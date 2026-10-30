import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import '../finder_scope.dart';

/// Scrolls [controller] while files dragged over [child] are near its
/// edge, faster the closer they get, as Finder does. Platform drags send
/// no pointer events, so positions come from a [DropMonitor].
class DragAutoScroll extends StatefulWidget {
  const DragAutoScroll({
    super.key,
    required this.controller,
    required this.axis,
    this.reverse = false,
    this.edge = 56,
    required this.child,
  });

  final ScrollController controller;
  final Axis axis;

  /// Matches the scroll view's `reverse`.
  final bool reverse;

  /// Width of the band along each edge that scrolls.
  final double edge;
  final Widget child;

  @override
  State<DragAutoScroll> createState() => _DragAutoScrollState();
}

/// Pixels per tick at the very edge.
const _maxStep = 22.0;
const _tick = Duration(milliseconds: 16);

/// Scroll speed for a drag at [position] along a [extent]-long view:
/// negative near the start, positive near the end, 0 in between.
double autoScrollStep(double position, double extent, double edge) {
  if (extent <= 2 * edge) return 0;
  if (position < edge) return -_maxStep * (1 - position.clamp(0, edge) / edge);
  final fromEnd = extent - position;
  if (fromEnd < edge) return _maxStep * (1 - fromEnd.clamp(0, edge) / edge);
  return 0;
}

class _DragAutoScrollState extends State<DragAutoScroll> {
  Timer? _timer;
  double _step = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _over(MonitorDropOverEvent event) {
    final size = context.size;
    final files = event.session.items.every(
      (i) => i.canProvide(Formats.fileUri),
    );
    if (!event.isInside || size == null || !files) return _stop();
    final horizontal = widget.axis == Axis.horizontal;
    final step = autoScrollStep(
      horizontal ? event.position.local.dx : event.position.local.dy,
      horizontal ? size.width : size.height,
      widget.edge,
    );
    // A reversed view grows its offset toward the visual start.
    _step = widget.reverse ? -step : step;
    if (_step == 0) return _stop();
    // The platform only reports movement; keep scrolling while the
    // pointer rests near the edge.
    _timer ??= Timer.periodic(_tick, (_) => _scroll());
  }

  void _scroll() {
    final controller = widget.controller;
    if (!controller.hasClients) return _stop();
    final position = controller.position;
    final next = (position.pixels + _step).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (next == position.pixels) return _stop();
    position.jumpTo(next);
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _step = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (FinderScope.maybeOf(context)?.nativeDragAndDrop != true) {
      return widget.child;
    }
    return DropMonitor(
      formats: const [Formats.fileUri],
      hitTestBehavior: HitTestBehavior.translucent,
      onDropOver: _over,
      onDropLeave: (_) => _stop(),
      onDropEnded: (_) => _stop(),
      child: widget.child,
    );
  }
}
