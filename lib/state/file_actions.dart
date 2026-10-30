import 'dart:async';

import 'package:path/path.dart' as p;

import '../core/result.dart';
import '../models/file_entry.dart';
import '../models/tag_color.dart';
import '../services/adb_service.dart';
import '../services/file_system_service.dart';
import '../services/clipboard_service.dart';
import '../services/transfer_service.dart';
import 'browser_controller.dart';
import 'transfer_controller.dart';
import 'undo_history.dart';

/// File operations on the window's current folder and selection.
/// Failures are reported through [BrowserController.emit]; everything that
/// can be undone is recorded in [history].
class FileActions {
  FileActions(
    this._c, {
    required this.history,
    required this.transfers,
    required this.clipboard,
  });

  final BrowserController _c;
  final FileUndoHistory history;
  final TransferController transfers;

  /// Window clipboard, backed by the desktop clipboard.
  final ClipboardController clipboard;
  FileSystemService get _fs => _c.fs;

  Future<void> open(FileEntry entry) async {
    if (entry.isDirectory) {
      await _c.navigate(entry.path);
    } else {
      await _report(await _fs.open(entry.path));
    }
  }

  Future<void> openSelection() async {
    final selected = _c.selectedEntries;
    final folder = selected.where((e) => e.isDirectory).firstOrNull;
    if (folder != null) return _c.navigate(folder.path);
    for (final e in selected) {
      await _report(await _fs.open(e.path));
    }
  }

  Future<void> openPath(String path) => _report(_fs.open(path));

  Future<void> newFolder(String baseName) async {
    final result = await _fs.createFolder(_c.path, baseName);
    if (result case Ok(:final value)) {
      history.record(CreateFolderOp(value));
      await _c.refresh();
      _c.select(value);
      _c.beginRename(value);
    }
    await _report(result);
  }

  Future<void> commitRename(String newName) async {
    final from = _c.renamingPath;
    if (from == null) return;
    final result = await _fs.rename(from, newName);
    _c.cancelRename();
    if (result case Ok(:final value) when value != from) {
      history.record(RenameOp(from, value));
    }
    if (result case Ok(:final value)) {
      await _c.refresh();
      _c.select(value);
    }
    await _report(result);
  }

  Future<void> trashSelection() => trashPaths(_selectedPaths);

  Future<void> deletePaths(List<String> paths) async {
    if (paths.isEmpty) return;
    await _finish(await _fs.deletePermanently(paths));
  }

  Future<void> putBackSelection() async {
    final restored = <String>[];
    for (final path in _selectedPaths) {
      switch (await _fs.restoreFromTrash(path)) {
        case Ok(:final value):
          restored.add(value);
        case Err() && final failure:
          if (restored.isNotEmpty) history.record(RestoreOp(restored));
          return _finish(failure);
      }
    }
    if (restored.isNotEmpty) history.record(RestoreOp(restored));
    await _c.refresh();
  }

  /// Adds [color] to the selected items, or removes it if they all have
  /// it already, as clicking a tag in Finder's menu does.
  Future<void> toggleTag(TagColor color) async {
    final targets = _c.selectedEntries;
    if (targets.isEmpty) return;
    final remove = targets.every((e) => e.colorTags.contains(color));
    for (final e in targets) {
      final result = await _fs.setTags(
        e.path,
        withTag(e.tags, color, remove: remove),
      );
      if (result case Err(:final failure)) {
        _c.emit(FailureNotice(failure));
        break;
      }
    }
    await _c.refresh();
  }

  Future<void> emptyTrash() => _finish(_fs.emptyTrash());

  Future<void> copy() => _putOnClipboard(cut: false);
  Future<void> cut() => _putOnClipboard(cut: true);

  Future<void> paste({
    required String copySuffix,
    required ConflictResolver resolve,
  }) async {
    if (_c.isTrash) return;
    // Whatever is on the desktop clipboard: this window, another Finder
    // window, or Nautilus.
    final clip = await clipboard.read();
    if (clip == null) return;
    final ok = await _transfer(
      clip.paths,
      _c.path,
      move: clip.cut,
      copySuffix: copySuffix,
      resolve: resolve,
    );
    // A cut is consumed once pasted, like Finder's "Move Item Here".
    if (ok && clip.cut) await clipboard.consumeCut();
  }

  Future<void> duplicate({required String copySuffix}) async {
    final paths = _selectedPaths;
    if (paths.isEmpty) return;
    // Copies into the same folder always get a fresh "copy" name.
    await _transfer(
      paths,
      _c.path,
      move: false,
      copySuffix: copySuffix,
      resolve: (_, _, _) async =>
          (choice: ConflictChoice.keepBoth, applyToAll: true),
    );
  }

  /// Drag and drop: moves (or with [copy], copies) [paths] into [destDir].
  Future<void> dropInto(
    List<String> paths,
    String destDir, {
    required bool copy,
    required String copySuffix,
    required ConflictResolver resolve,
  }) => _transfer(
    paths,
    destDir,
    move: !copy,
    copySuffix: copySuffix,
    resolve: resolve,
  );

  /// Copies the selection to the device at [deviceRoot], each item into
  /// the folder [sendTargetFor] picks (photos where the gallery finds them).
  Future<void> sendSelectionToDevice(
    String deviceRoot,
    String deviceName, {
    required String copySuffix,
    required ConflictResolver resolve,
  }) async {
    final byFolder = <String, List<String>>{};
    for (final e in _c.selectedEntries) {
      (byFolder[sendTargetFor(e, deviceRoot)] ??= []).add(e.path);
    }
    var sent = 0;
    for (final MapEntry(key: folder, value: paths) in byFolder.entries) {
      final ok = await _transfer(
        paths,
        folder,
        move: false,
        copySuffix: copySuffix,
        resolve: resolve,
      );
      if (!ok) return;
      sent += paths.length;
    }
    if (sent > 0) _c.emit(SentToDeviceNotice(sent, deviceName));
  }

  /// Moves [paths] to the Trash (Delete key, dropping on the Trash place).
  Future<void> trashPaths(List<String> paths) async {
    if (paths.isEmpty) return;
    final result = await _fs.trash(paths);
    if (result is Ok) {
      history.record(TrashOp(paths));
      _c.emit(TrashedNotice(paths.length));
    }
    await _finish(result);
  }

  Future<void> undo() async {
    await _report(await history.undo() ?? const Ok(null));
    await _c.refresh();
  }

  Future<void> redo() async {
    await _report(await history.redo() ?? const Ok(null));
    await _c.refresh();
  }

  /// Copies or moves in the background (progress panel), asking about name
  /// conflicts first; records the undo step and selects what arrived.
  /// Returns whether everything finished.
  Future<bool> _transfer(
    List<String> paths,
    String destDir, {
    required bool move,
    required String copySuffix,
    required ConflictResolver resolve,
  }) async {
    final result = await transfers.run(
      sources: paths,
      destDir: destDir,
      move: move,
      copySuffix: copySuffix,
      resolve: resolve,
    );
    if (result case Err(:final failure)) {
      _c.emit(FailureNotice(failure));
      return false;
    }
    final outcome = (result as Ok<TransferOutcome?>).value;
    if (outcome == null) return false;
    history.record(
      CompoundOp([
        if (outcome.replaced.isNotEmpty) TrashOp(outcome.replaced),
        if (outcome.done.isNotEmpty)
          move ? MoveOp(outcome.done) : CopyOp(outcome.done),
      ]),
    );
    await _c.refresh();
    if (destDir == _c.path) {
      for (final (i, (_, dest)) in outcome.done.indexed) {
        _c.select(dest, toggle: i > 0);
      }
    }
    if (outcome.failure case final failure?) _c.emit(FailureNotice(failure));
    return outcome.failure == null && !outcome.cancelled;
  }

  Future<void> eject(String mountPoint) async {
    if (p.isWithin(mountPoint, _c.path) || _c.path == mountPoint) {
      await _c.navigate(_c.fs.isDirectory('/media') ? '/media' : '/');
    }
    await _report(await _fs.eject(mountPoint));
  }

  List<String> get _selectedPaths =>
      _c.selectedEntries.map((e) => e.path).toList();

  Future<void> _putOnClipboard({required bool cut}) async {
    final paths = _selectedPaths;
    if (paths.isNotEmpty) await clipboard.put((paths: paths, cut: cut));
  }

  Future<void> _finish(FutureOr<Result<void>> pending) async {
    await _report(await pending);
    await _c.refresh();
  }

  Future<void> _report(FutureOr<Result<Object?>> pending) async {
    if (await pending case Err(:final failure)) _c.emit(FailureNotice(failure));
  }
}
