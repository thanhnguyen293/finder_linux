import 'dart:io';

import 'package:finder_linux/services/clipboard_service.dart';
import 'package:finder_linux/services/file_system_service.dart';
import 'package:finder_linux/services/window_registry.dart';
import 'package:finder_linux/state/browser_controller.dart';
import 'package:finder_linux/services/transfer_service.dart';
import 'package:finder_linux/state/tabs_controller.dart';
import 'package:finder_linux/state/transfer_controller.dart';
import 'package:finder_linux/state/undo_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('finder_tabs');
    for (final d in ['a', 'b', 'c']) {
      Directory(p.join(root.path, d)).createSync();
    }
  });

  tearDown(() => root.deleteSync(recursive: true));

  group('TabsController', () {
    late TabsController tabs;
    String at(String name) => p.join(root.path, name);

    setUp(() {
      tabs = TabsController(
        (path) => BrowserController(
          fs: const FileSystemService(),
          trashDir: '/nonexistent',
          initialPath: path,
        ),
        history: FileUndoHistory(
          fs: const FileSystemService(),
          trashFilesDir: '/nonexistent',
        ),
        transfers: TransferController(
          TransferService(const FileSystemService()),
        ),
        clipboard: ClipboardController(MemoryFileClipboard()),
      );
    });

    tearDown(() => tabs.dispose());

    test('opens after the active tab and activates it', () {
      tabs.open(at('a'));
      tabs.open(at('b'));
      tabs.activate(0);
      tabs.open(at('c'));
      expect(tabs.tabs.map((t) => p.basename(t.browser.path)), ['a', 'c', 'b']);
      expect(tabs.activeIndex, 1);
    });

    test('background tabs keep the current one active', () {
      tabs.open(at('a'));
      tabs.open(at('b'), activate: false);
      expect(tabs.activeIndex, 0);
      expect(tabs.tabs, hasLength(2));
    });

    test('closing the active tab activates its right neighbour', () {
      tabs.open(at('a'));
      tabs.open(at('b'));
      tabs.open(at('c'));
      tabs.activate(1);
      expect(tabs.close(1), isTrue);
      expect(p.basename(tabs.active.browser.path), 'c');
      expect(tabs.close(1), isTrue);
      expect(p.basename(tabs.active.browser.path), 'a');
      expect(tabs.close(0), isFalse, reason: 'last tab closes the window');
    });

    test('cycle wraps, move keeps the active tab', () {
      tabs.open(at('a'));
      tabs.open(at('b'));
      tabs.open(at('c'));
      tabs.cycle(1);
      expect(tabs.activeIndex, 0);
      tabs.cycle(-1);
      expect(tabs.activeIndex, 2);
      tabs.move(2, 0);
      expect(p.basename(tabs.active.browser.path), 'c');
      expect(tabs.activeIndex, 0);
    });

    test('split view pairs tabs and ends when either leaves', () {
      final a = tabs.open(at('a'));
      final b = tabs.open(at('b'));
      final c = tabs.open(at('c'));
      tabs.activate(0);
      expect(tabs.splitWith(b), isTrue);
      expect(tabs.split?.left, a);
      expect(tabs.split?.right, b);
      expect(tabs.active, b, reason: 'the dragged tab gets focus');

      tabs.activate(0);
      expect(tabs.split, isNotNull, reason: 'switching sides keeps split');
      tabs.move(2, 0);
      expect(tabs.split?.right, b, reason: 'reordering keeps the pair');

      tabs.activate(tabs.tabs.indexOf(c));
      expect(tabs.split, isNull, reason: 'another tab leaves split view');

      tabs.splitWith(c);
      tabs.close(tabs.tabs.indexOf(c));
      expect(tabs.split, isNull, reason: 'closing a side leaves split');
    });

    test('splitting the active tab pairs it with a neighbour', () {
      final a = tabs.open(at('a'));
      expect(tabs.splitWith(a), isFalse, reason: 'needs two tabs');
      final b = tabs.open(at('b'));
      expect(tabs.splitWith(b), isTrue);
      expect(tabs.split?.left, a);
    });

    test('closeOthers leaves only the chosen tab', () {
      tabs.open(at('a'));
      tabs.open(at('b'));
      tabs.closeOthers(0);
      expect(tabs.tabs.single.browser.path, at('a'));
    });
  });

  group('WindowRegistry', () {
    test('merging takes the other windows\' tabs and closes them', () async {
      final runtime = p.join(root.path, 'run');
      var bClosed = false;
      final a = WindowRegistry(
        runtimeDir: runtime,
        id: 'a',
        describeTabs: () => const [],
        surrender: () {},
      );
      final b = WindowRegistry(
        runtimeDir: runtime,
        id: 'b',
        describeTabs: () => const [
          TabDescriptor(path: '/one', viewMode: 'list'),
          TabDescriptor(path: '/two', viewMode: 'icons'),
        ],
        surrender: () => bClosed = true,
      );
      await a.start();
      await b.start();
      // A window that crashed leaves a socket nobody listens on.
      File(p.join(runtime, 'finder-linux', 'dead.sock')).writeAsStringSync('');

      final merged = await a.collectOtherWindows();

      expect(merged, hasLength(1));
      expect(merged.single.map((t) => t.path), ['/one', '/two']);
      expect(merged.single.first.viewMode, 'list');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bClosed, isTrue);
      expect(
        File(p.join(runtime, 'finder-linux', 'dead.sock')).existsSync(),
        isFalse,
        reason: 'stale sockets are cleaned up',
      );
      await a.dispose();
      await b.dispose();
    });
  });
}
