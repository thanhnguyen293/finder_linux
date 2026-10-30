import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../l10n/app_localizations.dart';
import '../../theme/finder_theme.dart';
import '../commands.dart';
import '../finder_scope.dart';
import '../widgets/finder_menu.dart';
import 'finder_toolbar.dart';

PopupMenuItem<T> _folderItem<T>(
  BuildContext context,
  T value,
  String path, {
  bool showParent = false,
}) {
  final palette = context.palette;
  return PopupMenuItem<T>(
    value: value,
    height: 26,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Row(
        spacing: 8,
        children: [
          Icon(CupertinoIcons.folder_fill, size: 14, color: palette.folder),
          Flexible(
            child: Text(
              folderTitle(context, path),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: FinderMetrics.fontSize),
            ),
          ),
          if (showParent && path != '/')
            Flexible(
              child: Text(
                p.dirname(path),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: FinderMetrics.fontSizeSmall,
                  color: palette.textSecondary,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Right-click on Back / Forward: the folders that way, nearest first,
/// as in a browser.
Future<void> showHistoryMenu(
  BuildContext context,
  Offset at, {
  required bool back,
}) async {
  final b = FinderScope.of(context).browser;
  final folders = back ? b.backHistory : b.forwardHistory;
  if (folders.isEmpty) return;
  final steps = await showFinderMenu<int>(context, at, [
    for (final (i, path) in folders.indexed)
      _folderItem(context, back ? i + 1 : -(i + 1), path),
  ]);
  if (steps != null) await b.jumpHistory(steps);
}

/// Toolbar clock button: folders recently opened in any window.
Future<void> showRecentFoldersMenu(BuildContext context, Offset at) async {
  final scope = FinderScope.of(context);
  final recents = scope.recents;
  if (recents == null) return;
  final folders = await recents.load();
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context);
  const clear = '';
  final chosen = await showFinderMenu<String>(context, at.translate(0, 12), [
    if (folders.isEmpty)
      PopupMenuItem<String>(
        enabled: false,
        height: 26,
        child: Text(
          l10n.recentNone,
          style: const TextStyle(fontSize: FinderMetrics.fontSize),
        ),
      ),
    for (final path in folders)
      _folderItem(context, path, path, showParent: true),
    if (folders.isNotEmpty) ...[
      const PopupMenuDivider(height: 9),
      PopupMenuItem<String>(
        value: clear,
        height: 26,
        child: Text(
          l10n.menuClearRecents,
          style: const TextStyle(fontSize: FinderMetrics.fontSize),
        ),
      ),
    ],
  ]);
  if (chosen == null || !context.mounted) return;
  if (chosen == clear) {
    await recents.clear();
  } else {
    await FinderCommands(context).goTo(chosen);
  }
}
