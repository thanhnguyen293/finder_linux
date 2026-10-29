import 'dart:async';

import 'package:path/path.dart' as p;

import '../core/result.dart';
import '../models/file_entry.dart';
import '../services/file_system_service.dart';
import 'browser_controller.dart';

/// File operations on the window's current folder and selection.
/// Failures are reported through [BrowserController.emit].
class FileActions {
  FileActions(this._c);

  final BrowserController _c;
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
    if (result case Ok(:final value)) {
      await _c.refresh();
      _c.select(value);
    }
    await _report(result);
  }

  Future<void> trashSelection() async {
    final paths = _selectedPaths;
    if (paths.isEmpty) return;
    final result = await _fs.trash(paths);
    if (result is Ok) _c.emit(TrashedNotice(paths.length));
    await _finish(result);
  }

  Future<void> deleteSelection() async {
    final paths = _selectedPaths;
    if (paths.isEmpty) return;
    await _finish(await _fs.deletePermanently(paths));
  }

  Future<void> putBackSelection() async {
    for (final path in _selectedPaths) {
      final result = await _fs.restoreFromTrash(path);
      if (result is Err) return _finish(result);
    }
    await _c.refresh();
  }

  Future<void> emptyTrash() => _finish(_fs.emptyTrash());

  void copy() => _setClipboard(cut: false);
  void cut() => _setClipboard(cut: true);

  Future<void> paste({required String copySuffix}) async {
    final clip = _c.clipboard;
    if (clip == null || _c.isTrash) return;
    final Result<List<String>> result;
    if (clip.cut) {
      result = await _fs.moveInto(clip.paths, _c.path);
      // A cut is consumed once pasted, like Finder's "Move Item Here".
      if (result is Ok) _c.clipboard = null;
    } else {
      result = await _fs.copyInto(clip.paths, _c.path, copySuffix: copySuffix);
    }
    await _finishSelecting(result);
  }

  Future<void> duplicate({required String copySuffix}) async {
    final paths = _selectedPaths;
    if (paths.isEmpty) return;
    await _finishSelecting(
      await _fs.copyInto(paths, _c.path, copySuffix: copySuffix),
    );
  }

  /// Drag and drop: moves (or with [copy], copies) [paths] into [destDir].
  /// Name clashes in [destDir] are numbered, as with paste.
  Future<void> dropInto(
    List<String> paths,
    String destDir, {
    required bool copy,
    required String copySuffix,
  }) async {
    final result = copy
        ? await _fs.copyInto(paths, destDir, copySuffix: copySuffix)
        : await _fs.moveInto(paths, destDir);
    await _finish(result);
  }

  /// Dropping onto the Trash place.
  Future<void> trashPaths(List<String> paths) async {
    final result = await _fs.trash(paths);
    if (result is Ok) _c.emit(TrashedNotice(paths.length));
    await _finish(result);
  }

  Future<void> eject(String mountPoint) async {
    if (p.isWithin(mountPoint, _c.path) || _c.path == mountPoint) {
      await _c.navigate(_c.fs.isDirectory('/media') ? '/media' : '/');
    }
    await _report(await _fs.eject(mountPoint));
  }

  List<String> get _selectedPaths =>
      _c.selectedEntries.map((e) => e.path).toList();

  void _setClipboard({required bool cut}) {
    final paths = _selectedPaths;
    if (paths.isNotEmpty) _c.clipboard = (paths: paths, cut: cut);
  }

  Future<void> _finish(FutureOr<Result<void>> pending) async {
    await _report(await pending);
    await _c.refresh();
  }

  Future<void> _finishSelecting(Result<List<String>> result) async {
    await _c.refresh();
    if (result case Ok(:final value) when value.isNotEmpty) {
      for (final (i, path) in value.indexed) {
        _c.select(path, toggle: i > 0);
      }
    }
    await _report(result);
  }

  Future<void> _report(FutureOr<Result<Object?>> pending) async {
    if (await pending case Err(:final failure)) _c.emit(FailureNotice(failure));
  }
}
