import 'dart:io';

import 'package:finder_linux/core/result.dart';
import 'package:finder_linux/models/grouping.dart';
import 'package:finder_linux/models/file_entry.dart';
import 'package:finder_linux/launch_target.dart';
import 'package:finder_linux/models/sort_spec.dart';
import 'package:finder_linux/services/file_system_service.dart';
import 'package:finder_linux/state/browser_controller.dart';
import 'package:finder_linux/state/file_actions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  const fs = FileSystemService();

  setUp(() async {
    root = await Directory.systemTemp.createTemp('finder_test');
    await Directory(
      p.join(root.path, 'Docs', 'Nested'),
    ).create(recursive: true);
    await File(p.join(root.path, 'b.txt')).writeAsString('b');
    await File(p.join(root.path, 'a.txt')).writeAsString('a');
    await File(p.join(root.path, '.secret')).writeAsString('s');
  });

  tearDown(() => root.delete(recursive: true));

  String at(String name) => p.join(root.path, name);

  group('FileSystemService', () {
    test('uniqueChildPath numbers names Finder-style', () async {
      expect(fs.uniqueChildPath(root.path, 'c.txt'), at('c.txt'));
      expect(fs.uniqueChildPath(root.path, 'a.txt'), at('a 2.txt'));
      expect(
        fs.uniqueChildPath(root.path, 'a.txt', suffix: 'copy'),
        at('a copy.txt'),
      );
      expect(fs.uniqueChildPath(root.path, 'Docs'), at('Docs 2'));
    });

    test('createFolder avoids collisions', () async {
      final first = await fs.createFolder(root.path, 'untitled folder');
      final second = await fs.createFolder(root.path, 'untitled folder');
      expect((first as Ok<String>).value, at('untitled folder'));
      expect((second as Ok<String>).value, at('untitled folder 2'));
    });

    test('rename rejects taken and invalid names', () async {
      final taken = await fs.rename(at('a.txt'), 'b.txt');
      expect((taken as Err).failure.kind, FailureKind.nameTaken);
      final invalid = await fs.rename(at('a.txt'), 'x/y');
      expect((invalid as Err).failure.kind, FailureKind.invalidName);
      final ok = await fs.rename(at('a.txt'), 'renamed.txt');
      expect(ok, isA<Ok<String>>());
      expect(File(at('renamed.txt')).existsSync(), isTrue);
    });

    test(
      'copy into same folder adds suffix; folders copy recursively',
      () async {
        final r = await fs.copyInto(
          [at('a.txt'), at('Docs')],
          root.path,
          copySuffix: 'copy',
        );
        expect((r as Ok<List<String>>).value, [
          at('a copy.txt'),
          at('Docs copy'),
        ]);
        expect(
          Directory(p.join(at('Docs copy'), 'Nested')).existsSync(),
          isTrue,
        );
      },
    );

    test('moving a folder into itself is refused', () async {
      final r = await fs.moveInto([at('Docs')], p.join(at('Docs'), 'Nested'));
      expect(r, isA<Err<List<String>>>());
      expect(Directory(at('Docs')).existsSync(), isTrue);
    });
  });

  group('BrowserController', () {
    late BrowserController c;

    setUp(() async {
      c = BrowserController(
        fs: fs,
        trashDir: '/nonexistent/trash',
        initialPath: root.path,
      );
      await c.start();
    });

    tearDown(() => c.dispose());

    test('lists folders first and hides dotfiles by default', () {
      expect(c.entries.map((e) => e.name), ['Docs', 'a.txt', 'b.txt']);
      c.toggleHidden();
      expect(c.entries.map((e) => e.name), contains('.secret'));
    });

    test('history: back, forward and up re-selects the child', () async {
      await c.navigate(at('Docs'));
      await c.navigate(p.join(at('Docs'), 'Nested'));
      await c.back();
      expect(c.path, at('Docs'));
      expect(c.selection, {p.join(at('Docs'), 'Nested')});
      await c.forward();
      expect(c.path, p.join(at('Docs'), 'Nested'));
      await c.up();
      await c.up();
      expect(c.path, root.path);
      expect(c.selection, {at('Docs')});
    });

    test('navigation swaps location and entries together', () async {
      final notified = <(String, List<String>)>[];
      c.addListener(
        () => notified.add((c.path, c.entries.map((e) => e.name).toList())),
      );
      final pending = c.navigate(at('Docs'));
      expect(c.path, root.path, reason: 'old folder stays until listed');
      await pending;
      // Every frame pairs a location with its own listing.
      expect(
        notified.where((n) => n.$1 == at('Docs')).map((n) => n.$2),
        everyElement(['Nested']),
      );
      expect(notified.last.$1, at('Docs'));
      expect(notified.last.$2, ['Nested']);
    });

    test('a newer navigation wins over a slower earlier one', () async {
      final first = c.navigate(at('Docs'));
      final second = c.navigate(p.join(at('Docs'), 'Nested'));
      await Future.wait([first, second]);
      expect(c.path, p.join(at('Docs'), 'Nested'));
    });

    test('search filters by name and clears on navigation', () async {
      c.setQuery('A.T');
      expect(c.entries.map((e) => e.name), ['a.txt']);
      await c.navigate(at('Docs'));
      expect(c.query, isEmpty);
    });

    test('shift selection extends from the anchor', () {
      c.select(at('Docs'));
      c.moveCursor(2, extend: true);
      expect(c.selection, {at('Docs'), at('a.txt'), at('b.txt')});
      c.moveCursor(-1);
      expect(c.selection, {at('a.txt')});
    });

    test('type-ahead and sort changes', () {
      c.selectByPrefix('b');
      expect(c.selection, {at('b.txt')});
      c.setSort(const SortSpec(ascending: false));
      expect(c.entries.map((e) => e.name), ['Docs', 'b.txt', 'a.txt']);
    });

    test('grouping reorders entries to match the on-screen order', () {
      c.setSort(const SortSpec(ascending: false));
      c.setGroupBy(GroupBy.kind);
      expect(c.groups, hasLength(2));
      expect(c.entries.map((e) => e.name), ['Docs', 'b.txt', 'a.txt']);
      c.setGroupBy(GroupBy.none);
      expect(c.groups, isEmpty);
    });

    test('Group By is a window setting kept across folders', () async {
      c.setGroupBy(GroupBy.kind);
      await c.navigate(at('Docs'));
      expect(c.groupBy, GroupBy.kind);
      expect(c.groups.single.key, const KindGroup(FileKind.folder));
      // Other folders shown alongside (column view) group the same way.
      final listing = await c.listDir(root.path);
      final groups = c.groupsFor((listing as Ok<List<FileEntry>>).value);
      expect(groups.map((g) => g.key), [
        const KindGroup(FileKind.folder),
        const KindGroup(FileKind.text),
      ]);
    });

    test(
      'column root: places start columns, deeper keeps, up resets',
      () async {
        expect(c.columnRoot, root.path);
        await c.navigate(at('Docs'), root: at('Docs'));
        expect(c.columnRoot, at('Docs'));
        await c.navigate(p.join(at('Docs'), 'Nested'));
        expect(c.columnRoot, at('Docs'), reason: 'going deeper keeps it');
        await c.up();
        await c.up();
        expect(c.path, root.path);
        expect(c.columnRoot, root.path, reason: 'above the root resets it');
      },
    );

    test('cut + paste moves items and consumes the clipboard', () async {
      final actions = FileActions(c);
      c.select(at('a.txt'));
      actions.cut();
      await c.navigate(at('Docs'));
      await actions.paste(copySuffix: 'copy');
      expect(File(p.join(at('Docs'), 'a.txt')).existsSync(), isTrue);
      expect(File(at('a.txt')).existsSync(), isFalse);
      expect(c.clipboard, isNull);
      expect(c.selection, {p.join(at('Docs'), 'a.txt')});
    });
  });

  group('resolveLaunchTarget', () {
    test('handles folders, files, file URIs and missing paths', () {
      expect(resolveLaunchTarget([], home: '/h'), ('/h', null));
      expect(resolveLaunchTarget(['--new-window', root.path], home: '/h'), (
        root.path,
        null,
      ));
      expect(resolveLaunchTarget([root.path], home: '/h'), (root.path, null));
      expect(
        resolveLaunchTarget([Uri.file(at('a.txt')).toString()], home: '/h'),
        (root.path, at('a.txt')),
      );
      expect(resolveLaunchTarget([at('missing')], home: '/h'), ('/h', null));
    });
  });
}
