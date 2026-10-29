import 'dart:io';

import 'package:path/path.dart' as p;

import '../core/result.dart';
import '../models/file_entry.dart';

/// All disk and desktop-integration side effects. Heavy lifting is delegated
/// to coreutils/gio so behaviour matches the rest of the desktop (trash spec,
/// cross-device moves, default-app handling).
/// Command-line flag forcing a separate window (Ctrl+N, Move Tab to New
/// Window) even when "open folders in tabs" is on.
const newWindowFlag = '--new-window';

class FileSystemService {
  const FileSystemService();

  Future<Result<List<FileEntry>>> list(String dir) async {
    try {
      final entities = await Directory(dir).list(followLinks: false).toList();
      final entries = await Future.wait(entities.map(_entryFor));
      return Ok(entries);
    } on FileSystemException catch (e) {
      return Err(_failureOf(e));
    }
  }

  Future<FileEntry> _entryFor(FileSystemEntity entity) async {
    // Stat through symlinks so linked folders behave like folders.
    final stat = await FileStat.stat(entity.path);
    final broken = stat.type == FileSystemEntityType.notFound;
    return FileEntry(
      path: entity.path,
      isDirectory: stat.type == FileSystemEntityType.directory,
      size: broken ? 0 : stat.size,
      modified: broken ? DateTime.fromMillisecondsSinceEpoch(0) : stat.modified,
      mode: broken ? 0 : stat.mode,
      isSymlink: entity is Link,
    );
  }

  Future<FileEntry?> entry(String path) async {
    if (!_exists(path)) return null;
    return _entryFor(
      FileSystemEntity.isLinkSync(path) ? Link(path) : File(path),
    );
  }

  Future<Result<String>> createFolder(String parent, String baseName) async {
    final target = uniqueChildPath(parent, baseName);
    try {
      await Directory(target).create();
      return Ok(target);
    } on FileSystemException catch (e) {
      return Err(_failureOf(e));
    }
  }

  Future<Result<String>> rename(String path, String newName) async {
    final name = newName.trim();
    if (name.isEmpty || name == '.' || name == '..' || name.contains('/')) {
      return const Err(Failure(FailureKind.invalidName));
    }
    final target = p.join(p.dirname(path), name);
    if (target == path) return Ok(path);
    // Allow case-only renames, which the existence check would otherwise block.
    if (_exists(target) && target.toLowerCase() != path.toLowerCase()) {
      return Err(Failure(FailureKind.nameTaken, name));
    }
    return _run('mv', ['-T', '--', path, target], value: target);
  }

  /// Copies [paths] into [destDir]. Copies within the same folder get a
  /// "copy" suffix, Finder-style.
  Future<Result<List<String>>> copyInto(
    List<String> paths,
    String destDir, {
    required String copySuffix,
  }) async {
    final created = <String>[];
    for (final src in paths) {
      if (_isSelfOrAncestor(src, destDir)) {
        return Err(Failure(FailureKind.invalidName, p.basename(src)));
      }
      final sameDir = p.dirname(src) == destDir;
      final target = uniqueChildPath(
        destDir,
        p.basename(src),
        suffix: sameDir ? copySuffix : null,
      );
      final r = await _run('cp', ['-a', '--', src, target], value: target);
      if (r is Err<String>) return Err(r.failure);
      created.add(target);
    }
    return Ok(created);
  }

  Future<Result<List<String>>> moveInto(
    List<String> paths,
    String destDir,
  ) async {
    final moved = <String>[];
    for (final src in paths) {
      if (p.dirname(src) == destDir) continue;
      if (_isSelfOrAncestor(src, destDir)) {
        return Err(Failure(FailureKind.invalidName, p.basename(src)));
      }
      final target = uniqueChildPath(destDir, p.basename(src));
      final r = await _run('mv', ['-T', '--', src, target], value: target);
      if (r is Err<String>) return Err(r.failure);
      moved.add(target);
    }
    return Ok(moved);
  }

  Future<Result<void>> trash(List<String> paths) =>
      _run('gio', ['trash', '--', ...paths], value: null);

  Future<Result<void>> deletePermanently(List<String> paths) =>
      _run('rm', ['-rf', '--', ...paths], value: null);

  Future<Result<void>> emptyTrash() =>
      _run('gio', ['trash', '--empty'], value: null);

  /// Restores an item from `Trash/files` to the location recorded in its
  /// `.trashinfo` (freedesktop trash spec).
  Future<Result<String>> restoreFromTrash(String trashedPath) async {
    final trashDir = p.dirname(p.dirname(trashedPath));
    final info = File(
      p.join(trashDir, 'info', '${p.basename(trashedPath)}.trashinfo'),
    );
    try {
      final line = (await info.readAsLines()).firstWhere(
        (l) => l.startsWith('Path='),
        orElse: () => '',
      );
      if (line.isEmpty) return Err(Failure(FailureKind.notFound, trashedPath));
      final original = Uri.decodeFull(line.substring(5));
      final parent = p.dirname(original);
      await Directory(parent).create(recursive: true);
      final target = uniqueChildPath(parent, p.basename(original));
      final r = await _run('mv', [
        '-T',
        '--',
        trashedPath,
        target,
      ], value: target);
      if (r is Ok<String>) await info.delete();
      return r;
    } on FileSystemException catch (e) {
      return Err(_failureOf(e));
    }
  }

  Future<Result<void>> open(String path) =>
      _run('gio', ['open', path], value: null);

  Future<void> openTerminal(String dir) async {
    await Process.start(
      'x-terminal-emulator',
      const [],
      workingDirectory: dir,
      mode: ProcessStartMode.detached,
    );
  }

  Future<void> openNewWindow(String dir) async {
    await Process.start(Platform.resolvedExecutable, [
      dir,
    ], mode: ProcessStartMode.detached);
  }

  Future<Result<void>> eject(String mountPoint) async {
    final ejected = await _run('gio', ['mount', '-e', mountPoint], value: null);
    if (ejected is Ok) return ejected;
    return _run('gio', ['mount', '-u', mountPoint], value: null);
  }

  Future<int?> freeSpace(String path) async {
    final r = await Process.run('df', ['-B1', '--output=avail', path]);
    if (r.exitCode != 0) return null;
    final lines = (r.stdout as String).trim().split('\n');
    return lines.length < 2 ? null : int.tryParse(lines[1].trim());
  }

  Future<int?> directorySize(String path) async {
    final r = await Process.run('du', ['-sb', '--', path]);
    // du exits non-zero on unreadable children but still prints a total.
    return int.tryParse((r.stdout as String).split(RegExp(r'\s')).first);
  }

  Stream<FileSystemEvent> watch(String dir) => Directory(dir).watch();

  bool isDirectory(String path) => FileSystemEntity.isDirectorySync(path);

  /// First free name in [dir] following Finder's numbering:
  /// `name`, `name 2`, … or with a suffix `name copy`, `name copy 2`, …
  String uniqueChildPath(String dir, String name, {String? suffix}) {
    final ext = _splitExtension(dir, name);
    final stem = name.substring(0, name.length - ext.length);
    final base = suffix == null ? stem : '$stem $suffix';
    var candidate = p.join(dir, '$base$ext');
    for (var n = 2; _exists(candidate); n++) {
      candidate = p.join(dir, '$base $n$ext');
    }
    return candidate;
  }

  String _splitExtension(String dir, String name) {
    if (name.startsWith('.') && !name.substring(1).contains('.')) return '';
    if (isDirectory(p.join(dir, name))) return '';
    return p.extension(name);
  }

  bool _exists(String path) =>
      FileSystemEntity.typeSync(path, followLinks: false) !=
      FileSystemEntityType.notFound;

  bool _isSelfOrAncestor(String src, String dest) =>
      dest == src || p.isWithin(src, dest);

  Future<Result<T>> _run<T>(
    String exe,
    List<String> args, {
    required T value,
  }) async {
    try {
      final r = await Process.run(exe, args);
      if (r.exitCode == 0) return Ok(value);
      final stderr = (r.stderr as String).trim();
      return Err(
        Failure(
          stderr.contains('Permission denied')
              ? FailureKind.permissionDenied
              : FailureKind.other,
          stderr,
        ),
      );
    } on ProcessException catch (e) {
      return Err(Failure(FailureKind.other, e.message));
    }
  }

  Failure _failureOf(FileSystemException e) => switch (e.osError?.errorCode) {
    2 => Failure(FailureKind.notFound, e.path ?? ''),
    13 => Failure(FailureKind.permissionDenied, e.path ?? ''),
    17 => Failure(FailureKind.nameTaken, p.basename(e.path ?? '')),
    _ => Failure(FailureKind.other, e.osError?.message ?? e.message),
  };
}
