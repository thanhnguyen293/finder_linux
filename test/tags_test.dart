import 'dart:io';

import 'package:finder_linux/core/result.dart';
import 'package:finder_linux/models/tag_color.dart';
import 'package:finder_linux/services/file_system_service.dart';
import 'package:finder_linux/services/search_service.dart';
import 'package:finder_linux/services/transfer_service.dart';
import 'package:finder_linux/services/xattr_tags.dart';
import 'package:finder_linux/state/browser_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'support/fake_trash.dart';

void main() {
  late Directory root;
  const fs = FileSystemService();

  setUp(() async {
    root = await Directory.systemTemp.createTemp('finder_tags');
    await Directory(
      p.join(root.path, 'sub', '.hidden'),
    ).create(recursive: true);
    for (final name in ['a.txt', 'b.txt', 'sub/c.txt', 'sub/.hidden/d.txt']) {
      await File(p.join(root.path, name)).writeAsString(name);
    }
  });

  tearDown(() => root.delete(recursive: true));

  String at(String rel) => p.join(root.path, rel);

  // Some filesystems (old tmpfs) can't hold user attributes.
  bool supported() => writeTags(at('a.txt'), ['Probe']) is Ok;

  test('tag names map to colors; other tags are kept', () {
    expect(TagColor.fromTag('red'), TagColor.red);
    expect(TagColor.fromTag('Grey'), TagColor.gray);
    expect(TagColor.fromTag('Work'), isNull);
    expect(decodeTags(' Red, Work ,,'), ['Red', 'Work']);
    expect(withTag(['Work', 'red'], TagColor.red, remove: true), ['Work']);
    expect(withTag(['Work'], TagColor.blue, remove: false), ['Work', 'Blue']);
  });

  test('tags round-trip through the file attribute', () {
    if (!supported()) return markTestSkipped('no user xattrs in temp dir');
    expect(writeTags(at('a.txt'), ['Red', 'Work']), isA<Ok<void>>());
    expect(readTags(at('a.txt')), ['Red', 'Work']);
    expect(writeTags(at('a.txt'), []), isA<Ok<void>>());
    expect(readTags(at('a.txt')), isEmpty);
    // Removing tags a file never had is fine.
    expect(writeTags(at('b.txt'), []), isA<Ok<void>>());
    expect(writeTags(at('missing.txt'), ['Red']), isA<Err<void>>());
  });

  test(
    'toggling tags the selection, then untags it when all have it',
    () async {
      if (!supported()) return markTestSkipped('no user xattrs in temp dir');
      writeTags(at('a.txt'), ['Work']);
      final c = BrowserController(
        fs: fs,
        trashDir: '/nonexistent',
        initialPath: root.path,
      );
      addTearDown(c.dispose);
      await c.start();
      final actions = actionsFor(c, fs, '/nonexistent');
      c
        ..select(at('a.txt'))
        ..select(at('b.txt'), toggle: true);
      await actions.toggleTag(TagColor.green);
      expect(readTags(at('a.txt')), ['Work', 'Green']);
      expect(readTags(at('b.txt')), ['Green']);
      expect(c.entries.firstWhere((e) => e.name == 'b.txt').colorTags, [
        TagColor.green,
      ]);
      await actions.toggleTag(TagColor.green);
      expect(readTags(at('a.txt')), ['Work']);
      expect(readTags(at('b.txt')), isEmpty);
    },
  );

  test('copies keep their tags', () async {
    if (!supported()) return markTestSkipped('no user xattrs in temp dir');
    writeTags(at('sub'), ['Blue']);
    writeTags(at('sub/c.txt'), ['Red']);
    await Directory(at('dest')).create();
    final service = TransferService(fs);
    final plan = await service.plan(
      sources: [at('sub')],
      destDir: at('dest'),
      move: false,
      copySuffix: 'copy',
      resolve: keepBoth,
    );
    await service.execute(
      (plan as Ok<TransferPlan?>).value!,
      onProgress: (_) {},
      isCancelled: () => false,
    );
    expect(readTags(at('dest/sub')), ['Blue']);
    expect(readTags(at('dest/sub/c.txt')), ['Red']);
  });

  test('tag search walks subfolders, skipping hidden ones', () async {
    if (!supported()) return markTestSkipped('no user xattrs in temp dir');
    writeTags(at('a.txt'), []);
    writeTags(at('sub/c.txt'), ['red']);
    writeTags(at('sub/.hidden/d.txt'), ['Red']);
    const searcher = SearchService();
    expect(
      await searcher.tagged(root.path, 'Red', includeHidden: false).toList(),
      [at('sub/c.txt')],
    );
    expect(
      (await searcher.tagged(root.path, 'Red', includeHidden: true).toList())
          .toSet(),
      {at('sub/c.txt'), at('sub/.hidden/d.txt')},
    );
  });
}
