import 'dart:io';

import 'package:finder_linux/core/locations.dart';
import 'package:finder_linux/models/finder_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('typed locations resolve against home and the current folder', () {
    String r(String raw) => resolveLocation(raw, home: '/h', current: '/h/a');
    expect(r('~'), '/h');
    expect(r('~/Docs/'), '/h/Docs');
    expect(r('/etc/../usr'), '/usr');
    expect(r('b'), '/h/a/b');
    expect(r('..'), '/h');
  });

  group('completion', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('finder_loc');
      for (final d in ['Documents', 'Downloads', 'Music', '.config']) {
        await Directory(p.join(root.path, d)).create();
      }
      await File(p.join(root.path, 'Mfile')).writeAsString('');
    });

    tearDown(() => root.delete(recursive: true));

    String? c(String text) =>
        completeLocation(text, home: root.path, current: root.path);

    test('a single match completes the folder', () {
      expect(c('~/Mu'), '~/Music/');
      expect(c('mu'), 'Music/');
      expect(c('${root.path}/Mu'), '${root.path}/Music/');
    });

    test('several matches complete their common prefix', () {
      expect(c('~/D'), '~/Do');
      expect(c('~/Do'), isNull);
    });

    test('hidden folders need a leading dot; files never complete', () {
      expect(c('~/c'), isNull);
      expect(c('~/.c'), '~/.config/');
      expect(c('~/Mf'), isNull);
      expect(c('~/nope/x'), isNull);
    });
  });

  test('text size steps through the offered sizes', () {
    expect(stepTextSize(13, 1), 14);
    expect(stepTextSize(14, 1), 16);
    expect(stepTextSize(16, 1), 16);
    expect(stepTextSize(11, -1), 11);
    expect(stepTextSize(15, -1), 12);
  });
}
