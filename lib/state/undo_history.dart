import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../core/result.dart';
import '../services/file_system_service.dart';

/// A file operation that can be undone and redone.
sealed class FileOp {
  const FileOp();
}

final class RenameOp extends FileOp {
  const RenameOp(this.from, this.to);
  final String from;
  final String to;
}

final class CreateFolderOp extends FileOp {
  const CreateFolderOp(this.path);
  final String path;
}

/// Copies: (source, created copy).
final class CopyOp extends FileOp {
  const CopyOp(this.pairs);
  final List<(String, String)> pairs;
}

/// Moves: (from, to).
final class MoveOp extends FileOp {
  const MoveOp(this.pairs);
  final List<(String, String)> pairs;
}

/// Items moved to the Trash, by original path.
final class TrashOp extends FileOp {
  const TrashOp(this.originals);
  final List<String> originals;
}

/// Items put back from the Trash, by the path they were restored to.
final class RestoreOp extends FileOp {
  const RestoreOp(this.restored);
  final List<String> restored;
}

/// Several steps that undo together (e.g. replace = trash old + copy new).
final class CompoundOp extends FileOp {
  const CompoundOp(this.ops);
  final List<FileOp> ops;
}

const _maxSteps = 50;

/// Undo / redo of file operations for one window (all its tabs).
/// Undoing never deletes for good: created items go to the Trash.
class FileUndoHistory extends ChangeNotifier {
  FileUndoHistory({required this._fs, required this.trashFilesDir});

  final FileSystemService _fs;
  final String trashFilesDir;
  final _undo = <FileOp>[];
  final _redo = <FileOp>[];
  bool _busy = false;

  // What was in the Trash when the current step began: putting back must
  // pick from those, not from items the same step just trashed (undoing a
  // replace trashes the new copy, then restores the old item - both with
  // the same original path).
  Set<String>? _trashBefore;

  bool get canUndo => _undo.isNotEmpty && !_busy;
  bool get canRedo => _redo.isNotEmpty && !_busy;

  void record(FileOp op) {
    if (op is CompoundOp && op.ops.isEmpty) return;
    _undo.add(op);
    if (_undo.length > _maxSteps) _undo.removeAt(0);
    _redo.clear();
    notifyListeners();
  }

  /// Returns null when there was nothing to undo.
  Future<Result<void>?> undo() => _step(_undo, _redo, _revert);

  Future<Result<void>?> redo() => _step(_redo, _undo, _apply);

  Future<Result<void>?> _step(
    List<FileOp> from,
    List<FileOp> to,
    Future<Result<void>> Function(FileOp) run,
  ) async {
    if (from.isEmpty || _busy) return null;
    _busy = true;
    final op = from.removeLast();
    notifyListeners();
    _trashBefore = await _fs.trashedNames(trashFilesDir);
    final result = await run(op);
    _trashBefore = null;
    _busy = false;
    // A step that failed (files changed meanwhile) is dropped rather than
    // retried forever.
    if (result is Ok) to.add(op);
    notifyListeners();
    return result;
  }

  Future<Result<void>> _revert(FileOp op) async => switch (op) {
    RenameOp(:final from, :final to) => _fs.moveExact(to, from),
    CreateFolderOp(:final path) => _fs.trash([path]),
    CopyOp(:final pairs) => _fs.trash([for (final (_, copy) in pairs) copy]),
    MoveOp(:final pairs) => _all([
      for (final (from, to) in pairs.reversed) () => _fs.moveExact(to, from),
    ]),
    TrashOp(:final originals) => _all([
      for (final original in originals) () => _putBack(original),
    ]),
    RestoreOp(:final restored) => _fs.trash(restored),
    CompoundOp(:final ops) => _all([
      for (final o in ops.reversed) () => _revert(o),
    ]),
  };

  Future<Result<void>> _apply(FileOp op) async => switch (op) {
    RenameOp(:final from, :final to) => _fs.moveExact(from, to),
    CreateFolderOp(:final path) => _putBack(path),
    CopyOp(:final pairs) => _all([
      for (final (source, copy) in pairs) () => _fs.copyExact(source, copy),
    ]),
    MoveOp(:final pairs) => _all([
      for (final (from, to) in pairs) () => _fs.moveExact(from, to),
    ]),
    TrashOp(:final originals) => _fs.trash(originals),
    RestoreOp(:final restored) => _all([
      for (final path in restored) () => _putBack(path),
    ]),
    CompoundOp(:final ops) => _all([for (final o in ops) () => _apply(o)]),
  };

  /// Brings [original] back from the Trash to where it was.
  Future<Result<void>> _putBack(String original) async {
    final trashed = await _fs.findInTrash(
      original,
      trashFilesDir,
      among: _trashBefore,
    );
    if (trashed == null) {
      return Err(Failure(FailureKind.notFound, p.basename(original)));
    }
    final result = await _fs.restoreFromTrash(trashed);
    return switch (result) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }

  /// Runs steps in order, stopping at the first failure.
  Future<Result<void>> _all(List<Future<Result<void>> Function()> steps) async {
    for (final step in steps) {
      if (await step() case Err(:final failure)) return Err(failure);
    }
    return const Ok(null);
  }
}
