import 'package:flutter/material.dart';

import '../../core/result.dart';
import '../../l10n/app_localizations.dart';
import '../../models/finder_settings.dart';
import '../../models/place.dart';
import '../../models/sort_spec.dart';
import '../../theme/finder_theme.dart';
import '../formatting.dart';
import '../settings_scope.dart';
import '../sidebar/finder_sidebar.dart';
import 'settings_controls.dart';

/// Order of the sidebar toggles, matching the sidebar itself.
const _sidebarKinds = [
  PlaceKind.home,
  PlaceKind.desktop,
  PlaceKind.documents,
  PlaceKind.downloads,
  PlaceKind.pictures,
  PlaceKind.music,
  PlaceKind.videos,
  PlaceKind.bookmark,
  PlaceKind.computer,
  PlaceKind.volume,
  PlaceKind.trash,
];

/// Saves [next]; a failed write is reported but the change stays applied.
Future<void> _save(BuildContext context, FinderSettings next) async {
  final result = await SettingsScope.read(context).update(next);
  if (result case Err(:final failure) when context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(failureMessage(AppLocalizations.of(context), failure)),
      ),
    );
  }
}

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = SettingsScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingRow(
          label: l10n.settingsNewWindowsShow,
          child: PopupField(
            value: s.newWindowFolder,
            options: {
              for (final k in newWindowFolderChoices) k: placeName(l10n, k),
            },
            onChanged: (v) => _save(context, s.copyWith(newWindowFolder: v)),
          ),
        ),
        SettingRow(
          label: l10n.settingsDefaultView,
          child: PopupField(
            value: s.viewMode,
            options: {
              ViewMode.icons: l10n.viewIcons,
              ViewMode.list: l10n.viewList,
              ViewMode.columns: l10n.viewColumns,
            },
            onChanged: (v) => _save(context, s.copyWith(viewMode: v)),
          ),
        ),
        SettingRow(
          label: '${l10n.menuGroupBy}:',
          child: PopupField(
            value: s.groupBy,
            options: {
              GroupBy.none: l10n.groupNone,
              GroupBy.kind: l10n.columnKind,
              GroupBy.modified: l10n.columnModified,
              GroupBy.size: l10n.columnSize,
            },
            onChanged: (v) => _save(context, s.copyWith(groupBy: v)),
          ),
        ),
        SettingRow(
          label: '${l10n.menuSortBy}:',
          child: PopupField(
            value: s.sortField,
            options: {
              SortField.name: l10n.columnName,
              SortField.kind: l10n.columnKind,
              SortField.modified: l10n.columnModified,
              SortField.size: l10n.columnSize,
            },
            onChanged: (v) => _save(context, s.copyWith(sortField: v)),
          ),
        ),
        const SizedBox(height: 12),
        SettingRow(
          label: l10n.settingsAppearance,
          child: PopupField(
            value: s.appearance,
            options: {
              AppearanceMode.system: l10n.appearanceSystem,
              AppearanceMode.light: l10n.appearanceLight,
              AppearanceMode.dark: l10n.appearanceDark,
            },
            onChanged: (v) => _save(context, s.copyWith(appearance: v)),
          ),
        ),
        SettingRow(
          label: l10n.settingsLanguage,
          child: PopupField<String?>(
            value: s.languageCode,
            // Language names stay in their own language, as on macOS.
            options: {
              null: l10n.languageSystem,
              'en': 'English',
              'vi': 'Tiếng Việt',
            },
            onChanged: (v) => _save(context, s.copyWith(languageCode: () => v)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.settingsNewWindowsNote,
          style: TextStyle(
            fontSize: FinderMetrics.fontSizeSmall,
            color: context.palette.textSecondary,
          ),
        ),
      ],
    );
  }
}

class SidebarSettingsPage extends StatelessWidget {
  const SidebarSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = SettingsScope.of(context);
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsShowInSidebar,
          style: const TextStyle(fontSize: FinderMetrics.fontSize),
        ),
        const SizedBox(height: 8),
        for (final kind in _sidebarKinds)
          CheckRow(
            label: placeName(l10n, kind),
            leading: Icon(placeIcons[kind], size: 15, color: palette.accent),
            value: !s.hiddenPlaces.contains(kind),
            onChanged: (show) => _save(
              context,
              s.copyWith(
                hiddenPlaces: show
                    ? (s.hiddenPlaces.toSet()..remove(kind))
                    : {...s.hiddenPlaces, kind},
              ),
            ),
          ),
      ],
    );
  }
}

class AdvancedSettingsPage extends StatelessWidget {
  const AdvancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = SettingsScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckRow(
          label: l10n.settingsShowHidden,
          value: s.showHidden,
          onChanged: (v) => _save(context, s.copyWith(showHidden: v)),
        ),
        CheckRow(
          label: l10n.settingsFoldersOnTop,
          value: s.foldersFirst,
          onChanged: (v) => _save(context, s.copyWith(foldersFirst: v)),
        ),
        CheckRow(
          label: l10n.settingsThumbnails,
          value: s.showThumbnails,
          onChanged: (v) => _save(context, s.copyWith(showThumbnails: v)),
        ),
        CheckRow(
          label: l10n.settingsWarnEmptyTrash,
          value: s.warnBeforeEmptyingTrash,
          onChanged: (v) =>
              _save(context, s.copyWith(warnBeforeEmptyingTrash: v)),
        ),
      ],
    );
  }
}
