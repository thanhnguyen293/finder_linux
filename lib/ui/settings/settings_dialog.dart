import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/finder_theme.dart';
import '../widgets/glass_panel.dart';
import '../widgets/hover_button.dart';
import 'settings_display_page.dart';
import 'settings_pages.dart';
import 'settings_theme_page.dart';

/// Finder ▸ Settings: a small window with icon tabs. Changes apply as soon
/// as they are made, so there is no Save button.
/// [showUpdates] opens on the page with the update controls.
Future<void> showFinderSettings(
  BuildContext context, {
  bool showUpdates = false,
}) => showDialog<void>(
  context: context,
  barrierColor: Colors.black26,
  builder: (_) =>
      _SettingsWindow(initial: showUpdates ? _Tab.advanced : _Tab.general),
);

enum _Tab { general, display, theme, sidebar, advanced }

class _SettingsWindow extends StatefulWidget {
  const _SettingsWindow({required this.initial});

  final _Tab initial;

  @override
  State<_SettingsWindow> createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<_SettingsWindow> {
  late _Tab _tab = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final tabs = {
      _Tab.general: (CupertinoIcons.gear_alt, l10n.settingsGeneral),
      _Tab.display: (CupertinoIcons.textformat_size, l10n.settingsDisplay),
      _Tab.theme: (CupertinoIcons.paintbrush, l10n.settingsTheme),
      _Tab.sidebar: (CupertinoIcons.sidebar_left, l10n.settingsSidebar),
      _Tab.advanced: (
        CupertinoIcons.slider_horizontal_3,
        l10n.settingsAdvanced,
      ),
    };
    final glass = palette.glass;
    Widget window = SizedBox(
      width: 640,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            // On glass the whole window is one frosted pane.
            color: glass ? null : palette.toolbar,
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
                DisplaySettingsPage(),
                ThemeSettingsPage(),
                SidebarSettingsPage(),
                AdvancedSettingsPage(),
              ],
            ),
          ),
        ],
      ),
    );
    if (glass) {
      window = GlassPanel(
        tint: Theme.of(context).colorScheme.surface,
        child: window,
      );
    }
    return Dialog(
      clipBehavior: Clip.antiAlias,
      backgroundColor: glass ? Colors.transparent : null,
      elevation: glass ? 0 : null,
      child: window,
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
