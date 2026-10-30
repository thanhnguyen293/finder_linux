import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import '../../l10n/app_localizations.dart';
import '../../state/tabs_controller.dart';
import '../../theme/finder_theme.dart';
import '../commands.dart';
import '../dnd/file_drag.dart';
import '../finder_scope.dart';
import '../toolbar/finder_toolbar.dart';
import '../widgets/hover_button.dart';
import '../widgets/window_drag_area.dart';
import 'chrome_tab.dart';
import 'tab_drag.dart';
import 'tab_menu.dart';

const _plusWidth = 36.0;
const _slide = Duration(milliseconds: 160);

/// Chrome-style tabs: the active tab joins the toolbar, tabs shrink to fit.
/// Dragging a tab works like Chrome: it follows the pointer while the
/// others slide out of its way; pulled away from the strip it detaches
/// (the gap closes and a floating window preview follows the pointer).
class TabStrip extends StatefulWidget {
  const TabStrip({super.key});

  @override
  State<TabStrip> createState() => _TabStripState();
}

class _TabStripState extends State<TabStrip> {
  final _areaKey = GlobalKey();

  // Pressed tab, until the pointer moves far enough to start a drag.
  int? _pressedId;
  Offset? _pressAt;
  Offset _grab = Offset.zero;

  // Tab being dragged and the pointer, in strip coordinates.
  int? _dragId;
  double _pointerX = 0;

  @override
  Widget build(BuildContext context) {
    final scope = FinderScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([scope.tabs, scope.tabDrag]),
      builder: (context, _) => _build(context, scope),
    );
  }

  Widget _build(BuildContext context, FinderScope scope) {
    final l10n = AppLocalizations.of(context);
    final cmd = FinderCommands(context);
    final tabs = scope.tabs;
    final tracker = scope.tabDrag;
    return Container(
      height: FinderMetrics.tabStripHeight,
      color: context.palette.tabStrip,
      child: WindowDragArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 6, top: tabTopGap),
          child: LayoutBuilder(
            builder: (context, box) {
              final all = tabs.tabs;
              final width = _widthFor(box.maxWidth, all.length);
              final dragging = _dragId != null && tracker.dragging;
              final detached = dragging && !tracker.nearStrip;
              final dragIndex = all.indexWhere((t) => t.id == _dragId);
              final dragLeft = _dragLeft(width, all.length);
              // The slot the dragged tab would drop into; others make room.
              final target = dragging && !detached
                  ? _slotFor(dragLeft, width, all.length)
                  : null;
              final others = [
                for (final t in all)
                  if (!dragging || t.id != _dragId) t,
              ];
              // Detached, the dragged tab leaves the strip: the gap closes.
              final slots = all.length - (detached ? 1 : 0);

              Widget tab(BrowserTab t, {required bool floating}) => _tabWidget(
                context,
                scope,
                t,
                width: width,
                floating: floating,
                onClose: () => cmd.closeTab(all.indexOf(t)),
              );

              return SizedBox(
                key: _areaKey,
                width: box.maxWidth,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final (i, t) in others.indexed)
                      AnimatedPositioned(
                        key: ValueKey(t.id),
                        duration: _slide,
                        curve: Curves.easeOutCubic,
                        top: 0,
                        bottom: 0,
                        left:
                            width * (target != null && i >= target ? i + 1 : i),
                        width: width,
                        child: tab(t, floating: false),
                      ),
                    // The moving tab follows the pointer, on top.
                    if (dragging && !detached && dragIndex >= 0)
                      Positioned(
                        key: ValueKey(_dragId),
                        top: 0,
                        bottom: 0,
                        left: dragLeft,
                        width: width,
                        child: tab(all[dragIndex], floating: true),
                      ),
                    AnimatedPositioned(
                      duration: _slide,
                      curve: Curves.easeOutCubic,
                      top: 0,
                      bottom: 0,
                      left: width * slots,
                      width: _plusWidth,
                      child: Center(
                        child: HoverButton(
                          tooltip: l10n.tooltipNewTab,
                          padding: const EdgeInsets.all(4),
                          onPressed: cmd.newTab,
                          child: const Icon(CupertinoIcons.plus, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _tabWidget(
    BuildContext context,
    FinderScope scope,
    BrowserTab t, {
    required double width,
    required bool floating,
    required VoidCallback onClose,
  }) {
    final tabs = scope.tabs;
    final index = tabs.tabs.indexOf(t);
    final active = index == tabs.activeIndex;
    return Listener(
      onPointerDown: (e) => _onDown(t, e),
      onPointerMove: (e) => _onMove(scope, t, e),
      onPointerUp: (_) => _onUp(scope, t),
      onPointerCancel: (_) => _reset(scope),
      child: FolderDropTarget(
        dir: t.browser.path,
        onDrop: (paths, {required copy}) =>
            dropFiles(context, paths, t.browser.path, copy: copy),
        // Spring-loaded: rest files on a tab to open it, then drop inside
        // one of its folders.
        onLinger: () => tabs.activate(tabs.tabs.indexOf(t)),
        builder: (_, hovering) => ChromeTab(
          dropHover: hovering,
          title: folderTitle(context, t.browser.path),
          closeTooltip: AppLocalizations.of(context).tooltipCloseTab,
          width: width,
          active: active,
          paired: !active && tabs.isInSplit(t),
          // Chrome hides dividers beside the active and the moving tab.
          divider:
              !floating &&
              _dragId == null &&
              !active &&
              index + 1 != tabs.activeIndex &&
              index + 1 < tabs.tabs.length,
          onActivate: () => tabs.activate(tabs.tabs.indexOf(t)),
          onClose: onClose,
          onMenu: (at) => showTabMenu(context, at, tabs.tabs.indexOf(t)),
        ),
      ),
    );
  }

  void _onDown(BrowserTab t, PointerDownEvent e) {
    if (e.buttons != kPrimaryMouseButton) return;
    _pressedId = t.id;
    _pressAt = e.position;
    _grab = e.localPosition;
  }

  void _onMove(FinderScope scope, BrowserTab t, PointerMoveEvent e) {
    final pressAt = _pressAt;
    if (_pressedId != t.id || pressAt == null) return;
    if (_dragId == null) {
      // Clicks never turn into drags: wait for real movement.
      if ((e.position - pressAt).distance <= kTouchSlop) return;
      _dragId = t.id;
      scope.tabDrag.start(t, grab: _grab, preview: _snapshot(t));
    }
    final tracker = scope.tabDrag;
    // Pulled to the window's edge: continue as a platform drag, which can
    // end in another Finder window or outside (a new window).
    if (scope.nativeDragAndDrop &&
        tracker.dragging &&
        !tracker.nearStrip &&
        scope.tabs.tabs.length > 1 &&
        isAtWindowEdge(e.position, MediaQuery.sizeOf(context))) {
      tracker.leaveWindow(e.pointer, e.position);
      _clear();
      return;
    }
    final area = _areaKey.currentContext?.findRenderObject();
    if (area is RenderBox) {
      setState(() => _pointerX = area.globalToLocal(e.position).dx);
    }
  }

  void _onUp(FinderScope scope, BrowserTab t) {
    final dragging = _dragId == t.id && scope.tabDrag.dragging;
    if (dragging && scope.tabDrag.nearStrip) {
      final all = scope.tabs.tabs;
      final width = _widthFor(_areaWidth(), all.length);
      final target = _slotFor(_dragLeft(width, all.length), width, all.length);
      scope.tabs.move(all.indexOf(t), target);
      scope.tabDrag.cancel();
    } else if (dragging) {
      // Away from the strip: the window splits or tears the tab off.
      scope.tabDrag.release();
    }
    _clear();
  }

  void _reset(FinderScope scope) {
    if (_dragId != null) scope.tabDrag.cancel();
    _clear();
  }

  void _clear() {
    if (!mounted) return;
    setState(() {
      _pressedId = null;
      _pressAt = null;
      _dragId = null;
    });
  }

  double _widthFor(double available, int count) =>
      ((available - _plusWidth) / count).clamp(
        FinderMetrics.tabMinWidth,
        FinderMetrics.tabMaxWidth,
      );

  double _areaWidth() {
    final area = _areaKey.currentContext?.findRenderObject();
    return area is RenderBox ? area.size.width : 0;
  }

  /// Left edge of the moving tab, kept within the row of tabs.
  double _dragLeft(double width, int count) =>
      (_pointerX - _grab.dx).clamp(0.0, (count - 1) * width);

  int _slotFor(double left, double width, int count) =>
      ((left + width / 2) / width).floor().clamp(0, count - 1);

  /// A small picture of the tab's pane for the floating window.
  ui.Image? _snapshot(BrowserTab t) {
    final boundary = t.previewKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;
    try {
      return boundary.toImageSync(pixelRatio: 0.5);
    } on Object {
      return null;
    }
  }
}
