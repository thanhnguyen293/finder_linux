import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../core/result.dart';
import '../models/file_entry.dart';
import '../models/grouping.dart';
import '../models/sort_spec.dart';
import '../services/file_system_service.dart';
import 'selection_mixin.dart';

/// One-shot events for the UI to surface (snackbars, error alerts).
sealed class Notice {
  const Notice();
}

class FailureNotice extends Notice {
  const FailureNotice(this.failure);
  final Failure failure;
}

class TrashedNotice extends Notice {
  const TrashedNotice(this.count);
  final int count;
}

typedef FileClipboard = ({List<String> paths, bool cut});

const _maxCachedListings = 64;

/// State of one Finder window: location, history, listing and view options.
/// Selection lives in [SelectionMixin]; file operations in `FileActions`.
class BrowserController extends ChangeNotifier with SelectionMixin {
  BrowserController({
    required this.fs,
    required this.trashDir,
    required String initialPath,
    this._viewMode = ViewMode.icons,
    this._groupBy = GroupBy.none,
    this._sort = const SortSpec(),
    this._showHidden = false,
  }) : _path = initialPath,
       _columnRoot = p.normalize(initialPath);

  final FileSystemService fs;
  final String trashDir;

  String _path;
  String _columnRoot;
  final _back = <String>[];
  final _forward = <String>[];
  List<FileEntry> _all = const [];
  List<FileEntry> _visible = const [];
  bool _loading = true;
  int _ticket = 0;
  final _listings = <String, List<FileEntry>>{};
  Failure? _loadFailure;
  ViewMode _viewMode;
  SortSpec _sort;
  GroupBy _groupBy;
  List<EntryGroup> _groups = const [];
  bool _showHidden;
  String _query = '';
  int? _freeBytes;
  int _revision = 0;
  FileClipboard? _clipboard;

  StreamSubscription<FileSystemEvent>? _watch;
  Timer? _watchDebounce;
  final _notices = StreamController<Notice>.broadcast();

  String get path => _path;
  bool get canGoBack => _back.isNotEmpty;
  bool get canGoForward => _forward.isNotEmpty;
  bool get canGoUp => _path != '/';
  bool get isTrash => _path == trashDir;
  bool get loading => _loading;
  Failure? get loadFailure => _loadFailure;
  ViewMode get viewMode => _viewMode;
  SortSpec get sort => _sort;
  GroupBy get groupBy => _groupBy;

  /// Visible entries split into groups; empty when grouping is off.
  /// [entries] lists the same items in the same (grouped) order.
  List<EntryGroup> get groups => _groups;
  bool get showHidden => _showHidden;
  String get query => _query;
  int? get freeBytes => _freeBytes;
  FileClipboard? get clipboard => _clipboard;

  set clipboard(FileClipboard? value) {
    _clipboard = value;
    notifyListeners();
  }

  Stream<Notice> get notices => _notices.stream;

  /// Bumped on every reload so views caching other folders (column view)
  /// know to re-read them.
  int get revision => _revision;

  @override
  List<FileEntry> get entries => _visible;

  Future<void> start() => navigate(_path, record: false);

  /// [root] makes [target] the first column of the column view, as opening
  /// a sidebar item does in Finder.
  Future<void> navigate(
    String target, {
    String? select,
    String? root,
    bool record = true,
  }) async {
    final normalized = p.normalize(target);
    final ticket = ++_ticket;
    // List first, then swap location, history and entries in one frame, so
    // the old folder never shows under the new title while loading.
    final result = await fs.list(normalized);
    if (ticket != _ticket) return;
    if (record && normalized != _path) {
      _back.add(_path);
      _forward.clear();
    }
    _path = normalized;
    if (root != null) {
      _columnRoot = p.normalize(root);
    } else if (!_isWithinRoot(normalized)) {
      // Going above the first column (Back, parent folder) restarts the
      // columns at the new folder.
      _columnRoot = normalized;
    }
    _query = '';
    clearSelectionSilently();
    _apply(result, select: select);
    _watchCurrent();
    unawaited(_refreshFreeSpace());
  }

  Future<void> back() async {
    if (_back.isEmpty) return;
    final from = _path;
    final target = _back.removeLast();
    _forward.add(from);
    await navigate(target, record: false, select: _childOf(target, from));
  }

  Future<void> forward() async {
    if (_forward.isEmpty) return;
    _back.add(_path);
    await navigate(_forward.removeLast(), record: false);
  }

  /// First column of the column view; [path] is always it or inside it.
  String get columnRoot => _columnRoot;

  bool _isWithinRoot(String path) =>
      path == _columnRoot || p.isWithin(_columnRoot, path);

  /// Goes to the parent and highlights the folder we came from, as Finder does.
  Future<void> up() async {
    if (!canGoUp) return;
    await navigate(p.dirname(_path), select: _path);
  }

  Future<void> refresh() async {
    final ticket = _ticket;
    final result = await fs.list(_path);
    if (ticket != _ticket) return;
    _apply(result, keepSelection: true);
  }

  void _apply(
    Result<List<FileEntry>> result, {
    String? select,
    bool keepSelection = false,
  }) {
    _loading = false;
    _revision++;
    switch (result) {
      case Ok(:final value):
        _all = value;
        _loadFailure = null;
        _remember(_path, value);
      case Err(:final failure):
        _all = const [];
        _loadFailure = failure;
    }
    _rebuildVisible();
    if (select != null) {
      selectOnlySilently(select);
    } else if (keepSelection) {
      pruneSelectionSilently();
    }
    notifyListeners();
  }

  /// Lists another folder with this window's view options (column view).
  Future<Result<List<FileEntry>>> listDir(String dir) async {
    final result = await fs.list(dir);
    return switch (result) {
      Ok(:final value) => Ok(_present(_remember(dir, value), query: '')),
      Err() => result,
    };
  }

  /// Groups another folder's [sorted] listing with this window's Group By
  /// setting, so every column follows the same choice.
  List<EntryGroup> groupsFor(List<FileEntry> sorted) =>
      groupEntries(sorted, _groupBy, now: DateTime.now());

  /// Last known listing of [dir], so a newly built column can paint its
  /// contents in its first frame instead of flashing empty.
  List<FileEntry>? cachedListing(String dir) {
    final raw = _listings[dir];
    return raw == null ? null : _present(raw, query: '');
  }

  List<FileEntry> _remember(String dir, List<FileEntry> entries) {
    if (_listings.length >= _maxCachedListings) _listings.clear();
    return _listings[dir] = entries;
  }

  void setViewMode(ViewMode mode) {
    if (mode == _viewMode) return;
    _viewMode = mode;
    notifyListeners();
  }

  void sortBy(SortField field) => setSort(_sort.toggled(field));

  void setSort(SortSpec spec) {
    _sort = spec;
    _revision++;
    _rebuildVisible();
    notifyListeners();
  }

  void setGroupBy(GroupBy value) {
    if (value == _groupBy) return;
    _groupBy = value;
    _rebuildVisible();
    notifyListeners();
  }

  void toggleHidden() => setShowHidden(!_showHidden);

  void setShowHidden(bool value) {
    if (value == _showHidden) return;
    _showHidden = value;
    _revision++;
    _rebuildVisible();
    pruneSelectionSilently();
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    _rebuildVisible();
    pruneSelectionSilently();
    notifyListeners();
  }

  void emit(Notice notice) => _notices.add(notice);

  void _rebuildVisible() {
    final sorted = _present(_all, query: _query);
    _groups = groupEntries(sorted, _groupBy, now: DateTime.now());
    // Keyboard navigation and Shift-ranges walk entries, so it must follow
    // the on-screen (grouped) order.
    _visible = _groups.isEmpty
        ? sorted
        : [for (final g in _groups) ...g.entries];
  }

  List<FileEntry> _present(List<FileEntry> source, {required String query}) {
    final q = query.trim().toLowerCase();
    return source
        .where((e) => _showHidden || !e.isHidden)
        .where((e) => q.isEmpty || e.name.toLowerCase().contains(q))
        .toList()
      ..sort(_sort.compare);
  }

  void _watchCurrent() {
    _watch?.cancel();
    _watch = null;
    try {
      _watch = fs.watch(_path).listen((_) {
        // Copies emit bursts of events; coalesce them into one reload.
        _watchDebounce?.cancel();
        _watchDebounce = Timer(const Duration(milliseconds: 250), refresh);
      }, onError: (Object _) {});
    } on FileSystemException {
      // Unwatchable folders (permissions, pseudo filesystems) still work,
      // they just won't auto-refresh.
    }
  }

  Future<void> _refreshFreeSpace() async {
    final at = _path;
    final bytes = await fs.freeSpace(at);
    if (at != _path) return;
    _freeBytes = bytes;
    notifyListeners();
  }

  String? _childOf(String parent, String descendant) {
    if (!p.isWithin(parent, descendant)) return null;
    return p.join(parent, p.split(p.relative(descendant, from: parent)).first);
  }

  // Listings, df and watcher callbacks can complete after the window closes.
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _watch?.cancel();
    _watchDebounce?.cancel();
    _notices.close();
    super.dispose();
  }
}
