import 'dart:ui';

import 'package:finder_linux/ui/tabs/tab_drag.dart';
import 'package:finder_linux/ui/tabs/tab_native_drag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const strip = Rect.fromLTWH(0, 0, 1000, 36);
  const content = Rect.fromLTWH(200, 36, 800, 600);

  TabDropOutcome at(double x, double y, {int tabs = 3}) => tabDropOutcome(
    pointer: Offset(x, y),
    strip: strip,
    content: content,
    tabCount: tabs,
  );

  test('near the strip it is a reorder', () {
    expect(at(400, 20), TabDropOutcome.reorder);
    expect(at(400, 50), TabDropOutcome.reorder, reason: 'within slack');
  });

  test('right part of the content splits', () {
    expect(at(900, 300), TabDropOutcome.split);
    expect(at(200 + 800 * 0.55, 300), TabDropOutcome.split);
  });

  test('anywhere else tears the tab off', () {
    expect(at(300, 300), TabDropOutcome.newWindow, reason: 'left of content');
    expect(at(1200, 300), TabDropOutcome.newWindow, reason: 'outside');
    expect(at(400, 900), TabDropOutcome.newWindow);
  });

  test('a lone tab never splits or tears off', () {
    expect(at(900, 300, tabs: 1), TabDropOutcome.reorder);
    expect(at(400, 900, tabs: 1), TabDropOutcome.reorder);
  });

  test('a tab leaves the window at its edge, not inside it', () {
    const size = Size(1000, 700);
    expect(isAtWindowEdge(const Offset(500, 300), size), isFalse);
    expect(isAtWindowEdge(const Offset(995, 300), size), isTrue);
    expect(isAtWindowEdge(const Offset(500, 695), size), isTrue);
    expect(isAtWindowEdge(const Offset(-40, 300), size), isTrue);
  });

  test('tab payloads survive the trip between windows', () {
    const tab = (pid: 42, tab: 7, path: '/home/a b', viewMode: 'list');
    expect(tabPayloadFromJson(tabPayloadToJson(tab)), tab);
    expect(tabPayloadFromJson({'pid': '42'}), isNull);
    expect(tabPayloadFromJson(null), isNull);
  });
}
