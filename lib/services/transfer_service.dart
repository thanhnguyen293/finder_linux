import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../core/result.dart';
import 'file_system_service.dart';
import 'xattr_tags.dart';

enum ConflictChoice { replace, keepBoth, skip, cancel }

typedef ConflictAnswer = ({ConflictChoice choice, bool applyToAll});

/// Asks what to do when [name] already exists in [destDir]; [remaining] is
/// how many more conflicts follow (for "apply to the rest").
typedef ConflictResolver =
    Future<ConflictAnswer> Function(String name, String destDir, int remaining);

/// One item to transfer: source, final destination, and whether an existing
/// item at the destination is replaced (moved to the Trash first).
typedef TransferItem = ({String source, String dest, bool replace});

typedef TransferPlan = ({List<TransferItem> items, bool move});

class TransferProgress {
  const TransferProgress({
    required this.doneBytes,
    required this.totalBytes,
    required this.doneItems,
    required this.totalItems,
    this.current,
  });

  final int doneBytes;
  final int totalBytes;
  final int doneItems;
  final int totalItems;

  /// Name of the item being transferred.
  final String? current;

  double get fraction => totalBytes == 0
      ? (totalItems == 0 ? 1 : doneItems / totalItems)
      : (doneBytes / totalBytes).clamp(0, 1);
}

class TransferOutcome {
  const TransferOutcome({
    this.done = const [],
    this.replaced = const [],
    this.cancelled = false,
    this.failure,
  });

  /// (source, destination) of every item that finished.
  final List<(String, String)> done;

  /// Existing items that were moved to the Trash to be replaced.
  final List<String> replaced;
  final bool cancelled;
  final Failure? failure;
}

class _Cancelled implements Exception {}

/// Copies and moves files with byte-level progress, cancellation and
/// name-conflict handling. Copies stream in Dart so progress is precise;
/// moves are renames when source and destination share a filesystem.
class TransferService {
  TransferService(this._fs);

  final FileSystemService _fs;

  /// Decides each item's destination, asking [resolve] about conflicts.
  /// Copies into the source's own folder get "name copy" (Duplicate), with
  /// no question. Returns null when the user cancelled.
  Future<Result<TransferPlan?>> plan({
    required List<String> sources,
    required String destDir,
    required bool move,
    required String copySuffix,
    required ConflictResolver resolve,
  }) async {
    for (final src in sources) {
      if (src == destDir || p.isWithin(src, destDir)) {
        return Err(Failure(FailureKind.invalidName, p.basename(src)));
      }
    }
    bool clashes(String src) =>
        p.dirname(src) != destDir && _exists(p.join(destDir, p.basename(src)));
    final conflicts = sources.where(clashes).length;
    var asked = 0;
    ConflictAnswer? sticky;
    final items = <TransferItem>[];
    for (final src in sources) {
      final name = p.basename(src);
      if (p.dirname(src) == destDir) {
        if (move) continue;
        items.add((
          source: src,
          dest: _fs.uniqueChildPath(destDir, name, suffix: copySuffix),
          replace: false,
        ));
        continue;
      }
      final dest = p.join(destDir, name);
      if (!_exists(dest)) {
        items.add((source: src, dest: dest, replace: false));
        continue;
      }
      asked++;
      final answer = sticky ?? await resolve(name, destDir, conflicts - asked);
      if (answer.applyToAll) sticky = answer;
      switch (answer.choice) {
        case ConflictChoice.cancel:
          return const Ok(null);
        case ConflictChoice.skip:
          break;
        case ConflictChoice.keepBoth:
          items.add((
            source: src,
            dest: _fs.uniqueChildPath(destDir, name),
            replace: false,
          ));
        case ConflictChoice.replace:
          items.add((source: src, dest: dest, replace: true));
      }
    }
    return Ok((items: items, move: move));
  }

  Future<TransferOutcome> execute(
    TransferPlan plan, {
    required void Function(TransferProgress) onProgress,
    required bool Function() isCancelled,
  }) async {
    final run = _Run(plan, onProgress, isCancelled);
    if (!plan.move) {
      for (final item in plan.items) {
        run.totalBytes += await _sizeOf(item.source);
      }
    }
    final done = <(String, String)>[];
    final replaced = <String>[];
    for (final item in plan.items) {
      if (isCancelled()) {
        return TransferOutcome(done: done, replaced: replaced, cancelled: true);
      }
      run.current = p.basename(item.source);
      run.report(force: true);
      try {
        if (item.replace) {
          if (await _fs.trash([item.dest]) case Err(:final failure)) {
            return TransferOutcome(
              done: done,
              replaced: replaced,
              failure: failure,
            );
          }
          replaced.add(item.dest);
        }
        if (plan.move) {
          await _move(item.source, item.dest, run);
        } else {
          await _copyTree(item.source, item.dest, run);
        }
        done.add((item.source, item.dest));
        run.doneItems++;
      } on _Cancelled {
        // Never leave a half-copied item behind.
        await _deleteQuietly(item.dest);
        return TransferOutcome(done: done, replaced: replaced, cancelled: true);
      } on FileSystemException catch (e) {
        if (!plan.move) await _deleteQuietly(item.dest);
        return TransferOutcome(
          done: done,
          replaced: replaced,
          failure: Failure(
            e.osError?.errorCode == 13
                ? FailureKind.permissionDenied
                : FailureKind.other,
            e.osError?.message ?? e.message,
          ),
        );
      }
    }
    run.report(force: true);
    return TransferOutcome(done: done, replaced: replaced);
  }

  /// Rename when possible; across filesystems copy, then remove the source.
  Future<void> _move(String src, String dest, _Run run) async {
    try {
      await _entity(src).rename(dest);
    } on FileSystemException catch (e) {
      const crossDevice = 18; // EXDEV
      if (e.osError?.errorCode != crossDevice) rethrow;
      run.totalBytes += await _sizeOf(src);
      await _copyTree(src, dest, run);
      await _entity(src).delete(recursive: true);
    }
  }

  Future<void> _copyTree(String src, String dest, _Run run) async {
    switch (FileSystemEntity.typeSync(src, followLinks: false)) {
      case FileSystemEntityType.link:
        await Link(dest).create(await Link(src).target());
      case FileSystemEntityType.directory:
        await Directory(dest).create();
        _copyTags(src, dest);
        await for (final child in Directory(src).list(followLinks: false)) {
          await _copyTree(
            child.path,
            p.join(dest, p.basename(child.path)),
            run,
          );
        }
      default:
        await _copyFile(src, dest, run);
    }
  }

  Future<void> _copyFile(String src, String dest, _Run run) async {
    final stat = await File(src).stat();
    final out = File(dest).openWrite();
    try {
      await for (final chunk in File(src).openRead()) {
        if (run.isCancelled()) throw _Cancelled();
        out.add(chunk);
        run.doneBytes += chunk.length;
        run.report();
      }
    } finally {
      await out.close();
    }
    await File(dest).setLastModified(stat.modified);
    _copyTags(src, dest);
    final mode = stat.mode & 0x1ff;
    // A new file already gets the usual mode from the umask; only differing
    // ones (scripts, private files) need a chmod process.
    if ((await File(dest).stat()).mode & 0x1ff != mode) {
      await Process.run('chmod', [mode.toRadixString(8), dest]);
    }
  }

  /// Color tags travel with copies, as in Finder. Best effort: a target
  /// filesystem without extended attributes just drops them.
  static void _copyTags(String src, String dest) {
    final tags = readTags(src);
    if (tags.isNotEmpty) writeTags(dest, tags);
  }

  Future<int> _sizeOf(String path) async {
    switch (FileSystemEntity.typeSync(path, followLinks: false)) {
      case FileSystemEntityType.file:
        return File(path).length();
      case FileSystemEntityType.directory:
        var total = 0;
        await for (final e in Directory(
          path,
        ).list(recursive: true, followLinks: false)) {
          if (e is File) total += await e.length();
        }
        return total;
      default:
        return 0;
    }
  }

  FileSystemEntity _entity(String path) =>
      switch (FileSystemEntity.typeSync(path, followLinks: false)) {
        FileSystemEntityType.directory => Directory(path),
        FileSystemEntityType.link => Link(path),
        _ => File(path),
      };

  Future<void> _deleteQuietly(String path) async {
    try {
      if (_exists(path)) await _entity(path).delete(recursive: true);
    } on FileSystemException {
      // Best effort.
    }
  }

  bool _exists(String path) =>
      FileSystemEntity.typeSync(path, followLinks: false) !=
      FileSystemEntityType.notFound;
}

/// Mutable counters of one transfer, reported at most every 80 ms.
class _Run {
  _Run(this.plan, this.onProgress, this.isCancelled);

  final TransferPlan plan;
  final void Function(TransferProgress) onProgress;
  final bool Function() isCancelled;
  int totalBytes = 0;
  int doneBytes = 0;
  int doneItems = 0;
  String? current;
  DateTime _last = DateTime(0);

  void report({bool force = false}) {
    final now = DateTime.now();
    if (!force && now.difference(_last) < const Duration(milliseconds: 80)) {
      return;
    }
    _last = now;
    onProgress(
      TransferProgress(
        doneBytes: doneBytes,
        totalBytes: totalBytes,
        doneItems: doneItems,
        totalItems: plan.items.length,
        current: current,
      ),
    );
  }
}
