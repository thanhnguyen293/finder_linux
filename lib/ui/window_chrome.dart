import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/finder_theme.dart';
import 'tabs/tab_drag.dart';
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

/// While a tab is dragged over the right part of the content, shades that
/// part to show the tab will open there, side by side.
class SplitDropHint extends StatelessWidget {
  const SplitDropHint({
    super.key,
    required this.tracker,
    required this.contentKey,
  });

  final TabDragTracker tracker;
  final GlobalKey contentKey;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IgnorePointer(
      child: ListenableBuilder(
        listenable: tracker,
        builder: (context, _) {
          final pointer = tracker.pointer;
          final box = contentKey.currentContext?.findRenderObject();
          if (!tracker.dragging || pointer == null || box is! RenderBox) {
            return const SizedBox.shrink();
          }
          final local = box.globalToLocal(pointer);
          final inZone =
              (Offset.zero & box.size).contains(local) &&
              local.dx >= box.size.width * splitZoneStart;
          if (!inZone) return const SizedBox.shrink();
          return Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.16),
                  border: Border.all(color: palette.accent, width: 2),
                  borderRadius: BorderRadius.circular(
                    FinderMetrics.radiusLarge,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context).splitDropHint,
                  style: TextStyle(
                    color: palette.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
