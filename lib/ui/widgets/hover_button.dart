import 'package:flutter/material.dart';

import '../../theme/finder_theme.dart';

/// Borderless toolbar button that only shows a background on hover/active.
class HoverButton extends StatefulWidget {
  const HoverButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onPressedAt,
    this.tooltip,
    this.active = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
  });

  final Widget child;
  final VoidCallback? onPressed;

  /// Like [onPressed] but receives the global tap position (for menus).
  final ValueChanged<Offset>? onPressedAt;
  final String? tooltip;
  final bool active;
  final EdgeInsets padding;

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _hover = false;

  bool get _enabled => widget.onPressed != null || widget.onPressedAt != null;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = widget.active || (_hover && _enabled)
        ? palette.controlHover
        : palette.control;
    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: _enabled
            ? (d) {
                widget.onPressed?.call();
                widget.onPressedAt?.call(d.globalPosition);
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(FinderMetrics.radiusSmall),
          ),
          child: IconTheme.merge(
            data: IconThemeData(
              size: 17,
              color: _enabled
                  ? palette.textPrimary
                  : palette.textSecondary.withValues(alpha: 0.5),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip, child: button);
    }
    return button;
  }
}
