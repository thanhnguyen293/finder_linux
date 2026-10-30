import 'dart:io';

import 'package:finder_linux/core/result.dart';
import 'package:finder_linux/services/clipboard_service.dart';
import 'package:finder_linux/services/file_system_service.dart';
import 'package:finder_linux/services/transfer_service.dart';
import 'package:finder_linux/state/browser_controller.dart';
import 'package:finder_linux/state/file_actions.dart';
import 'package:finder_linux/state/transfer_controller.dart';
import 'package:finder_linux/state/undo_history.dart';
import 'package:path/path.dart' as p;

/// A FileSystemService whose Trash is a folder in the test's temp dir,
/// laid out like the freedesktop Trash (files/ + info/*.trashinfo), so
/// trashing and restoring can be tested without touching the real Trash.
class FakeTrashFs extends FileSystemService {
  FakeTrashFs(this.trashFilesDir) {
    Directory(trashFilesDir).createSync(recursive: true);
    Directory(p.join(p.dirname(trashFilesDir), 'info')).createSync();
  }

  final String trashFilesDir;
  var _stamp = 0;

  @override
  Future<Result<void>> trash(List<String> paths) async {
    for (final path in paths) {
      final dest = uniqueChildPath(trashFilesDir, p.basename(path));
      final name = p.basename(dest);
      await FileSystemEntity.isDirectory(path)
          ? Directory(path).rename(dest)
          : File(path).rename(dest);
      // Increasing dates so "most recent" is well defined within a test.
      final date = '2026-01-01T00:00:${(_stamp++).toString().padLeft(2, '0')}';
      File(
        p.join(p.dirname(trashFilesDir), 'info', '$name.trashinfo'),
      ).writeAsStringSync(
        '[Trash Info]\nPath=${Uri.encodeFull(path)}\nDeletionDate=$date\n',
      );
    }
    return const Ok(null);
  }

  @override
  Future<int?> freeSpace(String path) async => null;
}

Future<ConflictAnswer> keepBoth(String _, String _, int _) async =>
    (choice: ConflictChoice.keepBoth, applyToAll: true);

/// FileActions wired the way a window wires them.
FileActions actionsFor(
  BrowserController c,
  FileSystemService fs,
  String trash, {
  ClipboardController? clipboard,
}) => FileActions(
  c,
  history: FileUndoHistory(fs: fs, trashFilesDir: trash),
  transfers: TransferController(TransferService(fs)),
  clipboard: clipboard ?? ClipboardController(MemoryFileClipboard()),
);
