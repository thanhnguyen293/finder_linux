import 'dart:async';
import 'dart:io';

import 'package:finder_linux/core/result.dart';
import 'package:finder_linux/main.dart';
import 'package:finder_linux/ui/tabs/tab_strip.dart';
import 'package:finder_linux/ui/tab_pane.dart';
import 'package:finder_linux/ui/tabs/tab_drag_ghost.dart';
import 'package:finder_linux/ui/widgets/bottom_bars.dart';
import 'package:finder_linux/ui/widgets/path_bar.dart';
import 'package:finder_linux/ui/views/view_common.dart';
import 'package:finder_linux/ui/finder_scope.dart';
import 'package:finder_linux/ui/content_area.dart';
import 'package:finder_linux/ui/settings/settings_controls.dart';
import 'package:finder_linux/models/place.dart';
import 'package:finder_linux/services/file_system_service.dart';
import 'package:finder_linux/services/places_service.dart';
import 'package:finder_linux/services/settings_store.dart';
import 'package:finder_linux/state/settings_controller.dart';
import 'package:finder_linux/models/finder_settings.dart';
import 'package:finder_linux/models/sort_spec.dart';
import 'package:finder_linux/ui/views/column_preview_pane.dart';
import 'package:finder_linux/ui/widgets/rename_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// `df` runs through Process.run, which never completes inside the widget
/// test's fake-async zone and would leave a timer pending.
class _NoDiskStatsFs extends FileSystemService {
  const _NoDiskStatsFs();

  @override
  Future<int?> freeSpace(String path) async => null;

  // `mv` can't finish inside the fake-async zone; a rename does the same
  // for these same-filesystem test moves.

  @override
  Future<Result<List<String>>> moveInto(List<String> paths, String dest) async {
    final moved = [
      for (final src in paths)
        File(src).renameSync(p.join(dest, p.basename(src))).path,
    ];
    return Ok(moved);
  }
}

void main() {
  late Directory root;

  /// Real file IO started from the fake-async test zone only makes progress
  /// while real time passes, so alternate real waits with frame pumps.
  Future<void> settleIo(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await tester.pump();
    }
  }

  Future<void> ctrl(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(key);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
  }

  setUp(() async {
    root = Directory.systemTemp.createTempSync('finder_ui');
    Directory(p.join(root.path, 'Docs', 'Nested')).createSync(recursive: true);
    File(p.join(root.path, 'a.txt')).writeAsStringSync('hello');
    File(p.join(root.path, '.hidden')).writeAsStringSync('');
  });

  tearDown(() => root.deleteSync(recursive: true));

  testWidgets('renders icon, list and column views and renames inline', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      FinderApp(
        places: PlacesService(
          environment: {'HOME': root.path, 'USER': 'tester'},
        ),
        settings: SettingsController(
          SettingsStore(environment: {'XDG_CONFIG_HOME': root.path}),
          const FinderSettings(),
        ),
        initialPath: root.path,
        fs: const _NoDiskStatsFs(),
        nativeDragAndDrop: false,
      ),
    );
    await settleIo(tester);
    expect(find.text('a.txt'), findsOneWidget);
    expect(find.text('Docs'), findsWidgets);
    expect(find.text('2 items'), findsOneWidget);

    await ctrl(tester, LogicalKeyboardKey.digit2);
    expect(find.text('Date Modified'), findsOneWidget);
    expect(find.text('Plain Text'), findsOneWidget);

    await ctrl(tester, LogicalKeyboardKey.digit3);
    await tester.tap(find.text('Docs').last);
    await settleIo(tester);
    expect(
      find.text('Nested'),
      findsOneWidget,
      reason: 'selected folder shows its contents',
    );

    await tester.tap(find.text('a.txt'));
    await tester.pump();
    expect(
      tester.getRect(find.byType(ColumnPreviewPane)).right,
      closeTo(1200, 1),
      reason: 'preview fills the space right of the columns',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pump();
    await tester.pump();
    final field = find.descendant(
      of: find.byType(RenameField),
      matching: find.byType(TextField),
    );
    expect(field, findsOneWidget);
    await tester.enterText(field, 'notes.txt');
    // `mv` runs through Process.run, which only completes in the real zone.
    await tester.runAsync(() async {
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await settleIo(tester);
    expect(File(p.join(root.path, 'notes.txt')).existsSync(), isTrue);
    expect(
      find.text('notes.txt'),
      findsWidgets,
      reason: 'row, preview and path bar',
    );

    // Dispose the window so its polling timer and directory watcher stop.
    await tester.pumpWidget(const SizedBox());
    await settleIo(tester);
  });

  testWidgets('toolbar buttons respond without a double-click delay', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      FinderApp(
        places: PlacesService(
          environment: {'HOME': root.path, 'USER': 'tester'},
        ),
        settings: SettingsController(
          SettingsStore(environment: {'XDG_CONFIG_HOME': root.path}),
          const FinderSettings(),
        ),
        initialPath: root.path,
        fs: const _NoDiskStatsFs(),
        nativeDragAndDrop: false,
      ),
    );
    await settleIo(tester);

    await tester.tap(find.byTooltip('View as List'));
    // No time advances here: a double-tap recognizer above the button would
    // hold the tap for kDoubleTapTimeout (300 ms).
    await tester.pump();
    expect(find.text('Date Modified'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await settleIo(tester);
  });

  testWidgets('empty toolbar space drags the window; buttons stay centred', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('finder/window'),
      (call) async {
        calls.add(call.method);
        return null;
      },
    );
    await tester.pumpWidget(
      FinderApp(
        places: PlacesService(
          environment: {'HOME': root.path, 'USER': 'tester'},
        ),
        settings: SettingsController(
          SettingsStore(environment: {'XDG_CONFIG_HOME': root.path}),
          const FinderSettings(),
        ),
        initialPath: root.path,
        fs: const _NoDiskStatsFs(),
        nativeDragAndDrop: false,
      ),
    );
    await settleIo(tester);

    // The toolbar sits under the 36px tab strip.
    final back = tester.getRect(find.byTooltip('Back'));
    expect(back.center.dy, closeTo(36 + 26, 1), reason: 'centred in toolbar');

    for (final spot in [const Offset(600, 62), const Offset(900, 18)]) {
      calls.clear();
      await tester.dragFrom(spot, const Offset(80, 20));
      expect(calls, contains('startDrag'), reason: 'drag from $spot');
      await tester.pump(kDoubleTapTimeout);
    }

    await tester.pumpWidget(const SizedBox());
    await settleIo(tester);
  });

  testWidgets('settings apply to the open window and are saved', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = SettingsStore(environment: {'XDG_CONFIG_HOME': root.path});
    final settings = SettingsController(store, const FinderSettings());
    await tester.pumpWidget(
      FinderApp(
        places: PlacesService(
          environment: {'HOME': root.path, 'USER': 'tester'},
        ),
        settings: settings,
        initialPath: root.path,
        fs: const _NoDiskStatsFs(),
        nativeDragAndDrop: false,
      ),
    );
    await settleIo(tester);
    expect(find.text('Trash'), findsOneWidget);

    await ctrl(tester, LogicalKeyboardKey.comma);
    await tester.pumpAndSettle();
    expect(find.text('Finder Settings'), findsNothing);
    expect(find.text('General'), findsWidgets);

    // Sidebar tab: switch Trash off.
    await tester.tap(find.text('Sidebar'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.widgetWithText(CheckRow, 'Trash'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    expect(settings.value.hiddenPlaces, contains(PlaceKind.trash));

    // Advanced tab: show hidden files reaches the open window.
    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.widgetWithText(CheckRow, 'Show hidden files'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Trash'), findsNothing, reason: 'hidden from sidebar');
    expect(find.text('.hidden'), findsOneWidget);

    final saved = await tester.runAsync(store.load);
    expect(saved?.showHidden, isTrue);
    expect(saved?.hiddenPlaces, contains(PlaceKind.trash));

    await tester.pumpWidget(const SizedBox());
    await settleIo(tester);
  });

  testWidgets('tabs: open, switch, close; each tab keeps its folder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('finder/window'),
      (call) async {
        calls.add(call.method);
        return null;
      },
    );
    await tester.pumpWidget(
      FinderApp(
        places: PlacesService(
          environment: {'HOME': root.path, 'USER': 'tester'},
        ),
        settings: SettingsController(
          SettingsStore(environment: {'XDG_CONFIG_HOME': root.path}),
          const FinderSettings(),
        ),
        initialPath: root.path,
        fs: const _NoDiskStatsFs(),
        nativeDragAndDrop: false,
      ),
    );
    await settleIo(tester);

    await ctrl(tester, LogicalKeyboardKey.keyT);
    await settleIo(tester);
    expect(find.byTooltip('Close Tab'), findsWidgets);

    // Open Docs in the new tab, then go back to the first tab.
    await tester.tap(find.text('Docs').last);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await settleIo(tester);
    expect(find.text('Nested'), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await settleIo(tester);
    expect(find.text('a.txt'), findsOneWidget, reason: 'first tab unchanged');
    expect(find.text('Nested'), findsNothing);

    await ctrl(tester, LogicalKeyboardKey.keyW);
    await settleIo(tester);
    expect(find.text('Nested'), findsOneWidget, reason: 'Docs tab remains');
    expect(calls, isNot(contains('close')));

    await ctrl(tester, LogicalKeyboardKey.keyW);
    await tester.pump();
    expect(calls, contains('close'), reason: 'last tab closes the window');

    await tester.pumpWidget(const SizedBox());
    await settleIo(tester);
  });

  testWidgets('clicking tabs with a mouse; settings window keeps its size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('finder/window'),
      (call) async => null,
    );
    await tester.pumpWidget(
      FinderApp(
        places: PlacesService(
          environment: {'HOME': root.path, 'USER': 'tester'},
        ),
        settings: SettingsController(
          SettingsStore(environment: {'XDG_CONFIG_HOME': root.path}),
          const FinderSettings(),
        ),
        initialPath: root.path,
        fs: const _NoDiskStatsFs(),
        nativeDragAndDrop: false,
      ),
    );
    await settleIo(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    Future<void> click(Offset at) async {
      await mouse.moveTo(at);
      await mouse.down(at);
      await tester.pump();
      // A click must not start a tab drag (the dragged copy used to render
      // outside the window scope and show an error box).
      expect(tester.takeException(), isNull);
      await mouse.up();
      await tester.pump();
    }

    await click(tester.getCenter(find.byTooltip('New Tab')));
    await settleIo(tester);
    expect(find.byTooltip('Close Tab'), findsWidgets);
    final tabTitles = find.descendant(
      of: find.byType(TabStrip),
      matching: find.byType(Text),
    );
    await click(tester.getCenter(tabTitles.first));
    await settleIo(tester);

    await ctrl(tester, LogicalKeyboardKey.comma);
    await tester.pumpAndSettle();
    final dialog = find.byType(Dialog);
    final sizes = <Size>[tester.getSize(dialog)];
    for (final tab in ['Sidebar', 'Advanced', 'General']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      sizes.add(tester.getSize(dialog));
    }
    expect(sizes.toSet(), hasLength(1), reason: 'no resize between tabs');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await settleIo(tester);
  });

  testWidgets('display settings: text size, extensions, bars, Enter', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      FinderApp(
        places: PlacesService(
          environment: {'HOME': root.path, 'USER': 'tester'},
        ),
        settings: SettingsController(
          SettingsStore(environment: {'XDG_CONFIG_HOME': root.path}),
          const FinderSettings(
            viewMode: ViewMode.list,
            textSize: 16,
            showExtensions: false,
            showPathBar: false,
            showStatusBar: false,
            enterRenames: true,
          ),
        ),
        initialPath: root.path,
        fs: const _NoDiskStatsFs(),
        nativeDragAndDrop: false,
      ),
    );
    await settleIo(tester);

    expect(find.text('a'), findsOneWidget, reason: 'extension hidden');
    expect(find.text('a.txt'), findsNothing);
    final row = tester.getSize(
      find.ancestor(of: find.text('a'), matching: find.byType(EntryGestures)),
    );
    expect(row.height, closeTo(24 * 16 / 13, 0.5), reason: 'rows grow');
    expect(find.byType(PathBar), findsNothing);
    expect(find.byType(StatusBar), findsNothing);

    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump();
    expect(find.byType(RenameField), findsOneWidget, reason: 'Enter renames');

    await tester.pumpWidget(const SizedBox());
    await settleIo(tester);
  });

  testWidgets('column view: pressing an item keeps the open column', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    File(p.join(root.path, 'Docs', 'inner.txt')).writeAsStringSync('i');
    await tester.pumpWidget(
      FinderApp(
        places: PlacesService(
          environment: {'HOME': root.path, 'USER': 'tester'},
        ),
        settings: SettingsController(
          SettingsStore(environment: {'XDG_CONFIG_HOME': root.path}),
          const FinderSettings(viewMode: ViewMode.columns),
        ),
        initialPath: root.path,
        fs: const _NoDiskStatsFs(),
        nativeDragAndDrop: false,
      ),
    );
    await settleIo(tester);
    final b = FinderScope.of(tester.element(find.byType(ContentArea))).browser;

    await tester.tap(find.widgetWithText(EntryGestures, 'Docs'));
    await settleIo(tester);
    expect(find.text('inner.txt'), findsOneWidget);

    // Press a.txt as if to drag it: Docs stays selected, its column open,
    // so the file can be dropped there. Releasing without a drag selects.
    final press = await tester.startGesture(
      tester.getCenter(find.text('a.txt')),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    expect(b.selection, {p.join(root.path, 'Docs')});
    expect(find.text('inner.txt'), findsOneWidget);
    await press.up();
    await settleIo(tester);
    expect(b.selection, {p.join(root.path, 'a.txt')});

    await tester.pumpWidget(const SizedBox());
    await settleIo(tester);
  });

  testWidgets('drag a tab right to split, down to tear it off', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('finder/window'),
      (call) async {
        calls.add(call.method);
        return null;
      },
    );
    await tester.pumpWidget(
      FinderApp(
        places: PlacesService(
          environment: {'HOME': root.path, 'USER': 'tester'},
        ),
        settings: SettingsController(
          SettingsStore(environment: {'XDG_CONFIG_HOME': root.path}),
          const FinderSettings(),
        ),
        initialPath: root.path,
        fs: const _NoDiskStatsFs(),
        nativeDragAndDrop: false,
      ),
    );
    await settleIo(tester);
    final scope = FinderScope.of(tester.element(find.byType(ContentArea)));
    final docs = scope.tabs.open(p.join(root.path, 'Docs'));
    await settleIo(tester);

    // Drag the Docs tab with the mouse over the right half of the content:
    // the drop zone shows, and releasing there splits the window.
    final tabTitle = find.descendant(
      of: find.byType(TabStrip),
      matching: find.text('Docs'),
    );
    final drag = await tester.startGesture(
      tester.getCenter(tabTitle),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await drag.moveBy(const Offset(0, 30));
    await tester.pump();
    await drag.moveTo(const Offset(1000, 400));
    await tester.pump();
    expect(find.text('Drop to show side by side'), findsOneWidget);
    // Away from the strip the tab floats under the pointer.
    final ghost = find.descendant(
      of: find.byType(TabDragGhost),
      matching: find.text('Docs'),
    );
    expect(ghost, findsOneWidget);
    expect(
      (tester.getCenter(ghost) - const Offset(1000, 400)).distance,
      lessThan(80),
      reason: 'follows the pointer, not just sideways',
    );
    await drag.up();
    await tester.pumpAndSettle();
    await settleIo(tester);
    expect(find.byType(TabPane), findsNWidgets(2));
    expect(find.text('Nested'), findsOneWidget, reason: 'Docs on the right');
    expect(find.text('a.txt'), findsOneWidget, reason: 'home on the left');

    // Clicking the left pane makes its tab the active one.
    await tester.tap(find.text('a.txt'));
    await tester.pump();
    expect(scope.tabs.active.browser.path, root.path);

    scope.tabs.unsplit();
    await settleIo(tester);
    expect(find.byType(TabPane), findsOneWidget);

    // Release a tab far below the strip, left of the split zone: tear off.
    scope.tabDrag.start(docs);
    scope.tabDrag.move(const Offset(300, 600), strip: null);
    scope.tabDrag.release();
    await settleIo(tester);
    expect(scope.tabs.tabs, hasLength(1));
    expect(scope.tabs.tabs.single.browser.path, root.path);

    await tester.pumpWidget(const SizedBox());
    await settleIo(tester);
  });

  testWidgets('dragging a tab along the strip reorders it, Chrome-style', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      FinderApp(
        places: PlacesService(
          environment: {'HOME': root.path, 'USER': 'tester'},
        ),
        settings: SettingsController(
          SettingsStore(environment: {'XDG_CONFIG_HOME': root.path}),
          const FinderSettings(),
        ),
        initialPath: root.path,
        fs: const _NoDiskStatsFs(),
        nativeDragAndDrop: false,
      ),
    );
    await settleIo(tester);
    final scope = FinderScope.of(tester.element(find.byType(ContentArea)));
    final docs = scope.tabs.open(p.join(root.path, 'Docs'));
    await settleIo(tester);
    final docsTab = find.descendant(
      of: find.byType(TabStrip),
      matching: find.text('Docs'),
    );
    final start = tester.getCenter(docsTab);

    // Drag Docs left over the first tab: it follows the pointer and the
    // first tab slides right to make room.
    final drag = await tester.startGesture(
      start,
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await drag.moveBy(const Offset(-20, 0));
    await tester.pump();
    await drag.moveTo(start - const Offset(220, 0));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      (tester.getCenter(docsTab) - (start - const Offset(220, 0))).distance,
      lessThan(4),
      reason: 'the dragged tab sticks to the pointer',
    );
    await drag.up();
    await tester.pump(const Duration(milliseconds: 300));
    expect(scope.tabs.tabs.first, docs);

    await tester.pumpWidget(const SizedBox());
    await settleIo(tester);
  });

  testWidgets('dragging on empty space selects with a rectangle', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    File(p.join(root.path, 'b.txt')).writeAsStringSync('b');
    await tester.pumpWidget(
      FinderApp(
        places: PlacesService(
          environment: {'HOME': root.path, 'USER': 'tester'},
        ),
        settings: SettingsController(
          SettingsStore(environment: {'XDG_CONFIG_HOME': root.path}),
          const FinderSettings(viewMode: ViewMode.list),
        ),
        initialPath: root.path,
        fs: const _NoDiskStatsFs(),
        nativeDragAndDrop: false,
      ),
    );
    await settleIo(tester);
    final scope = FinderScope.of(tester.element(find.byType(ContentArea)));
    expect(scope.browser.entries.map((e) => e.name), [
      'Docs',
      'a.txt',
      'b.txt',
    ]);

    // From the empty space below the rows up into the second row.
    final rows = find.byType(ListView).last;
    final below = tester.getBottomLeft(rows) + const Offset(400, -40);
    final aTxt = tester.getCenter(find.text('a.txt'));
    final gesture = await tester.startGesture(below);
    await gesture.moveTo(Offset(below.dx, aTxt.dy - 2));
    await tester.pump();
    await gesture.moveTo(Offset(below.dx - 300, aTxt.dy));
    await tester.pump();
    expect(scope.browser.selection, {
      p.join(root.path, 'a.txt'),
      p.join(root.path, 'b.txt'),
    });
    await gesture.up();
    await tester.pump();
    expect(scope.browser.selection, hasLength(2), reason: 'kept on release');
  });

  testWidgets('a later launch opens its folder here as a tab', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      FinderApp(
        places: PlacesService(
          environment: {'HOME': root.path, 'USER': 'tester'},
        ),
        settings: SettingsController(
          SettingsStore(environment: {'XDG_CONFIG_HOME': root.path}),
          const FinderSettings(),
        ),
        initialPath: root.path,
        fs: const _NoDiskStatsFs(),
        nativeDragAndDrop: false,
      ),
    );
    await settleIo(tester);

    // What the GTK runner sends the active window for `finder <args>`.
    Future<Object?> launch(List<String> args) async {
      const codec = StandardMethodCodec();
      ByteData? reply;
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'finder/window',
        codec.encodeMethodCall(MethodCall('launch', args)),
        (data) => reply = data,
      );
      return reply == null ? null : codec.decodeEnvelope(reply!);
    }

    final scope = FinderScope.of(tester.element(find.byType(ContentArea)));
    final docs = p.join(root.path, 'Docs');
    expect(await launch([docs]), isTrue);
    await settleIo(tester);
    expect(scope.tabs.tabs, hasLength(2));
    expect(scope.tabs.active.browser.path, docs);

    // A window asked for, or no folder at all: GTK opens a new window.
    expect(await launch(['--new-window', docs]), isFalse);
    expect(await launch(const []), isFalse);
    expect(scope.tabs.tabs, hasLength(2));
  });

  testWidgets('reopens the saved tabs with their views', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      FinderApp(
        places: PlacesService(
          environment: {'HOME': root.path, 'USER': 'tester'},
        ),
        settings: SettingsController(
          SettingsStore(environment: {'XDG_CONFIG_HOME': root.path}),
          const FinderSettings(),
        ),
        initialPath: root.path,
        fs: const _NoDiskStatsFs(),
        nativeDragAndDrop: false,
        restoredSession: (
          tabs: [
            (path: root.path, viewMode: 'icons'),
            (path: p.join(root.path, 'Docs'), viewMode: 'list'),
          ],
          active: 1,
        ),
      ),
    );
    await settleIo(tester);
    final scope = FinderScope.of(tester.element(find.byType(ContentArea)));
    expect(scope.tabs.tabs, hasLength(2));
    expect(scope.tabs.active.browser.path, p.join(root.path, 'Docs'));
    expect(scope.tabs.active.browser.viewMode, ViewMode.list);

    await tester.pumpWidget(const SizedBox());
    await settleIo(tester);
  });

  testWidgets('paste over an existing name asks; Ctrl+Z undoes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    File(p.join(root.path, 'Docs', 'a.txt')).writeAsStringSync('old');
    await tester.pumpWidget(
      FinderApp(
        places: PlacesService(
          environment: {'HOME': root.path, 'USER': 'tester'},
        ),
        settings: SettingsController(
          SettingsStore(environment: {'XDG_CONFIG_HOME': root.path}),
          const FinderSettings(),
        ),
        initialPath: root.path,
        fs: const _NoDiskStatsFs(),
        nativeDragAndDrop: false,
      ),
    );
    await settleIo(tester);
    await tester.tap(find.text('a.txt'));
    await tester.pump();
    await ctrl(tester, LogicalKeyboardKey.keyC);
    final scope = FinderScope.of(tester.element(find.byType(ContentArea)));
    unawaited(scope.browser.navigate(p.join(root.path, 'Docs')));
    await settleIo(tester);

    await ctrl(tester, LogicalKeyboardKey.keyV);
    await settleIo(tester);
    expect(find.text('Keep Both'), findsOneWidget);
    await tester.tap(find.text('Keep Both'));
    await settleIo(tester);
    await settleIo(tester);
    expect(File(p.join(root.path, 'Docs', 'a 2.txt')).existsSync(), isTrue);
    expect(File(p.join(root.path, 'Docs', 'a.txt')).readAsStringSync(), 'old');
    expect(scope.actions.history.canUndo, isTrue);

    await tester.pumpWidget(const SizedBox());
    await settleIo(tester);
  });
}
