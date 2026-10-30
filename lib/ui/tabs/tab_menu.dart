import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/finder_theme.dart';
import '../commands.dart';
import '../finder_scope.dart';
import '../widgets/finder_menu.dart';

/// Right-click menu of a tab.
Future<void> showTabMenu(BuildContext context, Offset at, int index) async {
  final l10n = AppLocalizations.of(context);
  final cmd = FinderCommands(context);
  final tabs = FinderScope.of(context).tabs;
  final many = tabs.tabs.length > 1;
  final tab = tabs.tabs[index];
  PopupMenuItem<VoidCallback> item(String label, VoidCallback? run) =>
      PopupMenuItem(
        value: run,
        enabled: run != null,
        height: 26,
        child: Text(
          label,
          style: const TextStyle(fontSize: FinderMetrics.fontSize),
        ),
      );
  final chosen = await showFinderMenu<VoidCallback>(context, at, [
    item(l10n.tooltipNewTab, cmd.newTab),
    const PopupMenuDivider(height: 9),
    item(l10n.tooltipCloseTab, () => cmd.closeTab(index)),
    item(
      l10n.menuCloseOtherTabs,
      many ? () => cmd.closeOtherTabs(index) : null,
    ),
    item(
      l10n.menuMoveTabToNewWindow,
      many ? () => cmd.moveTabToNewWindow(index) : null,
    ),
    if (tabs.isInSplit(tab))
      item(l10n.menuExitSplitView, tabs.unsplit)
    else
      item(l10n.menuSplitView, many ? () => tabs.splitWith(tab) : null),
    const PopupMenuDivider(height: 9),
    item(l10n.menuMergeAllWindows, cmd.mergeAllWindows),
  ]);
  chosen?.call();
}
