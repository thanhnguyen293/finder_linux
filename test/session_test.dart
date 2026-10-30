import 'dart:io';

import 'package:finder_linux/services/session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late SessionStore store;

  setUp(() {
    root = Directory.systemTemp.createTempSync('finder_session');
    store = SessionStore(environment: {'XDG_CONFIG_HOME': root.path});
  });

  tearDown(() => root.deleteSync(recursive: true));

  test('saves and reopens tabs, skipping folders that are gone', () async {
    final a = Directory(p.join(root.path, 'a'))..createSync();
    final b = Directory(p.join(root.path, 'b'))..createSync();
    await store.save((
      tabs: [
        (path: a.path, viewMode: 'list'),
        (path: p.join(root.path, 'deleted'), viewMode: 'icons'),
        (path: b.path, viewMode: 'columns'),
      ],
      active: 2,
    ));
    final session = await store.load();
    expect(session?.tabs.map((t) => t.path), [a.path, b.path]);
    expect(session?.tabs.last.viewMode, 'columns');
    expect(session?.active, 1, reason: 'clamped to the remaining tabs');
  });

  test('no file or a corrupt file means a fresh start', () async {
    expect(await store.load(), isNull);
    store.file.parent.createSync(recursive: true);
    store.file.writeAsStringSync('{oops');
    expect(await store.load(), isNull);
  });
}
