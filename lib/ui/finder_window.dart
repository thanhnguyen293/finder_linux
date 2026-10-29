import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../l10n/app_localizations.dart';
import '../models/finder_settings.dart';
import '../models/sort_spec.dart';
import '../platform/window_channel.dart';
import '../services/file_system_service.dart';
import '../services/places_service.dart';
import '../services/window_registry.dart';
import '../state/browser_controller.dart';
import '../state/settings_controller.dart';
import '../state/sidebar_controller.dart';
import '../state/tabs_controller.dart';
import '../theme/finder_theme.dart';
import 'content_area.dart';
import 'finder_scope.dart';
import 'formatting.dart';
import 'keyboard.dart';
import 'sidebar/finder_sidebar.dart';
import 'toolbar/finder_toolbar.dart';
import 'widgets/bottom_bars.dart';
import 'widgets/window_frame.dart';
import 'window_chrome.dart';

class FinderWindow extends StatefulWidget {
  const FinderWindow({
    super.key,
    required this.fs,
    required this.places,
    required this.settings,
    required this.initialPath,
    this.initialSelection,
  });

  final FileSystemService fs;
  final PlacesService places;
  final SettingsController settings;
  final String initialPath;
  final String? initialSelection;

  @override
  State<FinderWindow> createState() => _FinderWindowState();
}

class _FinderWindowState extends State<FinderWindow> {
  // Settings last applied to this window, to tell which ones changed.
  late FinderSettings _applied = widget.settings.value;
  late final _tabs = TabsController(_createBrowser);
  late final _sidebar = SidebarController(widget.places);
  final _window = WindowChannel();
  WindowRegistry? _registry;
  double _sidebarWidth = FinderMetrics.sidebarDefaultWidth;
  String? _titledPath;

  /// New tabs start from the user's default view options.
  BrowserController _createBrowser(String path) {
    final browser = BrowserController(
      fs: widget.fs,
      trashDir: widget.places.trashFilesDir,
      initialPath: path,
      viewMode: _applied.viewMode,
      groupBy: _applied.groupBy,
      sort: SortSpec(
        field: _applied.sortField,
        ascending: SortSpec.defaultAscending(_applied.sortField),
        foldersFirst: _applied.foldersFirst,
      ),
      showHidden: _applied.showHidden,
    );
    // The stream ends when the tab's browser is disposed.
    browser.notices.listen(_showNotice);
    return browser;
  }

  @override
  void initState() {
    super.initState();
    _sidebar.start();
    _tabs.open(widget.initialPath, select: widget.initialSelection);
    _tabs.addListener(_syncWindowTitle);
    widget.settings.addListener(_applySettings);
    _startRegistry();
  }

  void _startRegistry() {
    final runtimeDir = widget.places.runtimeDir;
    if (runtimeDir == null) return;
    final registry = WindowRegistry(
      runtimeDir: runtimeDir,
      describeTabs: () => [
        for (final tab in _tabs.tabs)
          TabDescriptor(
            path: tab.browser.path,
            viewMode: tab.browser.viewMode.name,
          ),
      ],
      surrender: _surrender,
    );
    _registry = registry;
    // Without the socket this window just can't take part in merging.
    unawaited(registry.start().catchError((Object _) {}));
  }

  /// Another window took this window's tabs: remove the socket, then close.
  Future<void> _surrender() async {
    await _registry?.dispose();
    _registry = null;
    await _window.close();
  }

  void _syncWindowTitle() {
    final path = _tabs.active.browser.path;
    if (path == _titledPath) return;
    _titledPath = path;
    _window.setTitle(path == '/' ? '/' : p.basename(path));
  }

  void _showNotice(Notice notice) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final text = switch (notice) {
      FailureNotice(:final failure) => failureMessage(l10n, failure),
      TrashedNotice(:final count) => l10n.movedToTrash(count),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Settings edited while this window is open take effect in all its tabs;
  /// only the options that actually changed are applied, so the user's
  /// in-tab choices (e.g. a different view) aren't reset by unrelated edits.
  void _applySettings() {
    final next = widget.settings.value;
    final prev = _applied;
    _applied = next;
    for (final tab in _tabs.tabs) {
      final b = tab.browser;
      if (next.viewMode != prev.viewMode) b.setViewMode(next.viewMode);
      if (next.groupBy != prev.groupBy) b.setGroupBy(next.groupBy);
      if (next.showHidden != prev.showHidden) b.setShowHidden(next.showHidden);
      if (next.sortField != prev.sortField ||
          next.foldersFirst != prev.foldersFirst) {
        b.setSort(
          b.sort.copyWith(
            field: next.sortField,
            ascending: next.sortField == prev.sortField
                ? null
                : SortSpec.defaultAscending(next.sortField),
            foldersFirst: next.foldersFirst,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    widget.settings.removeListener(_applySettings);
    _tabs.removeListener(_syncWindowTitle);
    unawaited(_registry?.dispose());
    _tabs.dispose();
    _sidebar.dispose();
    _window.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _tabs,
      builder: (context, _) {
        final tab = _tabs.active;
        // Keyed by tab so switching tabs rebuilds the views against the new
        // tab's controller; the tab strip itself stays outside.
        final tabKey = ValueKey(tab.id);
        return FinderScope(
          browser: tab.browser,
          actions: tab.actions,
          sidebar: _sidebar,
          window: _window,
          contentFocus: tab.contentFocus,
          tabs: _tabs,
          registry: _registry,
          child: Builder(
            builder: (context) => Focus(
              onKeyEvent: (_, event) => handleGlobalKey(
                context,
                event,
                searchFocus: _tabs.active.searchFocus,
              ),
              child: WindowFrame(
                child: Scaffold(
                  body: Column(
                    children: [
                      const WindowTopBar(),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: _sidebarWidth,
                              child: KeyedSubtree(
                                key: tabKey,
                                child: const FinderSidebar(),
                              ),
                            ),
                            SidebarResizer(onDrag: _resizeSidebar),
                            Expanded(
                              child: KeyedSubtree(
                                key: tabKey,
                                child: Column(
                                  children: [
                                    FinderToolbar(searchFocus: tab.searchFocus),
                                    const Expanded(child: ContentArea()),
                                    const PathBar(),
                                    const StatusBar(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _resizeSidebar(double dx) => setState(() {
    _sidebarWidth = (_sidebarWidth + dx).clamp(
      FinderMetrics.sidebarMinWidth,
      FinderMetrics.sidebarMaxWidth,
    );
  });
}
