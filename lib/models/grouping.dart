import 'package:flutter/foundation.dart';

import 'file_entry.dart';
import 'sort_spec.dart';

enum DateBucket { today, yesterday, previous7Days, previous30Days, month, year }

/// Ordered largest first, as Finder lists size groups; folders come last
/// because they have no meaningful size.
enum SizeBucket {
  atLeast1GB,
  from100MB,
  from1MB,
  from100KB,
  under100KB,
  zero,
  folders,
}

/// What a group of entries has in common. The UI turns it into a label.
sealed class GroupKey {
  const GroupKey();
}

final class KindGroup extends GroupKey {
  const KindGroup(this.kind);
  final FileKind kind;

  @override
  bool operator ==(Object other) => other is KindGroup && other.kind == kind;

  @override
  int get hashCode => kind.hashCode;
}

/// [period] is the first day of the month or year for [DateBucket.month] /
/// [DateBucket.year], null for the relative buckets.
final class DateGroup extends GroupKey {
  const DateGroup(this.bucket, [this.period]);
  final DateBucket bucket;
  final DateTime? period;

  @override
  bool operator ==(Object other) =>
      other is DateGroup && other.bucket == bucket && other.period == period;

  @override
  int get hashCode => Object.hash(bucket, period);
}

final class SizeGroup extends GroupKey {
  const SizeGroup(this.bucket);
  final SizeBucket bucket;

  @override
  bool operator ==(Object other) =>
      other is SizeGroup && other.bucket == bucket;

  @override
  int get hashCode => bucket.hashCode;
}

@immutable
class EntryGroup {
  const EntryGroup(this.key, this.entries);
  final GroupKey key;
  final List<FileEntry> entries;
}

/// Splits already-sorted [entries] into groups, keeping their order inside
/// each group. Returns an empty list for [GroupBy.none].
List<EntryGroup> groupEntries(
  List<FileEntry> entries,
  GroupBy by, {
  required DateTime now,
}) {
  if (by == GroupBy.none) return const [];
  final buckets = <GroupKey, List<FileEntry>>{};
  for (final e in entries) {
    final key = switch (by) {
      GroupBy.kind => KindGroup(e.kind),
      GroupBy.modified => _dateGroup(e.modified, now),
      GroupBy.size => SizeGroup(_sizeBucket(e)),
      GroupBy.none => throw StateError('unreachable'),
    };
    (buckets[key] ??= []).add(e);
  }
  final keys = buckets.keys.toList()..sort(_compareKeys);
  return [for (final k in keys) EntryGroup(k, buckets[k]!)];
}

DateGroup _dateGroup(DateTime modified, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(modified.year, modified.month, modified.day);
  final daysAgo = today.difference(day).inDays;
  if (daysAgo <= 0) return const DateGroup(DateBucket.today);
  if (daysAgo == 1) return const DateGroup(DateBucket.yesterday);
  if (daysAgo <= 7) return const DateGroup(DateBucket.previous7Days);
  if (daysAgo <= 30) return const DateGroup(DateBucket.previous30Days);
  if (modified.year == now.year) {
    return DateGroup(DateBucket.month, DateTime(modified.year, modified.month));
  }
  return DateGroup(DateBucket.year, DateTime(modified.year));
}

const _kb = 1000;
const _mb = 1000 * _kb;
const _gb = 1000 * _mb;

SizeBucket _sizeBucket(FileEntry e) {
  if (e.isDirectory) return SizeBucket.folders;
  final s = e.size;
  if (s == 0) return SizeBucket.zero;
  if (s < 100 * _kb) return SizeBucket.under100KB;
  if (s < _mb) return SizeBucket.from100KB;
  if (s < 100 * _mb) return SizeBucket.from1MB;
  if (s < _gb) return SizeBucket.from100MB;
  return SizeBucket.atLeast1GB;
}

int _compareKeys(GroupKey a, GroupKey b) => switch ((a, b)) {
  (KindGroup(kind: final x), KindGroup(kind: final y)) => x.index.compareTo(
    y.index,
  ),
  (SizeGroup(bucket: final x), SizeGroup(bucket: final y)) => x.index.compareTo(
    y.index,
  ),
  (
    DateGroup(bucket: final x, period: final px),
    DateGroup(bucket: final y, period: final py),
  ) =>
    x != y
        ? x.index.compareTo(y.index)
        // Newest month / year first.
        : (py ?? DateTime(0)).compareTo(px ?? DateTime(0)),
  _ => 0,
};
