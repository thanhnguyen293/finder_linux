import 'package:finder_linux/state/drop_rules.dart';
import 'package:finder_linux/ui/dnd/drag_auto_scroll.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DropAction decide({
    List<String>? local,
    String dir = '/dest',
    bool move = true,
    bool copy = true,
    bool ctrl = false,
    bool shift = false,
    bool trash = false,
  }) => decideDrop(
    localPaths: local,
    dir: dir,
    allowMove: move,
    allowCopy: copy,
    ctrl: ctrl,
    shift: shift,
    toTrash: trash,
  );

  test('Finder drags move; Ctrl copies', () {
    expect(decide(local: ['/src/a']), DropAction.move);
    expect(decide(local: ['/src/a'], ctrl: true), DropAction.copy);
  });

  test('files from other apps copy; Shift moves', () {
    expect(decide(), DropAction.copy);
    expect(decide(shift: true), DropAction.move);
  });

  test('respects what the source allows', () {
    expect(decide(local: ['/src/a'], move: false), DropAction.copy);
    expect(decide(copy: false), DropAction.move);
    expect(decide(move: false, copy: false), DropAction.none);
  });

  test('refuses the same folder and folders into themselves', () {
    expect(decide(local: ['/dest/a']), DropAction.none);
    expect(decide(local: ['/src/dir'], dir: '/src/dir/sub'), DropAction.none);
    expect(decide(local: ['/src/dir'], dir: '/src/dir'), DropAction.none);
    expect(canDropInto(['/src/a', '/other/b'], '/dest'), isTrue);
  });

  test('Trash takes moves only', () {
    expect(decide(local: ['/src/a'], trash: true), DropAction.move);
    expect(decide(trash: true, move: false), DropAction.none);
  });

  test('auto-scroll speeds up toward the edges and rests in the middle', () {
    expect(autoScrollStep(200, 600, 50), 0);
    expect(autoScrollStep(0, 600, 50), lessThan(-20));
    expect(autoScrollStep(40, 600, 50), inInclusiveRange(-5, -0.1));
    expect(autoScrollStep(600, 600, 50), greaterThan(20));
    expect(autoScrollStep(560, 600, 50), inInclusiveRange(0.1, 5));
    // Views too small for two bands never scroll.
    expect(autoScrollStep(10, 80, 50), 0);
  });
}
