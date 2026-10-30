import 'dart:io';

import 'package:finder_linux/models/finder_settings.dart';
import 'package:finder_linux/models/theme_colors.dart';
import 'package:finder_linux/services/file_system_service.dart';
import 'package:finder_linux/services/recent_folders.dart';
import 'package:finder_linux/services/update_service.dart';
import 'package:finder_linux/state/browser_controller.dart';
import 'package:finder_linux/theme/finder_theme.dart';
import 'package:finder_linux/ui/dialogs/color_picker_dialog.dart';
import 'package:finder_linux/ui/views/column_browser_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('finder_misc');
    for (final d in ['a', 'b', 'c', 'd']) {
      await Directory(p.join(root.path, d)).create();
    }
  });

  tearDown(() => root.delete(recursive: true));

  String at(String rel) => p.join(root.path, rel);

  test('history menus jump several steps and keep the rest', () async {
    final visited = <String>[];
    final c = BrowserController(
      fs: const FileSystemService(),
      trashDir: '/nonexistent',
      initialPath: at('a'),
      onVisit: visited.add,
    );
    addTearDown(c.dispose);
    await c.start();
    for (final d in ['b', 'c', 'd']) {
      await c.navigate(at(d));
    }
    expect(c.backHistory, [at('c'), at('b'), at('a')]);
    await c.jumpHistory(2);
    expect(c.path, at('b'));
    expect(c.backHistory, [at('a')]);
    expect(c.forwardHistory, [at('c'), at('d')]);
    await c.jumpHistory(-2);
    expect(c.path, at('d'));
    expect(c.backHistory, [at('c'), at('b'), at('a')]);
    // Only the user's own navigations count as visits.
    expect(visited, [at('b'), at('c'), at('d')]);
  });

  test(
    'spring-loading opens a folder, never one already on the path',
    () async {
      await Directory(at('a/x/y')).create(recursive: true);
      final c = BrowserController(
        fs: const FileSystemService(),
        trashDir: '/nonexistent',
        initialPath: at('a/x'),
      );
      addTearDown(c.dispose);
      await c.start();
      springLoad(c, at('a'));
      springLoad(c, at('a/x'));
      await pumpEventQueue();
      expect(c.path, at('a/x'));
      springLoad(c, at('a/x/y'));
      await pumpEventQueue();
      expect(c.path, at('a/x/y'));
    },
  );

  test(
    'recent folders: newest first, no duplicates, gone folders dropped',
    () async {
      final recents = RecentFolders(
        environment: {'XDG_CONFIG_HOME': at('config')},
        limit: 3,
      );
      expect(await recents.load(), isEmpty);
      for (final d in ['a', 'b', 'a', 'c', 'd']) {
        await recents.add(at(d));
      }
      expect(await recents.load(), [at('d'), at('c'), at('a')]);
      await Directory(at('c')).delete();
      expect(await recents.load(), [at('d'), at('a')]);
      await recents.clear();
      expect(await recents.load(), isEmpty);
    },
  );

  test('theme colors survive the settings file', () {
    const s = FinderSettings(
      lightColors: {ThemeSlot.accent: 0xFF112233},
      darkColors: {ThemeSlot.sidebar: 0xFF000000},
      checkForUpdates: false,
    );
    final back = FinderSettings.fromJson(s.toJson());
    expect(back, s);
    expect(back.lightColors, {ThemeSlot.accent: 0xFF112233});
    expect(
      FinderSettings.fromJson({
        'lightColors': {'accent': 'red', 'nope': 1, 'folder': 0xFF00FF00},
      }).lightColors,
      {ThemeSlot.folder: 0xFF00FF00},
    );
  });

  test('overrides recolor the palette and its related shades', () {
    final light = FinderPalette.light;
    final edited = light.withOverrides({
      ThemeSlot.accent: 0xFFFF0000,
      ThemeSlot.toolbar: 0xFF808080,
    }, Brightness.light);
    expect(edited.accent, const Color(0xFFFF0000));
    expect(edited.selection, isNot(light.selection));
    expect(edited.toolbar, const Color(0xFF808080));
    expect(edited.tabStrip, isNot(light.tabStrip));
    expect(edited.content, light.content);
    expect(light.withOverrides(const {}, Brightness.light), same(light));
  });

  test('window effects: stored, clamped, and applied to the palette', () {
    const s = FinderSettings(
      sidebarOpacity: 0.6,
      windowOpacity: 0.8,
      glass: true,
    );
    expect(FinderSettings.fromJson(s.toJson()), s);
    final clamped = FinderSettings.fromJson({
      'sidebarOpacity': 0.01,
      'windowOpacity': 'x',
    });
    expect(clamped.sidebarOpacity, minSidebarOpacity);
    expect(clamped.windowOpacity, 1);

    final light = FinderPalette.light;
    expect(light.withTranslucency(sidebar: 1, window: 1), same(light));
    final seeThrough = light.withTranslucency(sidebar: 0.5, window: 0.8);
    expect(seeThrough.content.a, closeTo(0.8, 0.01));
    expect(seeThrough.sidebar.a, closeTo(0.4, 0.01));
    expect(seeThrough.accent, light.accent);
    final theme = buildFinderTheme(Brightness.light, windowOpacity: 0.8);
    expect(theme.scaffoldBackgroundColor.a, 0);
    expect(theme.colorScheme.surface.a, 1, reason: 'dialogs stay solid');
  });

  test('hex colors parse and print', () {
    expect(parseHexColor('#fa0'), const Color(0xFFFFAA00));
    expect(parseHexColor('112233'), const Color(0xFF112233));
    expect(parseHexColor('#12345'), isNull);
    expect(parseHexColor('zzzzzz'), isNull);
    expect(colorToHex(const Color(0xFF0A84FF)), '#0A84FF');
  });

  test('an update is offered only when main is ahead of the build', () {
    expect(
      parseCompare({'status': 'ahead', 'ahead_by': 3}),
      UpdateCheck.available,
    );
    expect(
      parseCompare({'status': 'identical', 'ahead_by': 0}),
      UpdateCheck.upToDate,
    );
    expect(
      parseCompare({'status': 'behind', 'ahead_by': 0}),
      UpdateCheck.upToDate,
    );
    expect(
      UpdateService(environment: const {}, commit: '', flutter: '').supported,
      isFalse,
    );
  });
}
