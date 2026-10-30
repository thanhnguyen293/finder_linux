import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import '../../theme/finder_theme.dart';
import '../widgets/hover_button.dart';

const tabTopGap = 6.0;

/// One tab. Everything it shows or does is passed in, so it can also be
/// drawn outside the window's [FinderScope] (the floating drag preview).
class ChromeTab extends StatefulWidget {
  const ChromeTab({
    super.key,
    required this.title,
    required this.closeTooltip,
    required this.width,
    required this.active,
    required this.divider,
    required this.onActivate,
    required this.onClose,
    required this.onMenu,
    this.dropHover = false,
    this.paired = false,
  });

  /// The other half of the active split view.
  final bool paired;

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
  State<ChromeTab> createState() => _ChromeTabState();
}

class _ChromeTabState extends State<ChromeTab> {
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
                : widget.paired
                ? palette.toolbar.withValues(alpha: 0.6)
                : (_hover ? palette.controlHover : null),
            divider: widget.divider ? palette.separator : null,
            rounded: widget.active || widget.paired,
          ),
          child: SizedBox(
            width: widget.width,
            height: FinderMetrics.tabStripHeight - tabTopGap,
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
                        color: widget.active || widget.paired
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
