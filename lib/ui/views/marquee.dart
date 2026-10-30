import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../theme/finder_theme.dart';
import '../finder_scope.dart';
import 'view_common.dart';

/// Paths of the items a selection rectangle touches; [rect] is in the
/// scroll content's coordinates (the top of the content is y = 0).
typedef MarqueeHitTest = Iterable<String> Function(Rect rect);

/// Pointer travel before a press on empty space becomes a selection
/// rectangle rather than a click.
const _slop = 4.0;

/// Band along the top and bottom edges that scrolls while selecting.
const _edge = 28.0;

/// Finder's selection rectangle: press on empty space and drag to select
/// every item the rectangle touches. Ctrl or Shift adds to the selection.
/// Near the top or bottom edge the view scrolls and keeps selecting.
class MarqueeSelector extends StatefulWidget {
  const MarqueeSelector({
    super.key,
    required this.controller,
    required this.hitTest,
    required this.child,
  });

  /// The vertical scroll view under the rectangle.
  final ScrollController controller;
  final MarqueeHitTest hitTest;
  final Widget child;

  @override
  State<MarqueeSelector> createState() => _MarqueeSelectorState();
}

class _MarqueeSelectorState extends State<MarqueeSelector> {
  int? _pointer;

  /// Where the drag began, in content coordinates (stays put on scroll).
  Offset? _anchor;
  Offset? _pressAt;

  /// The pointer, in this widget's coordinates.
  Offset _pointerAt = Offset.zero;
  bool _active = false;
  Set<String> _base = const {};
  Timer? _autoScroll;

  double get _offset =>
      widget.controller.hasClients ? widget.controller.offset : 0;

  @override
  void dispose() {
    _autoScroll?.cancel();
    super.dispose();
  }

  void _down(PointerDownEvent e) {
    // Presses on items belong to the items (select, drag the file).
    if (e.buttons != kPrimaryMouseButton ||
        e.pointer == EntryGestures.claimedPointer) {
      return;
    }
    final b = FinderScope.of(context).browser;
    if (b.renamingPath != null) return;
    final keys = HardwareKeyboard.instance;
    _base = keys.isControlPressed || keys.isShiftPressed
        ? {...b.selection}
        : const {};
    _pointer = e.pointer;
    _pressAt = e.localPosition;
    _pointerAt = e.localPosition;
    _anchor = e.localPosition + Offset(0, _offset);
  }

  void _move(PointerMoveEvent e) {
    if (e.pointer != _pointer) return;
    _pointerAt = e.localPosition;
    final pressAt = _pressAt;
    if (!_active &&
        pressAt != null &&
        (_pointerAt - pressAt).distance > _slop) {
      _active = true;
    }
    if (!_active) return;
    _select();
    _updateAutoScroll();
  }

  void _end(PointerEvent e) {
    if (e.pointer != _pointer) return;
    _autoScroll?.cancel();
    _autoScroll = null;
    _pointer = null;
    _anchor = null;
    _pressAt = null;
    if (_active) setState(() => _active = false);
  }

  Rect? get _contentRect {
    final anchor = _anchor;
    if (anchor == null) return null;
    return Rect.fromPoints(anchor, _pointerAt + Offset(0, _offset));
  }

  void _select() {
    final rect = _contentRect;
    if (rect == null || !mounted) return;
    FinderScope.of(
      context,
    ).browser.selectPaths({..._base, ...widget.hitTest(rect)});
    setState(() {});
  }

  /// Pixels to scroll per tick: toward whichever edge the pointer is
  /// near, faster closer to it; 0 away from the edges.
  double _scrollStep() {
    final height = context.size?.height ?? 0;
    final y = _pointerAt.dy;
    if (y < _edge) return -(_edge - y).clamp(0, _edge) / 2;
    if (y > height - _edge) return (y - (height - _edge)).clamp(0, _edge) / 2;
    return 0;
  }

  void _updateAutoScroll() {
    if (_scrollStep() == 0) {
      _autoScroll?.cancel();
      _autoScroll = null;
      return;
    }
    _autoScroll ??= Timer.periodic(const Duration(milliseconds: 16), (_) {
      final controller = widget.controller;
      if (!controller.hasClients || _pointer == null) return;
      final position = controller.position;
      final next = (position.pixels + _scrollStep()).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if (next != position.pixels) {
        position.jumpTo(next);
        _select();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rect = _contentRect;
    final palette = context.palette;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _down,
      onPointerMove: _move,
      onPointerUp: _end,
      onPointerCancel: _end,
      child: Stack(
        children: [
          widget.child,
          if (_active && rect != null)
            Positioned.fromRect(
              rect: rect.shift(Offset(0, -_offset)),
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.accent.withValues(alpha: 0.15),
                    border: Border.all(
                      color: palette.accent.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One run of the icon grid: its items' paths, after a group header when
/// [header] is true.
typedef GridSection = ({bool header, List<String> paths});

/// Icon grid items whose tile touches [rect]. Tiles sit in [columns]
/// cells of [cellWidth] × [tileHeight] from ([padding], [padding]); a
/// grouped section starts with a [headerHeight] header. The tile's own
/// margin doesn't count, so a rectangle in the gap selects nothing.
Iterable<String> gridHits(
  Rect rect, {
  required List<GridSection> sections,
  required int columns,
  required double cellWidth,
  required double tileHeight,
  required double padding,
  required double headerHeight,
}) sync* {
  var top = padding;
  for (final section in sections) {
    if (section.header) top += headerHeight;
    for (final (i, path) in section.paths.indexed) {
      final cell = Rect.fromLTWH(
        padding + (i % columns) * cellWidth,
        top + (i ~/ columns) * tileHeight,
        cellWidth,
        tileHeight,
      );
      if (cell.deflate(6).overlaps(rect)) yield path;
    }
    top += (section.paths.length / columns).ceil() * tileHeight;
  }
}

/// List rows touching [rect] vertically; [rows] holds a path per row, or
/// null for a group header, each [rowHeight] tall from y = 0.
Iterable<String> listHits(
  Rect rect, {
  required List<String?> rows,
  required double rowHeight,
}) sync* {
  for (final (i, path) in rows.indexed) {
    final top = i * rowHeight;
    if (path != null && top < rect.bottom && top + rowHeight > rect.top) {
      yield path;
    }
  }
}
