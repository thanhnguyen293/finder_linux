import 'dart:io';

import 'package:finder_linux/core/result.dart';
import 'package:finder_linux/services/transfer_service.dart';
import 'package:finder_linux/state/browser_controller.dart';
import 'package:finder_linux/state/file_actions.dart';
import 'package:finder_linux/state/undo_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'support/fake_trash.dart';

void main() {
  late Directory root;
  late FakeTrashFs fs;
  late TransferService transfers;

  String at(String name) => p.join(root.path, name);

  setUp(() {
    root = Directory.systemTemp.createTempSync('finder_transfer');
    fs = FakeTrashFs(p.join(root.path, '.trash', 'files'));
    transfers = TransferService(fs);
    Directory(at('src/sub')).createSync(recursive: true);
    Directory(at('dest')).createSync();
    File(at('src/a.txt')).writeAsStringSync('A' * 300000);
    File(at('src/sub/b.txt')).writeAsStringSync('B' * 200000);
  });

  tearDown(() => root.deleteSync(recursive: true));

  ConflictResolver always(ConflictChoice choice, {bool all = false}) =>
      (_, _, _) async => (choice: choice, applyToAll: all);

  Future<TransferOutcome> run(
    List<String> sources,
    String dest, {
    bool move = false,
    ConflictResolver? resolve,
    List<TransferProgress>? progress,
    bool Function()? cancel,
  }) async {
    final plan = await transfers.plan(
      sources: sources,
      destDir: dest,
      move: move,
      copySuffix: 'copy',
      resolve: resolve ?? always(ConflictChoice.cancel),
    );
    final value = (plan as Ok<TransferPlan?>).value;
    if (value == null) return const TransferOutcome(cancelled: true);
    return transfers.execute(
      value,
      onProgress: (p) => progress?.add(p),
      isCancelled: cancel ?? () => false,
    );
  }

  group('TransferService', () {
    test('copies folders recursively and reports byte progress', () async {
      final progress = <TransferProgress>[];
      final out = await run([at('src')], at('dest'), progress: progress);
      expect(out.done, [(at('src'), at('dest/src'))]);
      expect(File(at('dest/src/sub/b.txt')).lengthSync(), 200000);
      expect(progress.last.totalBytes, 500000);
      expect(progress.last.doneBytes, 500000);
      expect(progress.last.fraction, 1);
    });

    test('copies keep executable permissions', () async {
      final script = File(at('src/run.sh'))..writeAsStringSync('#!/bin/sh');
      await Process.run('chmod', ['755', script.path]);
      await run([script.path], at('dest'));
      expect(File(at('dest/run.sh')).statSync().mode & 0x1ff, 0x1ed);
    });

    test('conflicts: keep both, skip, replace (old one to Trash)', () async {
      File(at('dest/a.txt')).writeAsStringSync('old');
      var out = await run(
        [at('src/a.txt')],
        at('dest'),
        resolve: always(ConflictChoice.keepBoth),
      );
      expect(out.done.single.$2, at('dest/a 2.txt'));

      out = await run(
        [at('src/a.txt')],
        at('dest'),
        resolve: always(ConflictChoice.skip),
      );
      expect(out.done, isEmpty);

      out = await run(
        [at('src/a.txt')],
        at('dest'),
        resolve: always(ConflictChoice.replace),
      );
      expect(out.replaced, [at('dest/a.txt')]);
      expect(File(at('dest/a.txt')).lengthSync(), 300000);
      expect(File(p.join(fs.trashFilesDir, 'a.txt')).readAsStringSync(), 'old');
    });

    test('asks once when "apply to all" is ticked; cancel stops', () async {
      File(at('dest/a.txt')).writeAsStringSync('x');
      Directory(at('dest/sub')).createSync();
      var asked = 0;
      final out = await run(
        [at('src/a.txt'), at('src/sub')],
        at('dest'),
        resolve: (_, _, remaining) async {
          asked++;
          expect(remaining, 1);
          return (choice: ConflictChoice.skip, applyToAll: true);
        },
      );
      expect(asked, 1);
      expect(out.done, isEmpty);

      final cancelled = await run(
        [at('src/a.txt')],
        at('dest'),
        resolve: always(ConflictChoice.cancel),
      );
      expect(cancelled.cancelled, isTrue);
    });

    test('duplicates in the same folder get "copy" names', () async {
      final out = await run([at('src/a.txt')], at('src'));
      expect(out.done.single.$2, at('src/a copy.txt'));
    });

    test('cancelling mid-copy removes the partial item', () async {
      var checks = 0;
      final out = await run(
        [at('src')],
        at('dest'),
        cancel: () => ++checks > 3,
      );
      expect(out.cancelled, isTrue);
      expect(Directory(at('dest/src')).existsSync(), isFalse);
    });

    test('moves are renames and refuse a folder into itself', () async {
      final out = await run([at('src/a.txt')], at('dest'), move: true);
      expect(out.done.single, (at('src/a.txt'), at('dest/a.txt')));
      expect(File(at('src/a.txt')).existsSync(), isFalse);

      final into = await transfers.plan(
        sources: [at('src')],
        destDir: at('src/sub'),
        move: true,
        copySuffix: 'copy',
        resolve: always(ConflictChoice.cancel),
      );
      expect(into, isA<Err<TransferPlan?>>());
    });
  });

  group('undo / redo', () {
    late BrowserController c;
    late FileActions actions;
    late FileUndoHistory history;

    setUp(() async {
      c = BrowserController(
        fs: fs,
        trashDir: fs.trashFilesDir,
        initialPath: at('src'),
      );
      await c.start();
      actions = actionsFor(c, fs, fs.trashFilesDir);
      history = actions.history;
    });

    tearDown(() => c.dispose());

    test('rename', () async {
      c.select(at('src/a.txt'));
      c.beginRename(at('src/a.txt'));
      await actions.commitRename('renamed.txt');
      await actions.undo();
      expect(File(at('src/a.txt')).existsSync(), isTrue);
      await actions.redo();
      expect(File(at('src/renamed.txt')).existsSync(), isTrue);
    });

    test('move to Trash comes back on undo', () async {
      await actions.trashPaths([at('src/a.txt')]);
      expect(File(at('src/a.txt')).existsSync(), isFalse);
      await actions.undo();
      expect(File(at('src/a.txt')).existsSync(), isTrue);
      await actions.redo();
      expect(File(at('src/a.txt')).existsSync(), isFalse);
    });

    test('a drop-move goes back; a copy goes to the Trash', () async {
      await actions.dropInto(
        [at('src/a.txt')],
        at('dest'),
        copy: false,
        copySuffix: 'copy',
        resolve: keepBoth,
      );
      await actions.undo();
      expect(File(at('src/a.txt')).existsSync(), isTrue);
      expect(File(at('dest/a.txt')).existsSync(), isFalse);

      await actions.dropInto(
        [at('src/sub')],
        at('dest'),
        copy: true,
        copySuffix: 'copy',
        resolve: keepBoth,
      );
      expect(Directory(at('dest/sub')).existsSync(), isTrue);
      await actions.undo();
      expect(Directory(at('dest/sub')).existsSync(), isFalse);
      await actions.redo();
      expect(File(at('dest/sub/b.txt')).existsSync(), isTrue);
    });

    test('replacing restores the replaced item on undo', () async {
      File(at('dest/a.txt')).writeAsStringSync('old');
      await actions.dropInto(
        [at('src/a.txt')],
        at('dest'),
        copy: true,
        copySuffix: 'copy',
        resolve: always(ConflictChoice.replace),
      );
      expect(File(at('dest/a.txt')).lengthSync(), 300000);
      await actions.undo();
      expect(File(at('dest/a.txt')).readAsStringSync(), 'old');
    });

    test('new folder, and a new action clears redo', () async {
      await actions.newFolder('untitled folder');
      expect(Directory(at('src/untitled folder')).existsSync(), isTrue);
      await actions.undo();
      expect(Directory(at('src/untitled folder')).existsSync(), isFalse);
      expect(history.canRedo, isTrue);
      await actions.trashPaths([at('src/a.txt')]);
      expect(history.canRedo, isFalse);
    });
  });
}
