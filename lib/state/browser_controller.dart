import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../core/result.dart';
import '../models/file_entry.dart';
import '../models/grouping.dart';
import '../models/sort_spec.dart';
import '../models/tag_color.dart';
import '../services/adb_service.dart';
import '../services/file_system_service.dart';
import '../services/search_service.dart';
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

const _maxCachedListings = 64;

/// Where the search field looks: the whole tree below the folder (the
/// default, as in Finder) or just the folder's own items.
enum SearchScope { subfolders, thisFolder }

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
    this.searcher = const SearchService(),
    this.onVisit,
  }) : _path = initialPath,
       _columnRoot = p.normalize(initialPath);

  final FileSystemService fs;
  final String trashDir;
  final SearchService searcher;

  /// Called with each folder the user opens (for Recent Folders).
  final void Function(String path)? onVisit;

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
  SearchScope _searchScope = SearchScope.subfolders;
  bool _searchContents = false;
  TagColor? _tag;

  /// Results of the tree search, replacing the folder listing while it is
  /// active; null until the first results of a query arrive.
  List<FileEntry>? _found;
  bool _searching = false;
  int _searchTicket = 0;
  StreamSubscription<String>? _searchRun;
  Timer? _searchDebounce;
  Timer? _searchFlush;
  int? _freeBytes;
  int _revision = 0;

  StreamSubscription<FileSystemEvent>? _watch;
  Timer? _watchDebounce;
  final _notices = StreamController<Notice>.broadcast();

  String get path => _path;
  bool get canGoBack => _back.isNotEmpty;
  bool get canGoForward => _forward.isNotEmpty;

  /// Folders Back would visit, nearest first (Back button's menu).
  List<String> get backHistory => _back.reversed.toList();
  List<String> get forwardHistory => _forward.reversed.toList();

  /// Goes [steps] back (negative: forward) through history in one jump,
  /// keeping the skipped folders in the other direction's history.
  Future<void> jumpHistory(int steps) async {
    final (from, to) = steps > 0 ? (_back, _forward) : (_forward, _back);
    final n = steps.abs();
    if (n == 0 || n > from.length) return;
    to.add(_path);
    for (var i = 1; i < n; i++) {
      to.add(from.removeLast());
    }
    await navigate(from.removeLast(), record: false);
  }

  bool get canGoUp => _path != '/' && !isDeviceRoot(_path);
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
  SearchScope get searchScope => _searchScope;
  bool get searchContents => _searchContents;

  /// The path bar shows a text field for typing a location (Ctrl+L).
  bool get editingLocation => _editingLocation;
  bool _editingLocation = false;

  void setEditingLocation(bool value) {
    if (value == _editingLocation) return;
    _editingLocation = value;
    notifyListeners();
  }

  /// Color tag whose files are listed (sidebar Tags), if any.
  TagColor? get tag => _tag;

  /// The view shows matches from the whole tree rather than this folder.
  bool get searchesTree =>
      _tag != null ||
      (_query.trim().isNotEmpty && _searchScope == SearchScope.subfolders);

  /// A tree search is still running.
  bool get searching => _searching;
  int? get freeBytes => _freeBytes;

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
    if (record) onVisit?.call(normalized);
    _query = '';
    _tag = null;
    _stopSearch();
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
    // Results live all over the tree; files may have changed anywhere.
    if (searchesTree) _runSearch();
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
    if (searchesTree) _runSearch();
    _rebuildVisible();
    pruneSelectionSilently();
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    // Typing searches by name; it leaves a tag listing.
    if (value.trim().isNotEmpty) _tag = null;
    _searchDebounce?.cancel();
    if (searchesTree) {
      // Until the tree search answers, filter this folder as you type.
      _searchDebounce = Timer(const Duration(milliseconds: 250), _runSearch);
    } else {
      _stopSearch();
    }
    _rebuildVisible();
    pruneSelectionSilently();
    notifyListeners();
  }

  /// Lists every file below this folder tagged [tag] (null stops).
  void showTagged(TagColor? tag) {
    _tag = tag;
    _query = '';
    tag == null ? _stopSearch() : _runSearch();
    _rebuildVisible();
    clearSelectionSilently();
    notifyListeners();
  }

  void setSearchScope(SearchScope scope) {
    if (scope == _searchScope) return;
    _searchScope = scope;
    searchesTree ? _runSearch() : _stopSearch();
    _rebuildVisible();
    pruneSelectionSilently();
    notifyListeners();
  }

  void setSearchContents(bool value) {
    if (value == _searchContents) return;
    _searchContents = value;
    if (searchesTree) _runSearch();
    notifyListeners();
  }

  void _stopSearch() {
    _searchTicket++;
    _searchDebounce?.cancel();
    _searchFlush?.cancel();
    unawaited(_searchRun?.cancel());
    _searchRun = null;
    _searching = false;
    _found = null;
  }

  /// Starts (or restarts) the tree search. Earlier results stay on screen
  /// until new ones arrive, so typing doesn't flash an empty view.
  void _runSearch() {
    final previous = _found;
    _stopSearch();
    _found = previous;
    final ticket = _searchTicket;
    final found = <FileEntry>[];
    var pending = 0;
    var listed = false;
    var dirty = false;
    _searching = true;

    void publish() {
      if (ticket != _searchTicket || !dirty) return;
      dirty = false;
      _found = List.of(found);
      _rebuildVisible();
      pruneSelectionSilently();
      notifyListeners();
    }

    void finishIfDone() {
      if (!listed || pending > 0 || ticket != _searchTicket) return;
      _searchFlush?.cancel();
      _searching = false;
      dirty = true;
      publish();
    }

    _searchFlush = Timer.periodic(
      const Duration(milliseconds: 150),
      (_) => publish(),
    );
    final results = switch (_tag) {
      final tag? => searcher.tagged(
        _path,
        tag.tagName,
        includeHidden: _showHidden,
      ),
      null => searcher.search(
        _path,
        _query,
        contents: _searchContents,
        includeHidden: _showHidden,
      ),
    };
    _searchRun = results.listen(
      (path) {
        pending++;
        unawaited(
          fs.entry(path).then((entry) {
            pending--;
            if (entry != null) {
              found.add(entry);
              dirty = true;
            }
            finishIfDone();
          }),
        );
      },
      onError: (Object _) {},
      onDone: () {
        listed = true;
        finishIfDone();
      },
    );
  }

  void emit(Notice notice) => _notices.add(notice);

  void _rebuildVisible() {
    final found = searchesTree ? _found : null;
    // Tree results already match (by name or contents): no name filter.
    final sorted = found != null
        ? _present(found, query: '')
        : _present(_all, query: _query);
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
    _stopSearch();
    _watch?.cancel();
    _watchDebounce?.cancel();
    _notices.close();
    super.dispose();
  }
}
