import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/finder_theme.dart';

/// Frosted glass: blurs whatever lies behind it in the window, tints it
/// with [tint] and rims it with a light edge brighter at the top-left, as
/// light catches glass. With glass off it is a plain panel in [tint].
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.tint,
    required this.child,
    this.radius = FinderMetrics.radiusLarge,
    this.shadow = true,
  });

  final Color tint;
  final double radius;
  final bool shadow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final shape = BorderRadius.circular(radius);
    final shadows = shadow
        ? const [BoxShadow(color: Color(0x33000000), blurRadius: 18)]
        : null;
    if (!palette.glass) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 1),
          borderRadius: shape,
          border: Border.all(color: palette.separator),
          boxShadow: shadows,
        ),
        child: ClipRRect(borderRadius: shape, child: child),
      );
    }
    final dark = ThemeData.estimateBrightnessForColor(tint) == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: shape, boxShadow: shadows),
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: CustomPaint(
            foregroundPainter: _GlassEdge(radius: radius, dark: dark),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.62),
                // A faint sheen from the top, like light on curved glass.
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: dark ? 0.07 : 0.22),
                    Colors.white.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.45],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// The glass's rim: bright where light enters (top-left), fading around.
class _GlassEdge extends CustomPainter {
  _GlassEdge({required this.radius, required this.dark});

  final double radius;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(0.5);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: dark ? 0.35 : 0.8),
            Colors.white.withValues(alpha: dark ? 0.06 : 0.25),
            Colors.black.withValues(alpha: dark ? 0.3 : 0.08),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlassEdge old) =>
      old.radius != radius || old.dark != dark;
}
