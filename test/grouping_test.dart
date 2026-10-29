import 'package:finder_linux/models/file_entry.dart';
import 'package:finder_linux/models/grouping.dart';
import 'package:finder_linux/models/sort_spec.dart';
import 'package:flutter_test/flutter_test.dart';

final now = DateTime(2026, 10, 29, 15);

FileEntry entry(String name, {bool dir = false, int size = 1, DateTime? at}) =>
    FileEntry(
      path: '/x/$name',
      isDirectory: dir,
      size: size,
      modified: at ?? now,
      mode: 0x1a4,
    );

void main() {
  test('none returns no groups', () {
    expect(groupEntries([entry('a')], GroupBy.none, now: now), isEmpty);
  });

  test('kind groups follow kind order and keep item order', () {
    final groups = groupEntries(
      [
        entry('b.png'),
        entry('Docs', dir: true),
        entry('a.png'),
        entry('x.zzz'),
      ],
      GroupBy.kind,
      now: now,
    );
    expect(groups.map((g) => g.key), [
      const KindGroup(FileKind.folder),
      const KindGroup(FileKind.image),
      const KindGroup(FileKind.other),
    ]);
    expect(groups[1].entries.map((e) => e.name), ['b.png', 'a.png']);
  });

  test('date buckets: relative days, then months this year, then years', () {
    final groups = groupEntries(
      [
        entry('2024', at: DateTime(2024, 3, 1)),
        entry('march', at: DateTime(2026, 3, 9)),
        entry('week', at: DateTime(2026, 10, 25)),
        entry('today', at: DateTime(2026, 10, 29, 8)),
        entry('month', at: DateTime(2026, 10, 10)),
        entry('yesterday', at: DateTime(2026, 10, 28, 23)),
        entry('june', at: DateTime(2026, 6, 1)),
      ],
      GroupBy.modified,
      now: now,
    );
    expect(groups.map((g) => g.entries.single.name), [
      'today',
      'yesterday',
      'week',
      'month',
      'june',
      'march',
      '2024',
    ]);
    expect(groups[4].key, DateGroup(DateBucket.month, DateTime(2026, 6)));
    expect(groups.last.key, DateGroup(DateBucket.year, DateTime(2024)));
  });

  test('size buckets go largest first with folders last', () {
    final groups = groupEntries(
      [
        entry('dir', dir: true),
        entry('empty', size: 0),
        entry('small', size: 5000),
        entry('big', size: 2000000000),
        entry('mid', size: 5000000),
      ],
      GroupBy.size,
      now: now,
    );
    expect(groups.map((g) => (g.key as SizeGroup).bucket), [
      SizeBucket.atLeast1GB,
      SizeBucket.from1MB,
      SizeBucket.under100KB,
      SizeBucket.zero,
      SizeBucket.folders,
    ]);
  });
}
