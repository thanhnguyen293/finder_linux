import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../../l10n/app_localizations.dart';
import '../../models/file_entry.dart';
import '../../theme/finder_theme.dart';
import '../finder_scope.dart';
import '../widgets/file_icon.dart';

/// What is being dragged: one or more items from one folder.
@immutable
class FileDragPayload {
  const FileDragPayload({required this.entries});

  final List<FileEntry> entries;

  List<String> get paths => [for (final e in entries) e.path];

  /// Whether dropping into [dir] would do anything sensible: not into the
  /// folder the items already live in, nor into one of the dragged folders.
  bool canDropInto(String dir) => entries.every(
    (e) => e.parent != dir && e.path != dir && !p.isWithin(e.path, dir),
  );
}

/// Drop handler shared by every target. Ctrl held at drop time copies,
/// otherwise items move, matching GNOME Files.
Future<void> dropFiles(
  BuildContext context,
  FileDragPayload payload,
  String destDir,
) {
  final scope = FinderScope.of(context);
  final copy = HardwareKeyboard.instance.isControlPressed;
  return scope.actions.dropInto(
    payload.paths,
    destDir,
    copy: copy,
    copySuffix: AppLocalizations.of(context).copySuffix,
  );
}

/// Makes an item draggable. The drag starts only once the pointer has
/// moved past the slop, so clicks and double-clicks never begin one.
class FileDraggable extends StatelessWidget {
  const FileDraggable({
    super.key,
    required this.entry,
    required this.child,
    this.onDragStarted,
  });

  final FileEntry entry;
  final Widget child;
  final VoidCallback? onDragStarted;

  @override
  Widget build(BuildContext context) {
    final b = FinderScope.of(context).browser;
    return _SlopDraggable<FileDragPayload>(
      // Dragging a selected item takes the whole selection along.
      data: FileDragPayload(
        entries: b.isSelected(entry.path) ? b.selectedEntries : [entry],
      ),
      allowedButtonsFilter: (buttons) => buttons == kPrimaryMouseButton,
      onDragStarted: onDragStarted,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _DragFeedback(
        entry: entry,
        count: b.isSelected(entry.path) ? b.selection.length : 1,
      ),
      child: child,
    );
  }
}

/// Wraps a drop zone for folder [dir]. [builder] gets whether acceptable
/// files hover over it, to draw a highlight. [onLinger] fires when files
/// rest on the target, for spring-loaded tabs.
class FolderDropTarget extends StatefulWidget {
  const FolderDropTarget({
    super.key,
    required this.dir,
    required this.builder,
    this.onDrop,
    this.onLinger,
  });

  final String dir;
  final Widget Function(BuildContext context, bool hovering) builder;

  /// Overrides the default move/copy into [dir] (e.g. Trash).
  final void Function(FileDragPayload payload)? onDrop;
  final VoidCallback? onLinger;

  @override
  State<FolderDropTarget> createState() => _FolderDropTargetState();
}

class _FolderDropTargetState extends State<FolderDropTarget> {
  Timer? _linger;

  @override
  void dispose() {
    _linger?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<FileDragPayload>(
      onWillAcceptWithDetails: (d) {
        final ok = widget.onDrop != null || d.data.canDropInto(widget.dir);
        if (ok && widget.onLinger != null) {
          _linger?.cancel();
          _linger = Timer(const Duration(milliseconds: 550), () {
            if (mounted) widget.onLinger?.call();
          });
        }
        return ok;
      },
      onLeave: (_) => _linger?.cancel(),
      onAcceptWithDetails: (d) {
        _linger?.cancel();
        final drop = widget.onDrop;
        if (drop != null) {
          drop(d.data);
        } else {
          dropFiles(context, d.data, widget.dir);
        }
      },
      builder: (context, candidates, _) =>
          widget.builder(context, candidates.isNotEmpty),
    );
  }
}

/// Accent ring + tint marking where a drop would land.
BoxDecoration dropHighlight(BuildContext context) => BoxDecoration(
  color: context.palette.accent.withValues(alpha: 0.18),
  border: Border.all(color: context.palette.accent, width: 2),
  borderRadius: BorderRadius.circular(FinderMetrics.radiusSmall),
);

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.entry, required this.count});

  final FileEntry entry;
  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // The drag overlay has no Material ancestor, hence no default text style
    // for the icon's extension label.
    return Material(
      type: MaterialType.transparency,
      child: Opacity(
        opacity: 0.85,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            FileIcon(entry: entry, size: 48, thumbnail: true),
            if (count > 1)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: palette.textOnAccent,
                      fontSize: FinderMetrics.fontSizeSmall,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SlopDraggable<T extends Object> extends Draggable<T> {
  const _SlopDraggable({
    required super.child,
    required super.feedback,
    super.data,
    super.allowedButtonsFilter,
    super.dragAnchorStrategy,
    super.onDragStarted,
  });

  @override
  MultiDragGestureRecognizer createRecognizer(
    GestureMultiDragStartCallback onStart,
  ) =>
      _SlopMultiDragRecognizer(allowedButtonsFilter: allowedButtonsFilter)
        ..onStart = onStart;
}

/// Like [ImmediateMultiDragGestureRecognizer], but when it wins the gesture
/// arena by default on pointer-down (no other recognizer competing, as with
/// our raw-pointer item handlers) it still waits for real movement.
class _SlopMultiDragRecognizer extends MultiDragGestureRecognizer {
  _SlopMultiDragRecognizer({super.allowedButtonsFilter})
    : super(debugOwner: null);

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) =>
      _SlopPointerState(event.position, event.kind, gestureSettings);

  @override
  String get debugDescription => 'slop multidrag';
}

class _SlopPointerState extends MultiDragPointerState {
  _SlopPointerState(super.initialPosition, super.kind, super.gestureSettings);

  GestureMultiDragStartCallback? _starter;

  bool get _pastSlop =>
      (pendingDelta?.distance ?? 0) > computeHitSlop(kind, gestureSettings);

  @override
  void checkForResolutionAfterMove() {
    if (!_pastSlop) return;
    final starter = _starter;
    if (starter != null) {
      _starter = null;
      starter(initialPosition);
    } else {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    if (_pastSlop) {
      starter(initialPosition);
    } else {
      _starter = starter;
    }
  }
}
