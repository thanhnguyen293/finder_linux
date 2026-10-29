import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/finder_theme.dart';
import '../finder_scope.dart';

/// macOS close / minimize / zoom buttons; glyphs appear when hovering the group.
class TrafficLights extends StatefulWidget {
  const TrafficLights({super.key});

  @override
  State<TrafficLights> createState() => _TrafficLightsState();
}

class _TrafficLightsState extends State<TrafficLights> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final window = FinderScope.of(context).window;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          _Light(
            color: palette.trafficClose,
            glyph: CupertinoIcons.xmark,
            showGlyph: _hover,
            onTap: window.close,
          ),
          _Light(
            color: palette.trafficMinimize,
            glyph: CupertinoIcons.minus,
            showGlyph: _hover,
            onTap: window.minimize,
          ),
          _Light(
            color: palette.trafficZoom,
            glyph: CupertinoIcons.plus,
            showGlyph: _hover,
            onTap: window.toggleMaximize,
          ),
        ],
      ),
    );
  }
}

class _Light extends StatelessWidget {
  const _Light({
    required this.color,
    required this.glyph,
    required this.showGlyph,
    required this.onTap,
  });

  final Color color;
  final IconData glyph;
  final bool showGlyph;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: showGlyph
            ? Icon(glyph, size: 8, color: Colors.black.withValues(alpha: 0.6))
            : null,
      ),
    );
  }
}
