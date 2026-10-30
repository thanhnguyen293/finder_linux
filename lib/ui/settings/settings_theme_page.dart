import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/finder_settings.dart';
import '../../models/theme_colors.dart';
import '../../theme/finder_theme.dart';
import '../dialogs/color_picker_dialog.dart';
import '../settings_scope.dart';
import '../widgets/hover_button.dart';
import 'settings_controls.dart';

/// Theme editor: override palette colors for the appearance in use
/// (light and dark keep separate colors, since a background that suits
/// one rarely suits the other).
class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = SettingsScope.of(context);
    final palette = context.palette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = dark ? s.darkColors : s.lightColors;

    FinderSettings withColors(ThemeColors next) =>
        dark ? s.copyWith(darkColors: next) : s.copyWith(lightColors: next);

    final slots = {
      ThemeSlot.accent: (l10n.themeAccent, palette.accent),
      ThemeSlot.selection: (l10n.themeSelection, palette.selection),
      ThemeSlot.folder: (l10n.themeFolder, palette.folder),
      ThemeSlot.window: (l10n.themeWindow, palette.content),
      ThemeSlot.sidebar: (l10n.themeSidebar, palette.sidebar),
      ThemeSlot.toolbar: (l10n.themeToolbar, palette.toolbar),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.themeEditingFor(
            dark ? l10n.appearanceDark : l10n.appearanceLight,
          ),
          style: TextStyle(
            fontSize: FinderMetrics.fontSizeSmall + 1,
            color: palette.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        for (final MapEntry(key: slot, value: (label, current))
            in slots.entries)
          SettingRow(
            label: label,
            child: Row(
              spacing: 8,
              children: [
                _Swatch(
                  color: current,
                  onTap: () async {
                    final picked = await showColorPicker(context, current);
                    if (picked == null || !context.mounted) return;
                    await saveSettings(
                      context,
                      withColors({...colors, slot: picked.toARGB32()}),
                    );
                  },
                ),
                Text(
                  colorToHex(current),
                  style: TextStyle(
                    fontSize: FinderMetrics.fontSizeSmall + 1,
                    color: palette.textSecondary,
                  ),
                ),
                if (colors.containsKey(slot))
                  HoverButton(
                    tooltip: l10n.themeReset,
                    padding: const EdgeInsets.all(3),
                    onPressed: () => saveSettings(
                      context,
                      withColors({...colors}..remove(slot)),
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_counterclockwise,
                      size: 13,
                    ),
                  ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: colors.isEmpty
                ? null
                : () => saveSettings(context, withColors(const {})),
            child: Text(l10n.themeResetAll),
          ),
        ),
        Text(
          l10n.themeEffects,
          style: const TextStyle(
            fontSize: FinderMetrics.fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        SettingRow(
          label: l10n.themeSidebarOpacity,
          child: _OpacitySlider(
            value: s.sidebarOpacity,
            min: minSidebarOpacity,
            onChanged: (v) =>
                saveSettings(context, s.copyWith(sidebarOpacity: v)),
          ),
        ),
        SettingRow(
          label: l10n.themeWindowOpacity,
          child: _OpacitySlider(
            value: s.windowOpacity,
            min: minWindowOpacity,
            onChanged: (v) =>
                saveSettings(context, s.copyWith(windowOpacity: v)),
          ),
        ),
        CheckRow(
          label: l10n.themeGlass,
          value: s.glass,
          onChanged: (v) => saveSettings(context, s.copyWith(glass: v)),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.themeBlurHint(appId),
          style: TextStyle(
            fontSize: FinderMetrics.fontSizeSmall + 1,
            color: palette.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// GNOME's name for Finder's windows, which Blur my Shell lists.
const appId = 'dev.thanh.finder_linux';

/// 5 % steps, shown as a percentage. Steps keep a drag from saving the
/// settings file on every pixel.
class _OpacitySlider extends StatelessWidget {
  const _OpacitySlider({
    required this.value,
    required this.min,
    required this.onChanged,
  });

  final double value;
  final double min;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Slider(
          value: value.clamp(min, 1),
          min: min,
          divisions: ((1 - min) / 0.05).round(),
          onChanged: onChanged,
        ),
      ),
      SizedBox(
        width: 44,
        child: Text(
          '${(value * 100).round()}%',
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: FinderMetrics.fontSizeSmall + 1,
            color: context.palette.textSecondary,
          ),
        ),
      ),
    ],
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 22,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(FinderMetrics.radiusSmall),
          border: Border.all(color: context.palette.separator),
        ),
      ),
    ),
  );
}
