import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/tabs_controller.dart';
import '../../theme/finder_theme.dart';
import '../commands.dart';
import '../dnd/file_drag.dart';
import '../finder_scope.dart';
import '../toolbar/finder_toolbar.dart';
import '../widgets/hover_button.dart';
import '../widgets/window_drag_area.dart';
import 'tab_menu.dart';

const _plusWidth = 36.0;
const _tabTopGap = 6.0;

/// Chrome-style tabs above the toolbar: the active tab joins the toolbar,
/// tabs shrink to fit, drag to reorder, middle-click closes.
class TabStrip extends StatelessWidget {
  const TabStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = FinderScope.of(context).tabs;
    return ListenableBuilder(
      listenable: tabs,
      builder: (context, _) => _build(context, tabs),
    );
  }

  Widget _build(BuildContext context, TabsController tabs) {
    final l10n = AppLocalizations.of(context);
    final cmd = FinderCommands(context);
    return Container(
      height: FinderMetrics.tabStripHeight,
      color: context.palette.tabStrip,
      child: WindowDragArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 6, top: _tabTopGap),
          child: LayoutBuilder(
            builder: (context, box) {
              final count = tabs.tabs.length;
              final width = ((box.maxWidth - _plusWidth) / count).clamp(
                FinderMetrics.tabMinWidth,
                FinderMetrics.tabMaxWidth,
              );
              return Row(
                children: [
                  // Shrink-wrapped so the empty strip after the tabs stays
                  // free for dragging the window.
                  Flexible(
                    child: ReorderableListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      buildDefaultDragHandles: false,
                      proxyDecorator: (child, _, _) => Material(
                        type: MaterialType.transparency,
                        child: child,
                      ),
                      itemCount: count,
                      onReorderItem: tabs.move,
                      itemBuilder: (context, i) => _HorizontalDragStart(
                        key: ValueKey(tabs.tabs[i].id),
                        index: i,
                        child: FolderDropTarget(
                          dir: tabs.tabs[i].browser.path,
                          // Built here because the tab itself can render
                          // outside the window scope while being reordered.
                          onDrop: (paths, {required copy}) => dropFiles(
                            context,
                            paths,
                            tabs.tabs[i].browser.path,
                            copy: copy,
                          ),
                          // Spring-loaded: rest files on a tab to open it,
                          // then drop inside one of its folders.
                          onLinger: () => tabs.activate(i),
                          builder: (_, hovering) => _ChromeTab(
                            dropHover: hovering,
                            title: folderTitle(
                              context,
                              tabs.tabs[i].browser.path,
                            ),
                            closeTooltip: l10n.tooltipCloseTab,
                            width: width,
                            active: i == tabs.activeIndex,
                            // Chrome hides the divider next to the active tab.
                            divider:
                                i != tabs.activeIndex &&
                                i + 1 != tabs.activeIndex &&
                                i + 1 < count,
                            onActivate: () => tabs.activate(i),
                            onClose: () => cmd.closeTab(i),
                            onMenu: (at) => showTabMenu(context, at, i),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
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
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Starts reordering only after a horizontal move past the touch slop, so a
/// plain click just selects the tab. (The default listener starts a drag on
/// pointer-down, which re-rendered the tab in the drag overlay on every
/// click.)
class _HorizontalDragStart extends ReorderableDragStartListener {
  const _HorizontalDragStart({
    super.key,
    required super.child,
    required super.index,
  });

  @override
  MultiDragGestureRecognizer createRecognizer() =>
      _HorizontalSlopDragRecognizer(debugOwner: this);
}

/// Reorders only after a real horizontal move. The stock horizontal
/// recognizer still starts at once when it is the only one in the gesture
/// arena (our tabs use raw pointer listeners), which turned every click on
/// a tab into a reorder drag.
class _HorizontalSlopDragRecognizer extends MultiDragGestureRecognizer {
  _HorizontalSlopDragRecognizer({super.debugOwner});

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) =>
      _HorizontalSlopState(event.position, event.kind, gestureSettings);

  @override
  String get debugDescription => 'horizontal slop multidrag';
}

class _HorizontalSlopState extends MultiDragPointerState {
  _HorizontalSlopState(
    super.initialPosition,
    super.kind,
    super.gestureSettings,
  );

  GestureMultiDragStartCallback? _starter;

  bool get _pastSlop =>
      (pendingDelta?.dx.abs() ?? 0) > computeHitSlop(kind, gestureSettings);

  @override
  void checkForResolutionAfterMove() {
    if (!_pastSlop) return;
    final starter = _starter;
    if (starter != null) {
      _starter = null;
      starter(initialPosition);
    } else {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    if (_pastSlop) {
      starter(initialPosition);
    } else {
      _starter = starter;
    }
  }
}

/// One tab. Everything it shows or does is passed in: while dragged it is
/// rebuilt inside the overlay, outside the window's [FinderScope].
class _ChromeTab extends StatefulWidget {
  const _ChromeTab({
    required this.title,
    required this.closeTooltip,
    required this.width,
    required this.active,
    required this.divider,
    required this.onActivate,
    required this.onClose,
    required this.onMenu,
    this.dropHover = false,
  });

  /// Files are being dragged over this tab.
  final bool dropHover;
  final String title;
  final String closeTooltip;
  final double width;
  final bool active;
  final bool divider;
  final VoidCallback onActivate;
  final VoidCallback onClose;
  final ValueChanged<Offset> onMenu;

  @override
  State<_ChromeTab> createState() => _ChromeTabState();
}

class _ChromeTabState extends State<_ChromeTab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final showClose = widget.active || _hover;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Listener(
        onPointerDown: (e) {
          if (e.buttons & kMiddleMouseButton != 0) {
            widget.onClose();
          } else if (e.buttons & kSecondaryMouseButton != 0) {
            widget.onMenu(e.position);
          } else if (e.buttons & kPrimaryMouseButton != 0) {
            widget.onActivate();
          }
        },
        child: CustomPaint(
          painter: _TabShapePainter(
            fill: widget.dropHover
                ? palette.accent.withValues(alpha: 0.25)
                : widget.active
                ? palette.toolbar
                : (_hover ? palette.controlHover : null),
            divider: widget.divider ? palette.separator : null,
            rounded: widget.active,
          ),
          child: SizedBox(
            width: widget.width,
            height: FinderMetrics.tabStripHeight - _tabTopGap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.folder_fill,
                    size: 14,
                    color: palette.folder,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: FinderMetrics.fontSizeSmall + 1,
                        color: widget.active
                            ? palette.textPrimary
                            : palette.textSecondary,
                      ),
                    ),
                  ),
                  if (showClose)
                    HoverButton(
                      tooltip: widget.closeTooltip,
                      padding: const EdgeInsets.all(3),
                      onPressed: widget.onClose,
                      child: const Icon(CupertinoIcons.xmark, size: 10),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Active tab: rounded top corners with outward curves at the bottom so it
/// flows into the toolbar, as in Chrome. Inactive: a soft hover pill.
class _TabShapePainter extends CustomPainter {
  _TabShapePainter({this.fill, this.divider, required this.rounded});

  final Color? fill;
  final Color? divider;
  final bool rounded;

  @override
  void paint(Canvas canvas, Size size) {
    if (fill case final color?) {
      final paint = Paint()..color = color;
      if (rounded) {
        const r = 8.0;
        const foot = 6.0;
        final path = Path()
          ..moveTo(-foot, size.height)
          ..quadraticBezierTo(0, size.height, 0, size.height - foot)
          ..lineTo(0, r)
          ..quadraticBezierTo(0, 0, r, 0)
          ..lineTo(size.width - r, 0)
          ..quadraticBezierTo(size.width, 0, size.width, r)
          ..lineTo(size.width, size.height - foot)
          ..quadraticBezierTo(
            size.width,
            size.height,
            size.width + foot,
            size.height,
          )
          ..close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawRRect(
          RRect.fromLTRBR(
            2,
            2,
            size.width - 2,
            size.height - 4,
            const Radius.circular(6),
          ),
          paint,
        );
      }
    }
    if (divider case final color?) {
      canvas.drawLine(
        Offset(size.width, 7),
        Offset(size.width, size.height - 9),
        Paint()
          ..color = color
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(_TabShapePainter old) =>
      old.fill != fill || old.divider != divider || old.rounded != rounded;
}
