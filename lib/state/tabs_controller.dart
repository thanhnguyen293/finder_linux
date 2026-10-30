import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'browser_controller.dart';
import '../services/clipboard_service.dart';
import 'file_actions.dart';
import 'transfer_controller.dart';
import 'undo_history.dart';

/// One tab: its own location, history, selection and focus.
class BrowserTab {
  BrowserTab({
    required this.id,
    required this.browser,
    required FileUndoHistory history,
    required TransferController transfers,
    required ClipboardController clipboard,
  }) : actions = FileActions(
         browser,
         history: history,
         transfers: transfers,
         clipboard: clipboard,
       );

  final int id;
  final BrowserController browser;
  final FileActions actions;
  final contentFocus = FocusNode(debugLabel: 'content');

  /// Marks the tab's on-screen pane, to snapshot it while the tab is
  /// dragged out of the strip.
  final previewKey = GlobalKey();
  final searchFocus = FocusNode(debugLabel: 'search');

  void dispose() {
    browser.dispose();
    contentFocus.dispose();
    searchFocus.dispose();
  }
}

/// The tabs of one window. Notifies when tabs are added, closed, moved or
/// activated, and when any tab moves to another folder (its title changes).
class TabsController extends ChangeNotifier {
  TabsController(
    this._createBrowser, {
    required this.history,
    required this.transfers,
    required this.clipboard,
  });

  /// Shared by every tab: undo applies to the whole window, as in Finder.
  final FileUndoHistory history;
  final TransferController transfers;
  final ClipboardController clipboard;

  /// Builds a browser for a new tab with the window's current defaults.
  final BrowserController Function(String path) _createBrowser;

  final _tabs = <BrowserTab>[];
  final _paths = <int, String>{};
  int _active = 0;
  int _nextId = 0;

  // Split view pairs two tabs by id, so reordering doesn't break it.
  int? _splitLeft;
  int? _splitRight;

  List<BrowserTab> get tabs => UnmodifiableListView(_tabs);
  int get activeIndex => _active;
  BrowserTab get active => _tabs[_active];

  /// The two tabs shown side by side, or null when not split.
  ({BrowserTab left, BrowserTab right})? get split {
    final left = _byId(_splitLeft);
    final right = _byId(_splitRight);
    return left == null || right == null ? null : (left: left, right: right);
  }

  bool isInSplit(BrowserTab tab) =>
      split != null && (tab.id == _splitLeft || tab.id == _splitRight);

  /// Shows [tab] beside the active tab (or, when [tab] is the active one,
  /// beside its neighbour), and focuses it. Needs at least two tabs.
  bool splitWith(BrowserTab tab) {
    final index = _tabs.indexOf(tab);
    if (index < 0 || _tabs.length < 2) return false;
    final partner = tab != active
        ? active
        : _tabs[index > 0 ? index - 1 : index + 1];
    _splitLeft = partner.id;
    _splitRight = tab.id;
    _active = index;
    notifyListeners();
    return true;
  }

  void unsplit() {
    if (_splitLeft == null && _splitRight == null) return;
    _clearSplit();
    notifyListeners();
  }

  void _clearSplit() {
    _splitLeft = null;
    _splitRight = null;
  }

  BrowserTab? _byId(int? id) {
    if (id == null) return null;
    for (final t in _tabs) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Opens [path] in a new tab after the active one. Background tabs
  /// ([activate] false) are what a middle-click opens, as in Chrome.
  /// [atEnd] appends instead, keeping the order of a batch (merged windows).
  BrowserTab open(
    String path, {
    String? select,
    bool activate = true,
    bool atEnd = false,
  }) {
    final browser = _createBrowser(path);
    final tab = BrowserTab(
      id: _nextId++,
      browser: browser,
      history: history,
      transfers: transfers,
      clipboard: clipboard,
    );
    final index = _tabs.isEmpty || atEnd ? _tabs.length : _active + 1;
    _tabs.insert(index, tab);
    if (activate) _active = index;
    _paths[tab.id] = browser.path;
    browser.addListener(() => _onBrowserChanged(tab));
    unawaited(browser.navigate(path, select: select, record: false));
    notifyListeners();
    return tab;
  }

  /// Closes the tab at [index]. Returns false when it was the last one, in
  /// which case the window should close instead.
  bool close(int index) {
    if (_tabs.length == 1) return false;
    final tab = _tabs.removeAt(index);
    if (tab.id == _splitLeft || tab.id == _splitRight) _clearSplit();
    _paths.remove(tab.id);
    // Like Chrome: closing the active tab activates its right neighbour.
    if (index < _active || _active >= _tabs.length) _active--;
    _active = _active.clamp(0, _tabs.length - 1);
    notifyListeners();
    tab.dispose();
    return true;
  }

  void closeOthers(int index) {
    final keep = _tabs[index];
    _clearSplit();
    for (final tab in List.of(_tabs)) {
      if (tab != keep) tab.dispose();
    }
    _tabs
      ..clear()
      ..add(keep);
    _paths.removeWhere((id, _) => id != keep.id);
    _active = 0;
    notifyListeners();
  }

  /// Activating a tab outside the split pair leaves split view.
  void activate(int index) {
    if (index < 0 || index >= _tabs.length || index == _active) return;
    if (split != null && !isInSplit(_tabs[index])) _clearSplit();
    _active = index;
    notifyListeners();
  }

  /// Next / previous tab, wrapping around.
  void cycle(int delta) => activate((_active + delta) % _tabs.length);

  void move(int from, int to) {
    if (from == to) return;
    final activeTab = active;
    final tab = _tabs.removeAt(from);
    _tabs.insert(to.clamp(0, _tabs.length), tab);
    _active = _tabs.indexOf(activeTab);
    notifyListeners();
  }

  void _onBrowserChanged(BrowserTab tab) {
    final path = tab.browser.path;
    if (_paths[tab.id] == path) return;
    _paths[tab.id] = path;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final tab in _tabs) {
      tab.dispose();
    }
    super.dispose();
  }
}
