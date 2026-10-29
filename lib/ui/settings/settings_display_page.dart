import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/finder_settings.dart';
import '../../theme/finder_theme.dart';
import '../settings_scope.dart';
import 'settings_controls.dart';

/// Look of the app: theme, accent, text and icon sizes, optional bars.
class DisplaySettingsPage extends StatelessWidget {
  const DisplaySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = SettingsScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingRow(
          label: l10n.settingsAppearance,
          child: PopupField(
            value: s.appearance,
            options: {
              AppearanceMode.system: l10n.appearanceSystem,
              AppearanceMode.light: l10n.appearanceLight,
              AppearanceMode.dark: l10n.appearanceDark,
            },
            onChanged: (v) => saveSettings(context, s.copyWith(appearance: v)),
          ),
        ),
        SettingRow(
          label: l10n.settingsAccentColor,
          child: _AccentPicker(
            value: s.accent,
            onChanged: (v) => saveSettings(context, s.copyWith(accent: v)),
          ),
        ),
        const SizedBox(height: 8),
        SettingRow(
          label: l10n.settingsTextSize,
          child: PopupField(
            value: s.textSize,
            // Point sizes read the same in every language.
            options: {for (final pt in textSizeChoices) pt: '$pt pt'},
            onChanged: (v) => saveSettings(context, s.copyWith(textSize: v)),
          ),
        ),
        SettingRow(
          label: l10n.settingsIconSize,
          child: PopupField(
            value: s.iconSize,
            options: {for (final px in iconSizeChoices) px: '$px × $px'},
            onChanged: (v) => saveSettings(context, s.copyWith(iconSize: v)),
          ),
        ),
        const SizedBox(height: 12),
        CheckRow(
          label: l10n.settingsShowPathBar,
          value: s.showPathBar,
          onChanged: (v) => saveSettings(context, s.copyWith(showPathBar: v)),
        ),
        CheckRow(
          label: l10n.settingsShowStatusBar,
          value: s.showStatusBar,
          onChanged: (v) => saveSettings(context, s.copyWith(showStatusBar: v)),
        ),
        CheckRow(
          label: l10n.settingsShowExtensions,
          value: s.showExtensions,
          onChanged: (v) =>
              saveSettings(context, s.copyWith(showExtensions: v)),
        ),
      ],
    );
  }
}

/// Row of colour dots, as in macOS System Settings ▸ Appearance.
class _AccentPicker extends StatelessWidget {
  const _AccentPicker({required this.value, required this.onChanged});

  final AccentColor value;
  final ValueChanged<AccentColor> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final names = {
      AccentColor.blue: l10n.accentBlue,
      AccentColor.purple: l10n.accentPurple,
      AccentColor.pink: l10n.accentPink,
      AccentColor.red: l10n.accentRed,
      AccentColor.orange: l10n.accentOrange,
      AccentColor.yellow: l10n.accentYellow,
      AccentColor.green: l10n.accentGreen,
      AccentColor.graphite: l10n.accentGraphite,
    };
    return Wrap(
      spacing: 8,
      children: [
        for (final MapEntry(key: accent, value: name) in names.entries)
          Tooltip(
            message: name,
            child: GestureDetector(
              onTap: () => onChanged(accent),
              child: Container(
                width: 22,
                height: 22,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent == value
                        ? context.palette.textSecondary
                        : const Color(0x00000000),
                    width: 2,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: accentSwatch(accent),
                    shape: BoxShape.circle,
                  ),
                  child: accent == value
                      ? const Icon(
                          CupertinoIcons.circle_fill,
                          size: 6,
                          color: Color(0xFFFFFFFF),
                        )
                      : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
