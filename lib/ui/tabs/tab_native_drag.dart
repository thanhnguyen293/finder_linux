import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
// The public API only starts drags from its own gesture detector; a tab
// switches to a platform drag midway through Finder's own tab drag.
// ignore: implementation_imports
import 'package:super_drag_and_drop/src/into_raw.dart';
import 'package:super_clipboard/super_clipboard.dart'
    show SimplePlatformCodec, SimpleValueFormat;
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:super_native_extensions/raw_drag_drop.dart' as raw;

import '../../theme/finder_theme.dart';

/// A tab dragged out of a window: which process and tab it came from and
/// what to reopen elsewhere.
typedef TabPayload = ({int pid, int tab, String path, String viewMode});

Map<String, Object> tabPayloadToJson(TabPayload t) => {
  'pid': t.pid,
  'tab': t.tab,
  'path': t.path,
  'viewMode': t.viewMode,
};

TabPayload? tabPayloadFromJson(Object? json) => switch (json) {
  {
    'pid': final int pid,
    'tab': final int tab,
    'path': final String path,
    'viewMode': final String viewMode,
  } =>
    (pid: pid, tab: tab, path: path, viewMode: viewMode),
  _ => null,
};

Future<String?> _decode(Object value, String format) async => switch (value) {
  final String s => s,
  final List<int> bytes => utf8.decode(bytes, allowMalformed: true),
  _ => null,
};

Object _encode(String value, String format) =>
    Uint8List.fromList(utf8.encode(value));

/// Finder's own type for dragged tabs. Only Finder windows accept it, so
/// a tab dropped on the desktop or in another app is refused, which is
/// the signal to open it as a new window.
const tabFormat = SimpleValueFormat<String>(
  fallback: SimplePlatformCodec<String>(
    formats: ['application/x-finder-linux-tab'],
    onDecode: _decode,
    onEncode: _encode,
  ),
);

/// Whether every item of [session] is a dragged tab.
bool isTabDrag(DropSession session) =>
    session.items.isNotEmpty &&
    session.items.every((i) => i.canProvide(tabFormat));

/// Starts a platform drag carrying [payload], showing [image] at [rect]
/// (global coordinates). Completes with how the drag ended.
Future<DropOperation?> startTabDrag({
  required BuildContext context,
  required TabPayload payload,
  required int pointer,
  required Offset position,
  required ui.Image image,
  required Rect rect,
}) async {
  final dragContext = await raw.DragContext.instance();
  final session = dragContext.newSession(pointer: pointer);
  final item = DragItem(localData: tabPayloadToJson(payload))
    ..add(tabFormat(jsonEncode(tabPayloadToJson(payload))));
  final configuration = await DragConfiguration(
    items: [
      DragConfigurationItem(
        item: item,
        image: TargetedWidgetSnapshot(WidgetSnapshot.image(image), rect),
      ),
    ],
    allowedOperations: const [DropOperation.move],
  ).intoRaw(1);
  final done = Completer<DropOperation?>();
  session.dragCompleted.addListener(() {
    configuration.disposeImages();
    if (!done.isCompleted) done.complete(session.dragCompleted.value);
  });
  if (!context.mounted) {
    configuration.disposeImages();
    return null;
  }
  await dragContext.startDrag(
    buildContext: context,
    session: session,
    configuration: configuration,
    position: position,
  );
  return done.future;
}

const _imageWidth = 300.0;
const _headerHeight = 30.0;

/// The picture under the pointer while a tab is dragged out: a small
/// window with the folder's name and a preview of its contents.
Future<ui.Image> tabDragImage({
  required String title,
  required ui.Image? preview,
  required FinderPalette palette,
}) {
  final bodyHeight = preview == null
      ? 120.0
      : (_imageWidth * preview.height / preview.width).clamp(120.0, 220.0);
  final size = Size(_imageWidth, _headerHeight + bodyHeight);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final window = RRect.fromRectAndRadius(
    Offset.zero & size,
    const Radius.circular(FinderMetrics.radiusLarge),
  );
  canvas
    ..clipRRect(window)
    ..drawRect(Offset.zero & size, Paint()..color = palette.content)
    ..drawRect(
      const Rect.fromLTWH(0, 0, _imageWidth, _headerHeight),
      Paint()..color = palette.toolbar,
    );
  if (preview != null) {
    final dest = Rect.fromLTWH(0, _headerHeight, _imageWidth, bodyHeight);
    final src = Rect.fromLTWH(
      0,
      0,
      preview.width.toDouble(),
      // Crop rather than squash a tall pane.
      (preview.width * bodyHeight / _imageWidth).clamp(
        0,
        preview.height.toDouble(),
      ),
    );
    canvas.drawImageRect(
      preview,
      src,
      dest,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }
  final text = TextPainter(
    text: TextSpan(
      text: title,
      style: TextStyle(
        fontSize: FinderMetrics.fontSize,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
        fontFamily: 'Ubuntu Sans',
      ),
    ),
    maxLines: 1,
    ellipsis: '…',
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: _imageWidth - 24);
  text.paint(canvas, Offset(12, (_headerHeight - text.height) / 2));
  text.dispose();
  canvas.drawRRect(
    window.deflate(0.5),
    Paint()
      ..color = palette.separator
      ..style = PaintingStyle.stroke,
  );
  final picture = recorder.endRecording();
  return picture.toImage(size.width.round(), size.height.round());
}

/// Where the pointer sits on the drag image: a little into the header,
/// as if holding the floating window by its title bar.
const tabDragGrab = Offset(40, _headerHeight / 2);

/// Accepts tabs dragged from any Finder window (this one included) and
/// hands them to [onDrop] with the global drop position. [onInside] says
/// whether a dragged tab is over this window, so the source can tell a
/// drag that ended outside (tear off) from one cancelled over it.
class TabDropZone extends StatelessWidget {
  const TabDropZone({
    super.key,
    required this.enabled,
    required this.onDrop,
    required this.onInside,
    required this.child,
  });

  /// Off where the platform drag plugin isn't available (widget tests).
  final bool enabled;
  final void Function(TabPayload tab, Offset position) onDrop;
  final ValueChanged<bool> onInside;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return DropMonitor(
      formats: const [tabFormat],
      onDropOver: (event) {
        if (isTabDrag(event.session)) onInside(true);
      },
      // Fired when the drag leaves the window (not just this widget).
      onDropLeave: (_) => onInside(false),
      child: DropRegion(
        formats: const [tabFormat],
        hitTestBehavior: HitTestBehavior.translucent,
        onDropOver: (event) =>
            isTabDrag(event.session) ? DropOperation.move : DropOperation.none,
        onPerformDrop: (event) async {
          final item = event.session.items.firstOrNull;
          if (item == null) return;
          // Same process: the payload travels as local data, no copying.
          var tab = tabPayloadFromJson(item.localData);
          final reader = item.dataReader;
          if (tab == null && reader != null) {
            final value = Completer<String?>();
            final progress = reader.getValue<String>(
              tabFormat,
              value.complete,
              onError: (_) => value.complete(null),
            );
            final raw = progress == null ? null : await value.future;
            tab = raw == null ? null : tabPayloadFromJson(jsonDecode(raw));
          }
          if (tab != null) onDrop(tab, event.position.global);
        },
        child: child,
      ),
    );
  }
}

/// This process's id, to tell a tab dropped back on its own window from
/// one arriving from another.
int get processId => pid;
