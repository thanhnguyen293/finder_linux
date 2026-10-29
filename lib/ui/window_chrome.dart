import 'package:flutter/material.dart';

import '../theme/finder_theme.dart';
import 'tabs/tab_strip.dart';
import 'widgets/traffic_lights.dart';
import 'widgets/window_drag_area.dart';

/// Room for the traffic lights: 18px inset, three 12px lights, 8px gaps,
/// then a little breathing space before the first tab (Chrome on macOS).
const _trafficLightsWidth = 18.0 + 3 * 12 + 2 * 8 + 14;

/// Top band across the whole window, Chrome-style: the traffic lights, then
/// the tabs right after them. Empty space drags the window.
class WindowTopBar extends StatelessWidget {
  const WindowTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.palette.tabStrip,
      child: SizedBox(
        height: FinderMetrics.tabStripHeight,
        child: Row(
          children: [
            const SizedBox(
              width: _trafficLightsWidth,
              child: WindowDragArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 18, top: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TrafficLights(),
                  ),
                ),
              ),
            ),
            const Expanded(child: TabStrip()),
          ],
        ),
      ),
    );
  }
}

class SidebarResizer extends StatelessWidget {
  const SidebarResizer({super.key, required this.onDrag});

  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (d) => onDrag(d.delta.dx),
        child: Container(
          width: 4,
          color: palette.sidebar,
          alignment: Alignment.centerRight,
          child: Container(width: 0.5, color: palette.separator),
        ),
      ),
    );
  }
}
