import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:super_drag_and_drop/super_drag_and_drop.dart'
    show DropOperation;

import '../l10n/app_localizations.dart';
import '../launch_target.dart';
import '../models/finder_settings.dart';
import '../models/sort_spec.dart';
import '../platform/window_channel.dart';
import '../services/clipboard_service.dart';
import '../services/file_system_service.dart';
import '../services/places_service.dart';
import '../services/recent_folders.dart';
import '../services/session_store.dart';
import '../services/transfer_service.dart';
import '../services/window_registry.dart';
import '../state/browser_controller.dart';
import '../state/settings_controller.dart';
import '../state/sidebar_controller.dart';
import '../state/tabs_controller.dart';
import '../state/transfer_controller.dart';
import '../state/undo_history.dart';
import '../state/update_controller.dart';
import '../theme/finder_theme.dart';
import 'app_services.dart';
import 'dnd/file_drag.dart' show dndLog;
import 'finder_scope.dart';
import 'formatting.dart';
import 'keyboard.dart';
import 'sidebar/finder_sidebar.dart';
import 'widgets/transfer_panel.dart';
import 'widgets/window_frame.dart';
import 'window_chrome.dart';
import 'tabs/tab_drag.dart';
import 'tabs/tab_drag_ghost.dart';
import 'tabs/tab_native_drag.dart';
import 'settings/settings_dialog.dart';
import 'tab_pane.dart';

/// Gutter around and between split view panes.
const _splitGap = 6.0;

class FinderWindow extends StatefulWidget {
  const FinderWindow({
    super.key,
    required this.fs,
    required this.places,
    required this.settings,
    required this.initialPath,
    this.initialSelection,
    this.nativeDragAndDrop = true,
    required this.clipboardStore,
    this.restoredSession,
    this.sessionStore,
    this.recents,
  });

  final FileSystemService fs;
  final PlacesService places;
  final SettingsController settings;
  final bool nativeDragAndDrop;
  final FileClipboardStore clipboardStore;
  final Session? restoredSession;
  final SessionStore? sessionStore;
  final RecentFolders? recents;
  final String initialPath;
  final String? initialSelection;

  @override
  State<FinderWindow> createState() => _FinderWindowState();
}

class _FinderWindowState extends State<FinderWindow> {
  // Settings last applied to this window, to tell which ones changed.
  late FinderSettings _applied = widget.settings.value;
  late final _transfers = TransferController(TransferService(widget.fs));
  late final _tabs = TabsController(
    _createBrowser,
    history: FileUndoHistory(
      fs: widget.fs,
      trashFilesDir: widget.places.trashFilesDir,
    ),
    transfers: _transfers,
    clipboard: ClipboardController(widget.clipboardStore),
  );
  late final _sidebar = SidebarController(widget.places, adb: widget.fs.adb);
  final _window = WindowChannel();
  WindowRegistry? _registry;
  double _sidebarWidth = FinderMetrics.sidebarDefaultWidth;
  late final _tabDrag = TabDragTracker(
    onRelease: _onTabReleased,
    onLeaveWindow: _dragTabOut,
  );

  /// A tab dragged out of this window and dropped back on it; the drop
  /// handler already acted on it.
  int? _droppedBackTab;

  /// Whether a tab dragged out of this window is still over it.
  bool _tabDragInside = true;
  final _stripKey = GlobalKey();
  final _contentKey = GlobalKey();
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
      onVisit: (path) {
        if (path != widget.places.trashFilesDir) {
          unawaited(widget.recents?.add(path));
        }
      },
    );
    // The stream ends when the tab's browser is disposed.
    browser.notices.listen(_showNotice);
    return browser;
  }

  @override
  void initState() {
    super.initState();
    _sidebar.start();
    _openInitialTabs();
    if (widget.sessionStore != null) _tabs.addListener(_scheduleSessionSave);
    _tabs.addListener(_syncWindowTitle);
    widget.settings.addListener(_applySettings);
    _startRegistry();
    _window.onLaunch = _onLaunch;
  }

  void _openInitialTabs() {
    final session = widget.restoredSession;
    if (session == null) {
      _tabs.open(widget.initialPath, select: widget.initialSelection);
      return;
    }
    for (final t in session.tabs) {
      final tab = _tabs.open(t.path, atEnd: true);
      final view = ViewMode.values.where((v) => v.name == t.viewMode);
      if (view.isNotEmpty) tab.browser.setViewMode(view.first);
    }
    _tabs.activate(session.active);
  }

  Timer? _sessionSave;

  /// Tabs change often (every folder visit); write at most twice a second.
  void _scheduleSessionSave() {
    _sessionSave?.cancel();
    _sessionSave = Timer(const Duration(milliseconds: 500), () {
      final store = widget.sessionStore;
      if (store == null || !mounted) return;
      unawaited(
        store.save((
          tabs: [
            for (final t in _tabs.tabs)
              (path: t.browser.path, viewMode: t.browser.viewMode.name),
          ],
          active: _tabs.activeIndex,
        )),
      );
    });
  }

  /// Finder launched again with this as the active window: a folder opens
  /// here as a tab when "open folders in tabs" is on; anything else (no
  /// folder, a new window asked for) gets a window of its own.
  Future<bool> _onLaunch(List<String> args) async {
    final openedWithPath = args.any((a) => !a.startsWith('--'));
    if (!openedWithPath ||
        args.contains(newWindowFlag) ||
        !widget.settings.value.openFoldersInTabs) {
      return false;
    }
    final (folder, select) = resolveLaunchTarget(
      args,
      home: widget.places.home,
    );
    _tabs.open(folder, select: select);
    unawaited(_window.present());
    return true;
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

  UpdateController? _updates;
  bool _announcedUpdate = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final updates = AppServices.updatesOf(context);
    if (updates == _updates) return;
    _updates?.removeListener(_announceUpdate);
    _updates = updates?..addListener(_announceUpdate);
    _announceUpdate();
  }

  /// Tells the user once per window that a new version is out.
  void _announceUpdate() {
    if (_announcedUpdate ||
        _updates?.status != UpdateStatus.available ||
        !mounted) {
      return;
    }
    _announcedUpdate = true;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.updateAvailable),
        duration: const Duration(seconds: 12),
        action: SnackBarAction(
          label: l10n.updateInstall,
          onPressed: () => showFinderSettings(context, showUpdates: true),
        ),
      ),
    );
  }

  void _showNotice(Notice notice) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final text = switch (notice) {
      FailureNotice(:final failure) => failureMessage(l10n, failure),
      TrashedNotice(:final count) => l10n.movedToTrash(count),
      SentToDeviceNotice(:final count, :final device) => l10n.sentToDevice(
        count,
        device,
      ),
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
    _updates?.removeListener(_announceUpdate);
    widget.settings.removeListener(_applySettings);
    _tabs.removeListener(_syncWindowTitle);
    _tabs.removeListener(_scheduleSessionSave);
    _sessionSave?.cancel();
    unawaited(_registry?.dispose());
    _tabs.dispose();
    _tabs.clipboard.dispose();
    _transfers.dispose();
    _tabDrag.dispose();
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
        final pair = _tabs.split;
        // Panes are keyed by tab so a tab keeps its views (scroll, focus)
        // while it stays on screen; the tab strip itself stays outside.
        final content = pair == null
            ? TabPane(key: ValueKey(tab.id), tab: tab)
            // Split view: two separate cards on a darker gutter, as in
            // Chrome, so the panes read as two windows.
            : ColoredBox(
                color: context.palette.tabStrip,
                child: Padding(
                  padding: const EdgeInsets.all(_splitGap),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: _splitGap,
                    children: [
                      Expanded(
                        child: TabPane(
                          key: ValueKey(pair.left.id),
                          tab: pair.left,
                          inSplit: true,
                        ),
                      ),
                      Expanded(
                        child: TabPane(
                          key: ValueKey(pair.right.id),
                          tab: pair.right,
                          inSplit: true,
                        ),
                      ),
                    ],
                  ),
                ),
              );
        return FinderScope(
          browser: tab.browser,
          actions: tab.actions,
          sidebar: _sidebar,
          window: _window,
          contentFocus: tab.contentFocus,
          tabs: _tabs,
          registry: _registry,
          nativeDragAndDrop: widget.nativeDragAndDrop,
          tabDrag: _tabDrag,
          recents: widget.recents,
          child: Builder(
            builder: (context) => Focus(
              onKeyEvent: (_, event) => handleGlobalKey(
                context,
                event,
                searchFocus: _tabs.active.searchFocus,
              ),
              // Pointer positions while a tab is dragged, for tear-off and
              // split view decisions.
              child: Listener(
                onPointerMove: (e) =>
                    _tabDrag.move(e.position, strip: _globalRect(_stripKey)),
                // Mouse side buttons go back and forward, as in browsers.
                onPointerDown: (e) {
                  if (e.buttons & kBackMouseButton != 0) {
                    unawaited(_tabs.active.browser.back());
                  } else if (e.buttons & kForwardMouseButton != 0) {
                    unawaited(_tabs.active.browser.forward());
                  }
                },
                child: WindowFrame(
                  child: TabDropZone(
                    enabled: widget.nativeDragAndDrop,
                    onDrop: _onTabDropped,
                    onInside: (inside) => _tabDragInside = inside,
                    child: Scaffold(
                      body: Stack(
                        fit: StackFit.expand,
                        children: [
                          Column(
                            children: [
                              WindowTopBar(key: _stripKey),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(
                                      width: _sidebarWidth,
                                      child: KeyedSubtree(
                                        key: ValueKey(tab.id),
                                        child: const FinderSidebar(),
                                      ),
                                    ),
                                    SidebarResizer(onDrag: _resizeSidebar),
                                    Expanded(
                                      key: _contentKey,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          content,
                                          SplitDropHint(
                                            tracker: _tabDrag,
                                            contentKey: _contentKey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          TabDragGhost(tracker: _tabDrag),
                          TransferPanel(controller: _transfers),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// A dragged tab was released: split, tear off, or (near the strip)
  /// nothing more than the reorder the strip already did.
  void _onTabReleased(BrowserTab tab, Offset pointer) {
    final strip = _globalRect(_stripKey);
    final content = _globalRect(_contentKey);
    if (strip == null || content == null) return;
    switch (tabDropOutcome(
      pointer: pointer,
      strip: strip,
      content: content,
      tabCount: _tabs.tabs.length,
    )) {
      case TabDropOutcome.reorder:
        break;
      case TabDropOutcome.split:
        _tabs.splitWith(tab);
      case TabDropOutcome.newWindow:
        final index = _tabs.tabs.indexOf(tab);
        if (index < 0) return;
        unawaited(_window.openWindow(tab.browser.path));
        _tabs.close(index);
    }
  }

  /// A tab pulled to the window's edge continues as a platform drag:
  /// dropped on another Finder window it moves there, dropped outside it
  /// becomes a window of its own, Escape leaves it where it was.
  Future<void> _dragTabOut(
    BrowserTab tab,
    int pointer,
    Offset position,
    ui.Image? preview,
  ) async {
    final path = tab.browser.path;
    final image = await tabDragImage(
      title: path == '/' ? '/' : p.basename(path),
      preview: preview,
      palette: context.palette,
    );
    preview?.dispose();
    if (!mounted) {
      image.dispose();
      return;
    }
    final DropOperation? result;
    _tabDragInside = true;
    try {
      result = await startTabDrag(
        context: context,
        payload: (
          pid: processId,
          tab: tab.id,
          path: path,
          viewMode: tab.browser.viewMode.name,
        ),
        pointer: pointer,
        position: position,
        image: image,
        rect:
            (position - tabDragGrab) &
            Size(image.width.toDouble(), image.height.toDouble()),
      );
    } on Exception {
      return; // The platform refused the drag; the tab stays.
    }
    final droppedBack = _droppedBackTab == tab.id;
    _droppedBackTab = null;
    final index = _tabs.tabs.indexOf(tab);
    dndLog(
      'tab drag ended: $result inside=$_tabDragInside '
      'droppedBack=$droppedBack index=$index',
    );
    if (!mounted || droppedBack || index < 0) return;
    if (result == DropOperation.move) {
      // Another Finder window opened it.
      _tabs.close(index);
    } else if (!_tabDragInside) {
      // Released outside, where nothing takes tabs. Wayland reports that
      // the same way as Escape, so where the drag ended decides: outside
      // this window the tab becomes a window of its own.
      unawaited(_window.openWindow(path));
      _tabs.close(index);
    }
  }

  /// A tab from a platform drag landed on this window: one of ours acts as
  /// if released here; one from another window opens as a new tab.
  void _onTabDropped(TabPayload payload, Offset position) {
    if (payload.pid == processId) {
      final tab = _tabs.tabs.where((t) => t.id == payload.tab).firstOrNull;
      if (tab == null) return;
      _droppedBackTab = tab.id;
      _onTabReleased(tab, position);
      return;
    }
    final tab = _tabs.open(payload.path);
    final view = ViewMode.values.where((v) => v.name == payload.viewMode);
    if (view.firstOrNull case final mode?) tab.browser.setViewMode(mode);
    _window.present();
  }

  static Rect? _globalRect(GlobalKey key) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  void _resizeSidebar(double dx) => setState(() {
    _sidebarWidth = (_sidebarWidth + dx).clamp(
      FinderMetrics.sidebarMinWidth,
      FinderMetrics.sidebarMaxWidth,
    );
  });
}
