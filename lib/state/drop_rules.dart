import 'package:path/path.dart' as p;

/// What a drop would do.
enum DropAction { none, move, copy }

/// Whether [paths] can go into [dir]: not into the folder they already
/// live in, nor into one of the dragged folders or their subfolders.
bool canDropInto(List<String> paths, String dir) => paths.every(
  (path) => p.dirname(path) != dir && path != dir && !p.isWithin(path, dir),
);

/// Decides what dropping into [dir] does.
///
/// [localPaths] are the dragged files when the drag started in Finder;
/// null for files from another app, whose paths are only read on drop.
/// Finder's own drags move (Ctrl copies), as in GNOME Files. Files from
/// other apps are copied unless Shift is held, so dragging out of a
/// browser or archive never removes the original by surprise.
/// [allowMove] / [allowCopy] are what the drag source permits.
DropAction decideDrop({
  required List<String>? localPaths,
  required String dir,
  required bool allowMove,
  required bool allowCopy,
  bool ctrl = false,
  bool shift = false,
  bool toTrash = false,
}) {
  if (toTrash) return allowMove ? DropAction.move : DropAction.none;
  if (localPaths != null && !canDropInto(localPaths, dir)) {
    return DropAction.none;
  }
  final local = localPaths != null;
  final wantsCopy = local ? ctrl : !shift;
  if (wantsCopy && allowCopy) return DropAction.copy;
  if (!wantsCopy && allowMove) return DropAction.move;
  // Fall back to whatever the source allows.
  if (allowCopy) return DropAction.copy;
  if (allowMove) return DropAction.move;
  return DropAction.none;
}
