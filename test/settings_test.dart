import 'dart:io';

import 'package:finder_linux/models/file_entry.dart';
import 'package:finder_linux/models/finder_settings.dart';
import 'package:finder_linux/models/place.dart';
import 'package:finder_linux/models/sort_spec.dart';
import 'package:finder_linux/services/settings_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late SettingsStore store;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('finder_settings');
    store = SettingsStore(environment: {'XDG_CONFIG_HOME': dir.path});
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('missing file loads defaults', () async {
    expect(await store.load(), const FinderSettings());
  });

  test('save then load round-trips every field', () async {
    const settings = FinderSettings(
      newWindowFolder: PlaceKind.downloads,
      viewMode: ViewMode.columns,
      groupBy: GroupBy.kind,
      sortField: SortField.size,
      appearance: AppearanceMode.dark,
      languageCode: 'vi',
      hiddenPlaces: {PlaceKind.music, PlaceKind.trash},
      showHidden: true,
      foldersFirst: false,
      showThumbnails: false,
      warnBeforeEmptyingTrash: false,
    );
    await store.save(settings);
    expect(await store.load(), settings);
  });

  test('corrupt or unknown values fall back to defaults', () async {
    store.file.parent.createSync(recursive: true);
    store.file.writeAsStringSync('{not json');
    expect(await store.load(), const FinderSettings());

    store.file.writeAsStringSync(
      '{"viewMode": "gallery", "showHidden": "yes", '
      '"hiddenPlaces": ["trash", "nope"], "languageCode": 3}',
    );
    final loaded = await store.load();
    expect(loaded.viewMode, ViewMode.icons);
    expect(loaded.showHidden, isFalse);
    expect(loaded.hiddenPlaces, {PlaceKind.trash});
    expect(loaded.languageCode, isNull);
  });

  test('copyWith can reset the language to follow the system', () {
    const vi = FinderSettings(languageCode: 'vi');
    expect(vi.copyWith(languageCode: () => null).languageCode, isNull);
    expect(vi.copyWith(showHidden: true).languageCode, 'vi');
  });

  test('folders-on-top can be switched off', () {
    FileEntry entry(String name, {bool dir = false}) => FileEntry(
      path: '/x/$name',
      isDirectory: dir,
      size: 0,
      modified: DateTime(2026),
      mode: 0,
    );
    final items = [entry('b'), entry('Zed', dir: true), entry('a')];
    items.sort(const SortSpec(foldersFirst: false).compare);
    expect(items.map((e) => e.name), ['a', 'b', 'Zed']);
  });
}
