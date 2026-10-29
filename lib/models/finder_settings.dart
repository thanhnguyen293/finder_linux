import 'package:flutter/foundation.dart';

import 'place.dart';
import 'sort_spec.dart';

enum AppearanceMode { system, light, dark }

/// Folders a new window can start in.
const newWindowFolderChoices = [
  PlaceKind.home,
  PlaceKind.desktop,
  PlaceKind.documents,
  PlaceKind.downloads,
  PlaceKind.computer,
];

/// User preferences (Finder ▸ Settings), persisted as JSON.
@immutable
class FinderSettings {
  const FinderSettings({
    this.newWindowFolder = PlaceKind.home,
    this.viewMode = ViewMode.icons,
    this.groupBy = GroupBy.none,
    this.sortField = SortField.name,
    this.appearance = AppearanceMode.system,
    this.languageCode,
    this.hiddenPlaces = const {},
    this.showHidden = false,
    this.foldersFirst = true,
    this.showThumbnails = true,
    this.warnBeforeEmptyingTrash = true,
  });

  final PlaceKind newWindowFolder;
  final ViewMode viewMode;
  final GroupBy groupBy;
  final SortField sortField;
  final AppearanceMode appearance;

  /// `null` follows the system language.
  final String? languageCode;

  /// Sidebar entries the user switched off.
  final Set<PlaceKind> hiddenPlaces;
  final bool showHidden;
  final bool foldersFirst;
  final bool showThumbnails;
  final bool warnBeforeEmptyingTrash;

  FinderSettings copyWith({
    PlaceKind? newWindowFolder,
    ViewMode? viewMode,
    GroupBy? groupBy,
    SortField? sortField,
    AppearanceMode? appearance,
    ValueGetter<String?>? languageCode,
    Set<PlaceKind>? hiddenPlaces,
    bool? showHidden,
    bool? foldersFirst,
    bool? showThumbnails,
    bool? warnBeforeEmptyingTrash,
  }) => FinderSettings(
    newWindowFolder: newWindowFolder ?? this.newWindowFolder,
    viewMode: viewMode ?? this.viewMode,
    groupBy: groupBy ?? this.groupBy,
    sortField: sortField ?? this.sortField,
    appearance: appearance ?? this.appearance,
    // A getter so callers can reset the language to `null` (system).
    languageCode: languageCode == null ? this.languageCode : languageCode(),
    hiddenPlaces: hiddenPlaces ?? this.hiddenPlaces,
    showHidden: showHidden ?? this.showHidden,
    foldersFirst: foldersFirst ?? this.foldersFirst,
    showThumbnails: showThumbnails ?? this.showThumbnails,
    warnBeforeEmptyingTrash:
        warnBeforeEmptyingTrash ?? this.warnBeforeEmptyingTrash,
  );

  Map<String, Object?> toJson() => {
    'newWindowFolder': newWindowFolder.name,
    'viewMode': viewMode.name,
    'groupBy': groupBy.name,
    'sortField': sortField.name,
    'appearance': appearance.name,
    'languageCode': languageCode,
    'hiddenPlaces': [for (final k in hiddenPlaces) k.name],
    'showHidden': showHidden,
    'foldersFirst': foldersFirst,
    'showThumbnails': showThumbnails,
    'warnBeforeEmptyingTrash': warnBeforeEmptyingTrash,
  };

  /// Unknown or missing values fall back to defaults, so an older or
  /// hand-edited file never prevents the app from starting.
  factory FinderSettings.fromJson(Map<String, Object?> json) {
    const d = FinderSettings();
    T pick<T extends Enum>(List<T> values, Object? raw, T fallback) =>
        values.where((v) => v.name == raw).firstOrNull ?? fallback;
    bool flag(String key, bool fallback) =>
        json[key] is bool ? json[key] as bool : fallback;
    final hidden = json['hiddenPlaces'];
    return FinderSettings(
      newWindowFolder: pick(
        newWindowFolderChoices,
        json['newWindowFolder'],
        d.newWindowFolder,
      ),
      viewMode: pick(ViewMode.values, json['viewMode'], d.viewMode),
      groupBy: pick(GroupBy.values, json['groupBy'], d.groupBy),
      sortField: pick(SortField.values, json['sortField'], d.sortField),
      appearance: pick(AppearanceMode.values, json['appearance'], d.appearance),
      languageCode: json['languageCode'] is String
          ? json['languageCode'] as String
          : null,
      hiddenPlaces: {
        if (hidden is List)
          for (final raw in hidden)
            ?PlaceKind.values.where((k) => k.name == raw).firstOrNull,
      },
      showHidden: flag('showHidden', d.showHidden),
      foldersFirst: flag('foldersFirst', d.foldersFirst),
      showThumbnails: flag('showThumbnails', d.showThumbnails),
      warnBeforeEmptyingTrash: flag(
        'warnBeforeEmptyingTrash',
        d.warnBeforeEmptyingTrash,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FinderSettings &&
      other.newWindowFolder == newWindowFolder &&
      other.viewMode == viewMode &&
      other.groupBy == groupBy &&
      other.sortField == sortField &&
      other.appearance == appearance &&
      other.languageCode == languageCode &&
      setEquals(other.hiddenPlaces, hiddenPlaces) &&
      other.showHidden == showHidden &&
      other.foldersFirst == foldersFirst &&
      other.showThumbnails == showThumbnails &&
      other.warnBeforeEmptyingTrash == warnBeforeEmptyingTrash;

  @override
  int get hashCode => Object.hash(
    newWindowFolder,
    viewMode,
    groupBy,
    sortField,
    appearance,
    languageCode,
    Object.hashAllUnordered(hiddenPlaces),
    showHidden,
    foldersFirst,
    showThumbnails,
    warnBeforeEmptyingTrash,
  );
}
