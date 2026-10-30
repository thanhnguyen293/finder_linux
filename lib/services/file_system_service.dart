import 'dart:io';

import 'package:path/path.dart' as p;

import '../core/result.dart';
import '../models/file_entry.dart';
import 'adb_service.dart';
import 'xattr_tags.dart';

/// All disk and desktop-integration side effects. Heavy lifting is delegated
/// to coreutils/gio so behaviour matches the rest of the desktop (trash spec,
/// cross-device moves, default-app handling).
/// Command-line flag forcing a separate window (Ctrl+N, Move Tab to New
/// Window) even when "open folders in tabs" is on. The GTK runner adds it
/// to every window after the first, which alone restores the saved tabs.
const newWindowFlag = '--new-window';

class FileSystemService {
  const FileSystemService({this.adb});

  /// Android devices, browsed under [adbRoot]; none when null (tests).
  final AdbService? adb;

  Future<Result<List<FileEntry>>> list(String dir) async {
    if (isDevicePath(dir)) return _onDevice(dir, (a) => a.list(dir));
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
      tags: broken ? const [] : readTags(entity.path),
    );
  }

  Future<FileEntry?> entry(String path) async {
    if (isDevicePath(path)) return adb?.entry(path);
    if (!exists(path)) return null;
    return _entryFor(
      FileSystemEntity.isLinkSync(path) ? Link(path) : File(path),
    );
  }

  /// Replaces [path]'s tags (see `xattr_tags.dart`).
  Future<Result<void>> setTags(String path, List<String> tags) async =>
      isDevicePath(path)
      ? Err(Failure(FailureKind.other, path))
      : writeTags(path, tags);

  Future<Result<String>> createFolder(String parent, String baseName) async {
    final target = uniqueChildPath(parent, baseName);
    if (isDevicePath(target)) return _onDevice(target, (a) => a.mkdir(target));
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
    if (exists(target) && target.toLowerCase() != path.toLowerCase()) {
      return Err(Failure(FailureKind.nameTaken, name));
    }
    if (isDevicePath(path)) {
      return _onDevice(path, (a) => a.rename(path, target));
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

  /// Devices have no Trash, so their items are deleted for good.
  Future<Result<void>> trash(List<String> paths) => paths.any(isDevicePath)
      ? deletePermanently(paths)
      : _run('gio', ['trash', '--', ...paths], value: null);

  Future<Result<void>> deletePermanently(List<String> paths) =>
      paths.any(isDevicePath)
      ? _onDevice(paths.first, (a) => a.delete(paths))
      : _run('rm', ['-rf', '--', ...paths], value: null);

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

  /// Moves [from] to exactly [to] (undo / redo); refuses to overwrite.
  Future<Result<void>> moveExact(String from, String to) async {
    if (exists(to)) return Err(Failure(FailureKind.nameTaken, p.basename(to)));
    if (isDevicePath(from) || isDevicePath(to)) {
      return _onDevice(to, (a) => a.move(from, to));
    }
    return _run('mv', ['-T', '--', from, to], value: null);
  }

  /// Copies [source] to exactly [dest] (redo of a copy).
  Future<Result<void>> copyExact(String source, String dest) async {
    if (exists(dest)) {
      return Err(Failure(FailureKind.nameTaken, p.basename(dest)));
    }
    if (isDevicePath(source) || isDevicePath(dest)) {
      return _onDevice(dest, (a) => a.copy(source, dest));
    }
    return _run('cp', ['-a', '-T', '--', source, dest], value: null);
  }

  /// Names of the items currently in the Trash.
  Future<Set<String>> trashedNames(String trashFilesDir) async {
    final dir = Directory(trashFilesDir);
    if (!dir.existsSync()) return {};
    return {await for (final e in dir.list()) p.basename(e.path)};
  }

  /// The most recently trashed item that came from [original], looked up
  /// through the `.trashinfo` files of [trashFilesDir]. With [among], only
  /// those trashed names are considered.
  Future<String?> findInTrash(
    String original,
    String trashFilesDir, {
    Set<String>? among,
  }) async {
    final info = Directory(p.join(p.dirname(trashFilesDir), 'info'));
    if (!info.existsSync()) return null;
    String? best;
    var bestDate = '';
    await for (final f in info.list()) {
      if (f is! File || !f.path.endsWith('.trashinfo')) continue;
      if (among != null &&
          !among.contains(p.basenameWithoutExtension(f.path))) {
        continue;
      }
      final lines = await f.readAsLines();
      String? field(String key) => lines
          .where((l) => l.startsWith('$key='))
          .map((l) => l.substring(key.length + 1))
          .firstOrNull;
      final path = field('Path');
      if (path == null || Uri.decodeFull(path) != original) continue;
      final date = field('DeletionDate') ?? '';
      if (best == null || date.compareTo(bestDate) > 0) {
        best = p.join(trashFilesDir, p.basenameWithoutExtension(f.path));
        bestDate = date;
      }
    }
    return best;
  }

  Future<Result<void>> open(String path) => isDevicePath(path)
      ? _onDevice(path, (a) => a.open(path))
      : _run('gio', ['open', path], value: null);

  /// [path] itself, or for a device file a local copy; null if unreadable.
  Future<String?> localCopy(String path) async {
    if (!isDevicePath(path)) return path;
    return switch (await adb?.pullToTemp(path)) {
      Ok(:final value) => value,
      _ => null,
    };
  }

  Future<void> openTerminal(String dir) async {
    if (isDevicePath(dir)) return;
    await Process.start(
      'x-terminal-emulator',
      const [],
      workingDirectory: dir,
      mode: ProcessStartMode.detached,
    );
  }

  Future<Result<void>> eject(String mountPoint) async {
    final ejected = await _run('gio', ['mount', '-e', mountPoint], value: null);
    if (ejected is Ok) return ejected;
    return _run('gio', ['mount', '-u', mountPoint], value: null);
  }

  Future<int?> freeSpace(String path) async {
    if (isDevicePath(path)) return adb?.freeSpace(path);
    final r = await Process.run('df', ['-B1', '--output=avail', path]);
    if (r.exitCode != 0) return null;
    final lines = (r.stdout as String).trim().split('\n');
    return lines.length < 2 ? null : int.tryParse(lines[1].trim());
  }

  Future<int?> directorySize(String path) async {
    if (isDevicePath(path)) return adb?.directorySize(path);
    final r = await Process.run('du', ['-sb', '--', path]);
    // du exits non-zero on unreadable children but still prints a total.
    return int.tryParse((r.stdout as String).split(RegExp(r'\s')).first);
  }

  /// Device folders aren't watched; they refresh on Reload and after
  /// this app changes them.
  Stream<FileSystemEvent> watch(String dir) =>
      isDevicePath(dir) ? const Stream.empty() : Directory(dir).watch();

  bool isDirectory(String path) => isDevicePath(path)
      ? adb?.isDirectory(path) ?? false
      : FileSystemEntity.isDirectorySync(path);

  /// First free name in [dir] following Finder's numbering:
  /// `name`, `name 2`, … or with a suffix `name copy`, `name copy 2`, …
  String uniqueChildPath(String dir, String name, {String? suffix}) {
    final ext = _splitExtension(dir, name);
    final stem = name.substring(0, name.length - ext.length);
    final base = suffix == null ? stem : '$stem $suffix';
    var candidate = p.join(dir, '$base$ext');
    for (var n = 2; exists(candidate); n++) {
      candidate = p.join(dir, '$base $n$ext');
    }
    return candidate;
  }

  String _splitExtension(String dir, String name) {
    if (name.startsWith('.') && !name.substring(1).contains('.')) return '';
    if (isDirectory(p.join(dir, name))) return '';
    return p.extension(name);
  }

  bool exists(String path) => isDevicePath(path)
      ? adb?.exists(path) ?? false
      : FileSystemEntity.typeSync(path, followLinks: false) !=
            FileSystemEntityType.notFound;

  Future<Result<T>> _onDevice<T>(
    String path,
    Future<Result<T>> Function(AdbService adb) run,
  ) => switch (adb) {
    final adb? => run(adb),
    null => Future.value(Err(Failure(FailureKind.notFound, path))),
  };

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
