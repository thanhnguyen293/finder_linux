import 'package:flutter/foundation.dart';

import 'file_entry.dart';

enum SortField { name, modified, size, kind }

enum ViewMode { icons, list, columns }

enum GroupBy { none, kind, modified, size }

@immutable
class SortSpec {
  const SortSpec({
    this.field = SortField.name,
    this.ascending = true,
    this.foldersFirst = true,
  });

  final SortField field;
  final bool ascending;

  /// Finder's "Keep folders on top" setting.
  final bool foldersFirst;

  SortSpec copyWith({SortField? field, bool? ascending, bool? foldersFirst}) =>
      SortSpec(
        field: field ?? this.field,
        ascending: ascending ?? this.ascending,
        foldersFirst: foldersFirst ?? this.foldersFirst,
      );

  /// Selecting the active field flips direction; a new field starts ascending
  /// (except dates and sizes, where newest/largest first is the useful default).
  SortSpec toggled(SortField newField) {
    if (newField == field) return copyWith(ascending: !ascending);
    return copyWith(field: newField, ascending: defaultAscending(newField));
  }

  static bool defaultAscending(SortField field) =>
      field != SortField.modified && field != SortField.size;

  int compare(FileEntry a, FileEntry b) {
    if (foldersFirst && a.isDirectory != b.isDirectory) {
      return a.isDirectory ? -1 : 1;
    }
    final byField = switch (field) {
      SortField.name => 0,
      SortField.modified => a.modified.compareTo(b.modified),
      SortField.size => a.size.compareTo(b.size),
      SortField.kind =>
        a.kind.index.compareTo(b.kind.index) != 0
            ? a.kind.index.compareTo(b.kind.index)
            : a.extension.compareTo(b.extension),
    };
    final result = byField != 0 ? byField : naturalCompare(a.name, b.name);
    return ascending ? result : -result;
  }

  @override
  bool operator ==(Object other) =>
      other is SortSpec &&
      other.field == field &&
      other.ascending == ascending &&
      other.foldersFirst == foldersFirst;

  @override
  int get hashCode => Object.hash(field, ascending, foldersFirst);
}

final _chunk = RegExp(r'(\d+|\D+)');

/// Case-insensitive comparison that orders "file2" before "file10".
int naturalCompare(String a, String b) {
  final ca = _chunk.allMatches(a.toLowerCase()).map((m) => m[0]!).toList();
  final cb = _chunk.allMatches(b.toLowerCase()).map((m) => m[0]!).toList();
  for (var i = 0; i < ca.length && i < cb.length; i++) {
    final na = int.tryParse(ca[i]);
    final nb = int.tryParse(cb[i]);
    final c = (na != null && nb != null)
        ? na.compareTo(nb)
        : ca[i].compareTo(cb[i]);
    if (c != 0) return c;
  }
  final byLength = ca.length.compareTo(cb.length);
  return byLength != 0 ? byLength : a.compareTo(b);
}
