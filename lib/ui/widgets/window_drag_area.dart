import 'package:flutter/widgets.dart';

import '../finder_scope.dart';

/// Empty toolbar space that moves the window on drag and zooms it on
/// double-click, since the native title bar is hidden.
///
/// The gesture layer sits *behind* [child], so it only receives pointers that
/// no button or field took. Wrapping the toolbar in a double-tap detector
/// instead made every button wait ~300 ms for a possible second click.
class WindowDragArea extends StatelessWidget {
  const WindowDragArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final window = FinderScope.of(context).window;
    return Stack(
      // Passthrough keeps the toolbar's fixed height on [child]; the default
      // loose fit let the row shrink and stick to the top edge.
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (_) => window.startDrag(),
            onDoubleTap: window.toggleMaximize,
          ),
        ),
        child,
      ],
    );
  }
}
