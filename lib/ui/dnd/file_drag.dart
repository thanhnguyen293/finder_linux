import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import '../../l10n/app_localizations.dart';
import '../../models/file_entry.dart';
import '../../services/adb_service.dart';
import '../../state/drop_rules.dart';
import '../../theme/finder_theme.dart';
import '../commands.dart';
import '../dialogs/conflict_dialog.dart';
import '../finder_scope.dart';
import '../widgets/file_icon.dart';

// Drag and drop goes through the platform (GTK) session for every drag, so
// the same code handles drags inside Finder, files dropped in from other
// apps, and files dragged out to them. Each dragged file carries its path
// as `localData` (Finder-internal) and a file:// URI (other apps).

// TEMP diagnostics for split-view drops; removed once fixed.
final _dndLog = Platform.environment['FINDER_DEBUG_DND'] == null
    ? null
    : File('/tmp/finder-dnd.log');
void dndLog(String message) => _dndLog?.writeAsStringSync(
  '${DateTime.now().toIso8601String()} $message\n',
  mode: FileMode.append,
);

/// Moves or copies [paths] into [destDir]; name clashes are numbered.
Future<void> dropFiles(
  BuildContext context,
  List<String> paths,
  String destDir, {
  required bool copy,
}) => FinderScope.of(context).actions.dropInto(
  paths,
  destDir,
  copy: copy,
  copySuffix: AppLocalizations.of(context).copySuffix,
  resolve: conflictResolver(context),
);

/// Drag sources currently on screen, by path, so dragging one selected
/// item can carry the rest of the selection along.
final _dragSources = <String, GlobalKey<DragItemWidgetState>>{};

/// Makes an item draggable, within Finder and out to other apps.
class FileDraggable extends StatefulWidget {
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
  State<FileDraggable> createState() => _FileDraggableState();
}

class _FileDraggableState extends State<FileDraggable> {
  final _key = GlobalKey<DragItemWidgetState>();

  @override
  void initState() {
    super.initState();
    _dragSources[widget.entry.path] = _key;
  }

  @override
  void didUpdateWidget(FileDraggable old) {
    super.didUpdateWidget(old);
    if (old.entry.path != widget.entry.path) {
      _unregister(old.entry.path);
      _dragSources[widget.entry.path] = _key;
    }
  }

  @override
  void dispose() {
    _unregister(widget.entry.path);
    super.dispose();
  }

  void _unregister(String path) {
    if (_dragSources[path] == _key) _dragSources.remove(path);
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    if (!FinderScope.of(context).nativeDragAndDrop) return widget.child;
    return DragItemWidget(
      key: _key,
      allowedOperations: () => const [DropOperation.move, DropOperation.copy],
      dragItemProvider: (_) =>
          DragItem(localData: entry.path, suggestedName: entry.name)
            // Other apps can't read device files, so they only get the name.
            ..add(
              isDevicePath(entry.path)
                  ? Formats.plainText(entry.name)
                  : Formats.fileUri(Uri.file(entry.path)),
            ),
      // The picture the platform shows under the pointer.
      dragBuilder: (context, _) => _DragFeedback(entry: entry),
      child: DraggableWidget(
        dragItemsProvider: (context) {
          widget.onDragStarted?.call();
          final b = FinderScope.of(context).browser;
          // A selected item drags the whole (visible) selection with it.
          final paths = b.isSelected(entry.path)
              ? [entry.path, ...b.selection.where((p) => p != entry.path)]
              : [entry.path];
          final items = [
            for (final path in paths) ?_dragSources[path]?.currentState,
          ];
          dndLog('drag start $paths -> ${items.length} items');
          return items;
        },
        child: widget.child,
      ),
    );
  }
}

/// Wraps a drop zone for folder [dir]. [builder] gets whether files hover
/// over it, to draw a highlight. [onLinger] fires when files rest on the
/// target (spring-loaded tabs).
class FolderDropTarget extends StatefulWidget {
  const FolderDropTarget({
    super.key,
    required this.dir,
    required this.builder,
    this.toTrash = false,
    this.onDrop,
    this.onLinger,
  });

  final String dir;
  final Widget Function(BuildContext context, bool hovering) builder;

  /// Dropping here moves files to the Trash instead of into [dir].
  final bool toTrash;

  /// Overrides the default move/copy into [dir].
  final Future<void> Function(List<String> paths, {required bool copy})? onDrop;
  final VoidCallback? onLinger;

  @override
  State<FolderDropTarget> createState() => _FolderDropTargetState();
}

class _FolderDropTargetState extends State<FolderDropTarget> {
  bool _hovering = false;
  Timer? _linger;

  @override
  void dispose() {
    _linger?.cancel();
    super.dispose();
  }

  void _setHovering(bool value) {
    if (!value) _linger?.cancel();
    if (value == _hovering || !mounted) return;
    setState(() => _hovering = value);
    if (value && widget.onLinger != null) {
      _linger = Timer(const Duration(milliseconds: 550), () {
        if (mounted && _hovering) widget.onLinger?.call();
      });
    }
  }

  DropAction _decide(DropSession session) {
    // Only files land in folders; other drags (tabs) go to their own zones.
    if (!session.items.every((i) => i.canProvide(Formats.fileUri))) {
      return DropAction.none;
    }
    final local = [
      for (final item in session.items)
        if (item.localData case final String path) path,
    ];
    final keys = HardwareKeyboard.instance;
    final action = decideDrop(
      localPaths: local.length == session.items.length ? local : null,
      dir: widget.dir,
      allowMove: session.allowedOperations.contains(DropOperation.move),
      allowCopy: session.allowedOperations.contains(DropOperation.copy),
      ctrl: keys.isControlPressed,
      shift: keys.isShiftPressed,
      toTrash: widget.toTrash,
    );
    dndLog(
      'over dir=${widget.dir} local=$local items=${session.items.length} '
      'ops=${session.allowedOperations} -> $action',
    );
    return action;
    // ignore: dead_code
    return decideDrop(
      localPaths: local.length == session.items.length ? local : null,
      dir: widget.dir,
      allowMove: session.allowedOperations.contains(DropOperation.move),
      allowCopy: session.allowedOperations.contains(DropOperation.copy),
      ctrl: keys.isControlPressed,
      shift: keys.isShiftPressed,
      toTrash: widget.toTrash,
    );
  }

  Future<void> _perform(PerformDropEvent event) async {
    _setHovering(false);
    final paths = await _droppedPaths(event.session);
    dndLog(
      'perform dir=${widget.dir} paths=$paths op=${event.acceptedOperation} '
      'mounted=$mounted',
    );
    if (paths.isEmpty || !mounted) return;
    final copy = event.acceptedOperation == DropOperation.copy;
    final scope = FinderScope.of(context);
    if (widget.toTrash && paths.any(isDevicePath)) {
      await FinderCommands(context).deleteImmediately(paths);
    } else if (widget.toTrash) {
      await scope.actions.trashPaths(paths);
    } else if (widget.onDrop case final drop?) {
      await drop(paths, copy: copy);
    } else if (mounted) {
      await dropFiles(context, paths, widget.dir, copy: copy);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Outside the window (a tab being reordered is drawn in an overlay)
    // the zone just renders.
    if (FinderScope.maybeOf(context)?.nativeDragAndDrop != true) {
      return widget.builder(context, false);
    }
    return DropRegion(
      formats: const [Formats.fileUri],
      // Empty space inside the zone (column gaps, folder background)
      // accepts drops too.
      hitTestBehavior: HitTestBehavior.translucent,
      onDropOver: (event) => switch (_decide(event.session)) {
        DropAction.none => DropOperation.none,
        DropAction.move => DropOperation.move,
        DropAction.copy => DropOperation.copy,
      },
      onDropEnter: (_) {
        dndLog('enter ${widget.dir}');
        _setHovering(true);
      },
      onDropLeave: (_) {
        dndLog('leave ${widget.dir}');
        _setHovering(false);
      },
      onDropEnded: (_) {
        dndLog('ended ${widget.dir}');
        _setHovering(false);
      },
      onPerformDrop: _perform,
      child: widget.builder(context, _hovering),
    );
  }
}

/// File paths of a drop: Finder's own items carry their path; other apps
/// provide file:// URIs (non-file URIs, e.g. web links, are ignored).
Future<List<String>> _droppedPaths(DropSession session) async {
  final paths = <String>[];
  for (final item in session.items) {
    if (item.localData case final String path) {
      paths.add(path);
      continue;
    }
    final reader = item.dataReader;
    if (reader == null || !reader.canProvide(Formats.fileUri)) continue;
    final uri = Completer<Uri?>();
    final progress = reader.getValue<Uri>(
      Formats.fileUri,
      (value) => uri.complete(value),
      onError: (_) => uri.complete(null),
    );
    if (progress == null) continue;
    if (await uri.future case final value? when value.isScheme('file')) {
      paths.add(value.toFilePath());
    }
  }
  return paths;
}

/// Accent ring + tint marking where a drop would land.
BoxDecoration dropHighlight(BuildContext context) => BoxDecoration(
  color: context.palette.accent.withValues(alpha: 0.18),
  border: Border.all(color: context.palette.accent, width: 2),
  borderRadius: BorderRadius.circular(FinderMetrics.radiusSmall),
);

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.entry});

  final FileEntry entry;

  @override
  Widget build(BuildContext context) => SnapshotSettings(
    // The snapshot is laid out at the item's top-left, which put the icon
    // far from the pointer on wide rows (list view, the right split pane).
    // Centre it under the pointer instead, at its own size rather than the
    // row's.
    translation: (rect, dragPosition) => dragPosition - rect.center,
    constraintsTransform: (_) => const BoxConstraints(),
    child: FileIcon(entry: entry, size: 48, thumbnail: true),
  );
}
