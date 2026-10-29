import 'package:flutter/foundation.dart';

import 'place.dart';
import 'sort_spec.dart';

enum AppearanceMode { system, light, dark }

/// macOS accent colours (System Settings ▸ Appearance).
enum AccentColor { blue, purple, pink, red, orange, yellow, green, graphite }

/// Folders a new window can start in.
const newWindowFolderChoices = [
  PlaceKind.home,
  PlaceKind.desktop,
  PlaceKind.documents,
  PlaceKind.downloads,
  PlaceKind.computer,
];

/// Text sizes offered, in points; 13 pt is the design size.
const textSizeChoices = [11, 12, 13, 14, 16];

/// Icon view icon sizes offered, in logical pixels.
const iconSizeChoices = [32, 48, 64, 80, 96, 128];

/// User preferences (Finder ▸ Settings), persisted as JSON.
@immutable
class FinderSettings {
  const FinderSettings({
    this.newWindowFolder = PlaceKind.home,
    this.openFoldersInTabs = true,
    this.viewMode = ViewMode.icons,
    this.groupBy = GroupBy.none,
    this.sortField = SortField.name,
    this.appearance = AppearanceMode.system,
    this.accent = AccentColor.blue,
    this.textSize = 13,
    this.iconSize = 64,
    this.languageCode,
    this.hiddenPlaces = const {},
    this.showPathBar = true,
    this.showStatusBar = true,
    this.showExtensions = true,
    this.showHidden = false,
    this.foldersFirst = true,
    this.showThumbnails = true,
    this.warnBeforeEmptyingTrash = true,
    this.enterRenames = false,
  });

  final PlaceKind newWindowFolder;

  /// Folders opened from other apps become tabs of an open window.
  final bool openFoldersInTabs;
  final ViewMode viewMode;
  final GroupBy groupBy;
  final SortField sortField;
  final AppearanceMode appearance;
  final AccentColor accent;

  /// Base text size in points (see [textSizeChoices]).
  final int textSize;

  /// Icon view icon size in logical pixels (see [iconSizeChoices]).
  final int iconSize;

  /// `null` follows the system language.
  final String? languageCode;

  /// Sidebar entries the user switched off.
  final Set<PlaceKind> hiddenPlaces;
  final bool showPathBar;
  final bool showStatusBar;

  /// Finder's "Show all filename extensions".
  final bool showExtensions;
  final bool showHidden;
  final bool foldersFirst;
  final bool showThumbnails;
  final bool warnBeforeEmptyingTrash;

  /// macOS behaviour: Enter renames and Ctrl+Down opens.
  final bool enterRenames;

  /// Factor applied to text (and the row heights that hold it).
  double get textScale => textSize / 13;

  FinderSettings copyWith({
    PlaceKind? newWindowFolder,
    bool? openFoldersInTabs,
    ViewMode? viewMode,
    GroupBy? groupBy,
    SortField? sortField,
    AppearanceMode? appearance,
    AccentColor? accent,
    int? textSize,
    int? iconSize,
    ValueGetter<String?>? languageCode,
    Set<PlaceKind>? hiddenPlaces,
    bool? showPathBar,
    bool? showStatusBar,
    bool? showExtensions,
    bool? showHidden,
    bool? foldersFirst,
    bool? showThumbnails,
    bool? warnBeforeEmptyingTrash,
    bool? enterRenames,
  }) => FinderSettings(
    newWindowFolder: newWindowFolder ?? this.newWindowFolder,
    openFoldersInTabs: openFoldersInTabs ?? this.openFoldersInTabs,
    viewMode: viewMode ?? this.viewMode,
    groupBy: groupBy ?? this.groupBy,
    sortField: sortField ?? this.sortField,
    appearance: appearance ?? this.appearance,
    accent: accent ?? this.accent,
    textSize: textSize ?? this.textSize,
    iconSize: iconSize ?? this.iconSize,
    // A getter so callers can reset the language to `null` (system).
    languageCode: languageCode == null ? this.languageCode : languageCode(),
    hiddenPlaces: hiddenPlaces ?? this.hiddenPlaces,
    showPathBar: showPathBar ?? this.showPathBar,
    showStatusBar: showStatusBar ?? this.showStatusBar,
    showExtensions: showExtensions ?? this.showExtensions,
    showHidden: showHidden ?? this.showHidden,
    foldersFirst: foldersFirst ?? this.foldersFirst,
    showThumbnails: showThumbnails ?? this.showThumbnails,
    warnBeforeEmptyingTrash:
        warnBeforeEmptyingTrash ?? this.warnBeforeEmptyingTrash,
    enterRenames: enterRenames ?? this.enterRenames,
  );

  Map<String, Object?> toJson() => {
    'newWindowFolder': newWindowFolder.name,
    'openFoldersInTabs': openFoldersInTabs,
    'viewMode': viewMode.name,
    'groupBy': groupBy.name,
    'sortField': sortField.name,
    'appearance': appearance.name,
    'accent': accent.name,
    'textSize': textSize,
    'iconSize': iconSize,
    'languageCode': languageCode,
    'hiddenPlaces': [for (final k in hiddenPlaces) k.name],
    'showPathBar': showPathBar,
    'showStatusBar': showStatusBar,
    'showExtensions': showExtensions,
    'showHidden': showHidden,
    'foldersFirst': foldersFirst,
    'showThumbnails': showThumbnails,
    'warnBeforeEmptyingTrash': warnBeforeEmptyingTrash,
    'enterRenames': enterRenames,
  };

  /// Unknown or missing values fall back to defaults, so an older or
  /// hand-edited file never prevents the app from starting.
  factory FinderSettings.fromJson(Map<String, Object?> json) {
    const d = FinderSettings();
    T pick<T extends Enum>(List<T> values, Object? raw, T fallback) =>
        values.where((v) => v.name == raw).firstOrNull ?? fallback;
    bool flag(String key, bool fallback) =>
        json[key] is bool ? json[key] as bool : fallback;
    int choice(String key, List<int> allowed, int fallback) =>
        allowed.contains(json[key]) ? json[key] as int : fallback;
    final hidden = json['hiddenPlaces'];
    return FinderSettings(
      newWindowFolder: pick(
        newWindowFolderChoices,
        json['newWindowFolder'],
        d.newWindowFolder,
      ),
      openFoldersInTabs: flag('openFoldersInTabs', d.openFoldersInTabs),
      viewMode: pick(ViewMode.values, json['viewMode'], d.viewMode),
      groupBy: pick(GroupBy.values, json['groupBy'], d.groupBy),
      sortField: pick(SortField.values, json['sortField'], d.sortField),
      appearance: pick(AppearanceMode.values, json['appearance'], d.appearance),
      accent: pick(AccentColor.values, json['accent'], d.accent),
      textSize: choice('textSize', textSizeChoices, d.textSize),
      iconSize: choice('iconSize', iconSizeChoices, d.iconSize),
      languageCode: json['languageCode'] is String
          ? json['languageCode'] as String
          : null,
      hiddenPlaces: {
        if (hidden is List)
          for (final raw in hidden)
            ?PlaceKind.values.where((k) => k.name == raw).firstOrNull,
      },
      showPathBar: flag('showPathBar', d.showPathBar),
      showStatusBar: flag('showStatusBar', d.showStatusBar),
      showExtensions: flag('showExtensions', d.showExtensions),
      showHidden: flag('showHidden', d.showHidden),
      foldersFirst: flag('foldersFirst', d.foldersFirst),
      showThumbnails: flag('showThumbnails', d.showThumbnails),
      warnBeforeEmptyingTrash: flag(
        'warnBeforeEmptyingTrash',
        d.warnBeforeEmptyingTrash,
      ),
      enterRenames: flag('enterRenames', d.enterRenames),
    );
  }

  // Equality by serialised form: every field is in toJson, and one place
  // to update beats keeping == and hashCode in sync by hand. The place set
  // is compared on its own because collections compare by identity.
  @override
  bool operator ==(Object other) =>
      other is FinderSettings &&
      mapEquals(other._scalars, _scalars) &&
      setEquals(other.hiddenPlaces, hiddenPlaces);

  Map<String, Object?> get _scalars => toJson()..remove('hiddenPlaces');

  @override
  int get hashCode => Object.hash(
    Object.hashAll(_scalars.values),
    Object.hashAllUnordered(hiddenPlaces),
  );
}
