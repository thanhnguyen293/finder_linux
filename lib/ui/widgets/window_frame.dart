import 'package:flutter/widgets.dart';

import '../../theme/finder_theme.dart';
import '../finder_scope.dart';

/// Rounds the window like macOS. The native window is transparent, so the
/// clipped-off corners show the desktop; maximized or tiled windows stay
/// square.
class WindowFrame extends StatelessWidget {
  const WindowFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ValueListenableBuilder<bool>(
      valueListenable: FinderScope.of(context).window.squareCorners,
      child: child,
      builder: (context, square, child) {
        if (square) return child!;
        final radius = BorderRadius.circular(FinderMetrics.windowRadius);
        return ClipRRect(
          borderRadius: radius,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: palette.separator, width: 0.5),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
