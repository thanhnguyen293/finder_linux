import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'browser_controller.dart';
import 'file_actions.dart';

/// One tab: its own location, history, selection and focus.
class BrowserTab {
  BrowserTab({required this.id, required this.browser})
    : actions = FileActions(browser);

  final int id;
  final BrowserController browser;
  final FileActions actions;
  final contentFocus = FocusNode(debugLabel: 'content');
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
  TabsController(this._createBrowser);

  /// Builds a browser for a new tab with the window's current defaults.
  final BrowserController Function(String path) _createBrowser;

  final _tabs = <BrowserTab>[];
  final _paths = <int, String>{};
  int _active = 0;
  int _nextId = 0;

  List<BrowserTab> get tabs => UnmodifiableListView(_tabs);
  int get activeIndex => _active;
  BrowserTab get active => _tabs[_active];

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
    final tab = BrowserTab(id: _nextId++, browser: browser);
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

  void activate(int index) {
    if (index < 0 || index >= _tabs.length || index == _active) return;
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
