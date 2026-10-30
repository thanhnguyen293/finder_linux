import 'dart:async';
import 'dart:io';

import 'package:finder_linux/services/file_system_service.dart';
import 'package:finder_linux/services/search_service.dart';
import 'package:finder_linux/state/browser_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  const searcher = SearchService();

  setUp(() async {
    root = await Directory.systemTemp.createTemp('finder_search');
    await Directory(p.join(root.path, 'Docs', 'Deep')).create(recursive: true);
    await Directory(p.join(root.path, '.cache')).create();
    await File(
      p.join(root.path, 'Docs', 'Deep', 'Report.txt'),
    ).writeAsString('quarterly numbers');
    await File(p.join(root.path, 'notes.md')).writeAsString('see report');
    await File(p.join(root.path, '.cache', 'report.bin')).writeAsString('x');
    await File(p.join(root.path, 'star*.txt')).writeAsString('');
    await File(p.join(root.path, 'starry.txt')).writeAsString('');
  });

  tearDown(() => root.delete(recursive: true));

  String at(String rel) => p.join(root.path, rel);

  Future<Set<String>> run(
    String q, {
    bool contents = false,
    bool hidden = false,
  }) async =>
      (await searcher
              .search(root.path, q, contents: contents, includeHidden: hidden)
              .toList())
          .toSet();

  group('SearchService', () {
    test(
      'finds names in subfolders, case-insensitively, skipping hidden',
      () async {
        expect(await run('report'), {at('Docs/Deep/Report.txt')});
        expect(await run('report', hidden: true), {
          at('Docs/Deep/Report.txt'),
          at('.cache/report.bin'),
        });
      },
    );

    test('contents search adds files whose text matches', () async {
      expect(await run('report', contents: true), {
        at('Docs/Deep/Report.txt'),
        at('notes.md'),
      });
      expect(await run('QUARTERLY', contents: true), {
        at('Docs/Deep/Report.txt'),
      });
    });

    test('glob characters in the query match literally', () async {
      expect(await run('star*'), {at('star*.txt')});
    });

    test('an empty query finds nothing', () async {
      expect(await run('  '), isEmpty);
    });
  });

  group('BrowserController tree search', () {
    late BrowserController c;

    setUp(() async {
      c = BrowserController(
        fs: const FileSystemService(),
        trashDir: '/nonexistent/trash',
        initialPath: root.path,
      );
      await c.start();
    });

    tearDown(() => c.dispose());

    Future<void> settled() async {
      final done = Completer<void>();
      void check() {
        if (!c.searching && !done.isCompleted) done.complete();
      }

      c.addListener(check);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      check();
      await done.future.timeout(const Duration(seconds: 5));
      c.removeListener(check);
    }

    test('shows matches from subfolders, then this folder only', () async {
      c.setQuery('report');
      // Before the search answers, this folder is filtered by name.
      expect(c.entries, isEmpty);
      await settled();
      expect(c.entries.map((e) => e.path), [at('Docs/Deep/Report.txt')]);

      c.setSearchScope(SearchScope.thisFolder);
      expect(c.entries, isEmpty);
      c.setQuery('notes');
      expect(c.entries.map((e) => e.name), ['notes.md']);
    });

    test('contents search and navigation reset', () async {
      c.setSearchContents(true);
      c.setQuery('report');
      await settled();
      expect(c.entries.map((e) => e.name).toSet(), {'Report.txt', 'notes.md'});
      await c.navigate(at('Docs'));
      expect(c.query, isEmpty);
      expect(c.searchesTree, isFalse);
      expect(c.entries.map((e) => e.name), ['Deep']);
    });
  });
}
