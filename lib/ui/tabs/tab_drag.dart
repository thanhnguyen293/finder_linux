import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../state/tabs_controller.dart';

/// Where a dragged tab ends up.
enum TabDropOutcome { reorder, split, newWindow }

/// How far (px) the pointer may stray from the tab strip and still reorder.
const _stripSlack = 24.0;

bool isNearStrip(Offset pointer, Rect strip) =>
    strip.inflate(_stripSlack).contains(pointer);

/// How close (px) to the window's edge a dragged tab must come to leave
/// the window. Generous, since a quick flick may report its last position
/// inside the window well before the edge.
const _edgeBand = 12.0;

/// Whether [pointer] has reached the edge of a window of [size].
bool isAtWindowEdge(Offset pointer, Size size) =>
    !(Offset.zero & size).deflate(_edgeBand).contains(pointer);

/// Fraction of the content width, from the left, where the split zone
/// starts.
const splitZoneStart = 0.55;

/// Decides what releasing a dragged tab at [pointer] does: near the strip
/// it reorders, over the right part of the content it splits the window,
/// anywhere else it tears the tab off into its own window (as in Chrome).
/// A window's only tab always just reorders.
TabDropOutcome tabDropOutcome({
  required Offset pointer,
  required Rect strip,
  required Rect content,
  required int tabCount,
}) {
  if (tabCount < 2 || isNearStrip(pointer, strip)) {
    return TabDropOutcome.reorder;
  }
  if (content.contains(pointer) &&
      pointer.dx >= content.left + content.width * splitZoneStart) {
    return TabDropOutcome.split;
  }
  return TabDropOutcome.newWindow;
}

/// Follows a tab being dragged in the strip. The window feeds pointer
/// positions in; the content area listens to show the split drop zone.
class TabDragTracker extends ChangeNotifier {
  TabDragTracker({required this.onRelease, this.onLeaveWindow});

  /// Called with the dragged tab and the final pointer position.
  final void Function(BrowserTab tab, Offset pointer) onRelease;

  /// Called when the tab is pulled out to the window's edge, to carry on
  /// as a platform drag that can end in another window or outside. Gets
  /// the tab's preview, which it then owns.
  final void Function(
    BrowserTab tab,
    int pointer,
    Offset position,
    ui.Image? preview,
  )?
  onLeaveWindow;

  BrowserTab? _tab;
  Offset? _pointer;
  bool _nearStrip = true;
  Offset _grab = Offset.zero;
  ui.Image? _preview;

  BrowserTab? get tab => _tab;
  Offset? get pointer => _pointer;
  bool get dragging => _tab != null;

  /// Where the tab was picked up, relative to its top-left, so the floating
  /// tab stays under the pointer at the same spot.
  Offset get grab => _grab;

  /// Snapshot of the tab's content, shown in the floating window.
  ui.Image? get preview => _preview;

  /// Whether the pointer is still by the tab strip (reordering). Away from
  /// it the tab floats under the pointer instead of sliding in the strip.
  bool get nearStrip => _nearStrip;

  void start(BrowserTab tab, {Offset grab = Offset.zero, ui.Image? preview}) {
    _tab = tab;
    _pointer = null;
    _nearStrip = true;
    _grab = grab;
    _preview?.dispose();
    _preview = preview;
    notifyListeners();
  }

  void move(Offset position, {required Rect? strip}) {
    if (_tab == null) return;
    _pointer = position;
    _nearStrip = strip == null || isNearStrip(position, strip);
    notifyListeners();
  }

  /// Ends the drag and lets the window act on where it was released.
  void release() {
    final tab = _tab;
    final pointer = _pointer;
    cancel();
    if (tab != null && pointer != null) onRelease(tab, pointer);
  }

  /// Hands the drag over to [onLeaveWindow]; this tracker's part ends.
  void leaveWindow(int pointer, Offset position) {
    final tab = _tab;
    final preview = _preview;
    final leave = onLeaveWindow;
    if (tab == null || leave == null) return;
    _preview = null;
    cancel();
    leave(tab, pointer, position, preview);
  }

  /// Ends the drag with nothing for the window to do (dropped in the strip).
  void cancel() {
    if (_tab == null) return;
    _tab = null;
    _pointer = null;
    _nearStrip = true;
    _preview?.dispose();
    _preview = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _preview?.dispose();
    super.dispose();
  }
}
