import 'dart:io';

import 'package:finder_linux/services/file_system_service.dart';
import 'package:finder_linux/services/window_registry.dart';
import 'package:finder_linux/state/browser_controller.dart';
import 'package:finder_linux/state/tabs_controller.dart';
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

  group('open folders in tabs', () {
    test('a new launch hands its folder to an open window', () async {
      final runtime = p.join(root.path, 'run2');
      String? opened;
      String? selected;
      final window = WindowRegistry(
        runtimeDir: runtime,
        id: 'w',
        describeTabs: () => const [],
        surrender: () {},
        openInTab: (path, select) {
          opened = path;
          selected = select;
        },
      );
      expect(
        await WindowRegistry.sendOpen(runtimeDir: runtime, path: '/x'),
        isFalse,
        reason: 'no window yet: the launch opens its own',
      );
      await window.start();
      final handed = await WindowRegistry.sendOpen(
        runtimeDir: runtime,
        path: '/srv/data',
        select: '/srv/data/a.txt',
      );
      expect(handed, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(opened, '/srv/data');
      expect(selected, '/srv/data/a.txt');
      await window.dispose();
    });
  });
}
