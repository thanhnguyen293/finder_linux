/// Palette colors the theme editor can change.
enum ThemeSlot { accent, selection, folder, sidebar, window, toolbar }

/// The user's color overrides for one appearance (light or dark), as ARGB
/// values; slots left out keep the built-in color.
typedef ThemeColors = Map<ThemeSlot, int>;

Map<String, int> themeColorsToJson(ThemeColors colors) => {
  for (final MapEntry(:key, :value) in colors.entries) key.name: value,
};

ThemeColors themeColorsFromJson(Object? json) => {
  if (json is Map)
    for (final slot in ThemeSlot.values)
      if (json[slot.name] case final int argb) slot: argb,
};
