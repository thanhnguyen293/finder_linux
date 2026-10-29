import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/file_entry.dart';

/// Finder-style selection over [entries]: click, Ctrl-click, Shift-click,
/// keyboard cursor movement and inline-rename target.
mixin SelectionMixin on ChangeNotifier {
  List<FileEntry> get entries;

  final _selection = <String>{};
  String? _anchor;
  String? _cursor;
  String? _renaming;

  Set<String> get selection => UnmodifiableSetView(_selection);
  String? get cursor => _cursor;
  String? get renamingPath => _renaming;
  bool isSelected(String path) => _selection.contains(path);

  List<FileEntry> get selectedEntries =>
      entries.where((e) => _selection.contains(e.path)).toList();

  FileEntry? get cursorEntry {
    for (final e in entries) {
      if (e.path == _cursor) return e;
    }
    return null;
  }

  void select(String path, {bool toggle = false, bool range = false}) {
    if (range && _anchor != null) {
      _selectRange(_anchor!, path);
    } else if (toggle) {
      if (!_selection.remove(path)) _selection.add(path);
      _anchor = path;
    } else {
      _selection
        ..clear()
        ..add(path);
      _anchor = path;
    }
    _cursor = path;
    notifyListeners();
  }

  void selectAll() {
    _selection
      ..clear()
      ..addAll(entries.map((e) => e.path));
    notifyListeners();
  }

  void clearSelection() {
    if (_selection.isEmpty) return;
    clearSelectionSilently();
    notifyListeners();
  }

  /// Moves the keyboard cursor by [delta] items; [extend] grows the
  /// selection from the anchor like Shift+Arrow.
  void moveCursor(int delta, {bool extend = false}) {
    if (entries.isEmpty) return;
    final current = entries.indexWhere((e) => e.path == _cursor);
    final next = current < 0
        ? (delta > 0 ? 0 : entries.length - 1)
        : (current + delta).clamp(0, entries.length - 1);
    final path = entries[next].path;
    select(path, range: extend && _anchor != null);
  }

  /// Type-ahead: selects the first entry whose name starts with [prefix].
  void selectByPrefix(String prefix) {
    final lower = prefix.toLowerCase();
    for (final e in entries) {
      if (e.name.toLowerCase().startsWith(lower)) {
        select(e.path);
        return;
      }
    }
  }

  void beginRename([String? path]) {
    final target = path ?? _cursor ?? _selection.firstOrNull;
    if (target == null) return;
    _renaming = target;
    notifyListeners();
  }

  void cancelRename() {
    if (_renaming == null) return;
    _renaming = null;
    notifyListeners();
  }

  @protected
  void clearSelectionSilently() {
    _selection.clear();
    _anchor = null;
    _cursor = null;
    _renaming = null;
  }

  @protected
  void selectOnlySilently(String path) {
    _selection
      ..clear()
      ..add(path);
    _anchor = path;
    _cursor = path;
  }

  /// Drops selected paths that are no longer visible after a reload/filter.
  @protected
  void pruneSelectionSilently() {
    final visible = entries.map((e) => e.path).toSet();
    _selection.retainWhere(visible.contains);
    if (!visible.contains(_anchor)) _anchor = null;
    if (!visible.contains(_cursor)) _cursor = null;
    if (!visible.contains(_renaming)) _renaming = null;
  }

  void _selectRange(String from, String to) {
    final a = entries.indexWhere((e) => e.path == from);
    final b = entries.indexWhere((e) => e.path == to);
    if (a < 0 || b < 0) return;
    final (lo, hi) = a < b ? (a, b) : (b, a);
    _selection
      ..clear()
      ..addAll(entries.sublist(lo, hi + 1).map((e) => e.path));
  }
}
