import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/finder_theme.dart';
import '../widgets/hover_button.dart';
import 'settings_pages.dart';

/// Finder ▸ Settings: a small window with icon tabs. Changes apply as soon
/// as they are made, so there is no Save button.
Future<void> showFinderSettings(BuildContext context) => showDialog<void>(
  context: context,
  barrierColor: Colors.black26,
  builder: (_) => const _SettingsWindow(),
);

enum _Tab { general, sidebar, advanced }

class _SettingsWindow extends StatefulWidget {
  const _SettingsWindow();

  @override
  State<_SettingsWindow> createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<_SettingsWindow> {
  _Tab _tab = _Tab.general;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final tabs = {
      _Tab.general: (CupertinoIcons.gear_alt, l10n.settingsGeneral),
      _Tab.sidebar: (CupertinoIcons.sidebar_left, l10n.settingsSidebar),
      _Tab.advanced: (
        CupertinoIcons.slider_horizontal_3,
        l10n.settingsAdvanced,
      ),
    };
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: palette.toolbar,
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      HoverButton(
                        padding: const EdgeInsets.all(4),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Icon(CupertinoIcons.xmark, size: 13),
                      ),
                      Expanded(
                        child: Text(
                          tabs[_tab]?.$2 ?? l10n.settingsTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: FinderMetrics.fontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 26),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 4,
                    children: [
                      for (final MapEntry(key: tab, value: (icon, label))
                          in tabs.entries)
                        _TabButton(
                          icon: icon,
                          label: label,
                          selected: tab == _tab,
                          onTap: () => setState(() => _tab = tab),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 0.5, thickness: 0.5, color: palette.separator),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              // All pages stay laid out so the window is as tall as the
              // tallest one and doesn't jump when switching tabs.
              child: IndexedStack(
                index: _tab.index,
                children: const [
                  GeneralSettingsPage(),
                  SidebarSettingsPage(),
                  AdvancedSettingsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = selected ? palette.accent : palette.textSecondary;
    return HoverButton(
      active: selected,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      onPressed: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          spacing: 3,
          children: [
            Icon(icon, size: 22, color: color),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: FinderMetrics.fontSizeSmall,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
