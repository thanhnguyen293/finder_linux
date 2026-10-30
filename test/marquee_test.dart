import 'dart:ui';

import 'package:finder_linux/ui/views/marquee.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('grid: tiles the rectangle touches, across groups', () {
    // Two columns of 100 × 120 cells from (10, 10); the second group
    // starts below a 30 px header.
    Set<String> hits(Rect r) => gridHits(
      r,
      sections: [
        (header: true, paths: ['a', 'b', 'c']),
        (header: true, paths: ['d']),
      ],
      columns: 2,
      cellWidth: 100,
      tileHeight: 120,
      padding: 10,
      headerHeight: 30,
    ).toSet();
    // First row of group one: y 40..160.
    expect(hits(const Rect.fromLTWH(20, 50, 10, 10)), {'a'});
    expect(hits(const Rect.fromLTWH(20, 50, 150, 150)), {'a', 'b', 'c'});
    // Group two's header ends at 280 + 30.
    expect(hits(const Rect.fromLTWH(20, 320, 5, 5)), {'d'});
    // The gap around a tile selects nothing.
    expect(hits(const Rect.fromLTWH(108, 50, 4, 4)), isEmpty);
  });

  test('list: rows overlapping vertically, skipping headers', () {
    Set<String> hits(Rect r) =>
        listHits(r, rows: ['a', null, 'b', 'c'], rowHeight: 24).toSet();
    expect(hits(const Rect.fromLTRB(0, 5, 10, 30)), {'a'});
    expect(hits(const Rect.fromLTRB(500, 10, 600, 60)), {'a', 'b'});
    expect(hits(const Rect.fromLTRB(0, 200, 10, 210)), isEmpty);
  });
}
