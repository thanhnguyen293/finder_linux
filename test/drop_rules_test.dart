import 'package:finder_linux/state/drop_rules.dart';
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
}
