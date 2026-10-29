import 'dart:async';
import 'dart:io';

import 'package:finder_linux/core/result.dart';
import 'package:finder_linux/main.dart';
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
      of: find.byType(ReorderableListView),
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

  testWidgets('drag files onto a folder, and across tabs', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    File(p.join(root.path, 'b.txt')).writeAsStringSync('b');
    Directory(p.join(root.path, 'Other')).createSync();
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
      ),
    );
    await settleIo(tester);

    Future<void> dragTo(Offset from, Offset to, {int lingerMs = 0}) async {
      final mouse = await tester.startGesture(
        from,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      await mouse.moveBy(const Offset(12, 4));
      await tester.pump();
      await mouse.moveTo(to);
      await tester.pump();
      if (lingerMs > 0) {
        await tester.pump(Duration(milliseconds: lingerMs));
        await tester.pump();
        await mouse.moveBy(const Offset(1, 1));
        await tester.pump();
      }
      await mouse.up();
      await tester.pump();
      await settleIo(tester);
    }

    // A click alone selects without starting a drag.
    await tester.tap(find.text('a.txt'));
    await tester.pump();
    expect(tester.takeException(), isNull);

    // Drop onto a folder in the icon grid.
    await dragTo(
      tester.getCenter(find.text('a.txt').first),
      tester.getCenter(find.text('Docs')),
    );
    expect(File(p.join(root.path, 'Docs', 'a.txt')).existsSync(), isTrue);
    expect(find.text('a.txt'), findsNothing);

    // Open "Other" in a second tab, go back to the first tab, then drag
    // b.txt onto the second tab, rest there until it opens, drop inside.
    final scope = FinderScope.of(tester.element(find.byType(ContentArea)));
    scope.tabs.open(p.join(root.path, 'Other'), activate: false);
    await settleIo(tester);
    final tabTitles = find.descendant(
      of: find.byType(ReorderableListView),
      matching: find.byType(Text),
    );
    final otherTab = tester.getCenter(tabTitles.at(1));
    await dragTo(
      tester.getCenter(find.text('b.txt').first),
      otherTab,
      lingerMs: 700,
    );
    expect(
      File(p.join(root.path, 'Other', 'b.txt')).existsSync(),
      isTrue,
      reason: 'dropped on the tab: moved into its folder',
    );
    expect(scope.tabs.activeIndex, 1, reason: 'resting on a tab opens it');
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await settleIo(tester);
  });

  testWidgets('column view: drag into the open column and out to a parent', (
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
      ),
    );
    await settleIo(tester);
    final b = FinderScope.of(tester.element(find.byType(ContentArea))).browser;

    Future<void> drag(Finder from, Offset to) async {
      final mouse = await tester.startGesture(
        tester.getCenter(from),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      await mouse.moveBy(const Offset(12, 4));
      await tester.pump();
      await mouse.moveTo(to);
      await tester.pump();
      await mouse.up();
      await tester.pump();
      await settleIo(tester);
    }

    // Select Docs: its contents open in the next column.
    await tester.tap(find.widgetWithText(EntryGestures, 'Docs'));
    await settleIo(tester);
    expect(find.text('inner.txt'), findsOneWidget);

    // Pressing a.txt to drag it must keep Docs selected (its column stays),
    // and dropping on that column's empty space moves the file into Docs.
    final docsColumnEmpty =
        tester.getCenter(find.text('inner.txt')) + const Offset(0, 300);
    await drag(find.text('a.txt'), docsColumnEmpty);
    expect(File(p.join(root.path, 'Docs', 'a.txt')).existsSync(), isTrue);

    // Go into Docs, then drag inner.txt back out onto the parent column.
    // Not awaited: its directory read only progresses inside settleIo.
    unawaited(b.navigate(p.join(root.path, 'Docs')));
    await settleIo(tester);
    final parentColumnEmpty =
        tester.getCenter(find.widgetWithText(EntryGestures, 'Docs')) +
        const Offset(0, 300);
    await drag(find.text('inner.txt'), parentColumnEmpty);
    expect(File(p.join(root.path, 'inner.txt')).existsSync(), isTrue);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await settleIo(tester);
  });
}
