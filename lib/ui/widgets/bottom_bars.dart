import 'package:flutter/cupertino.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/finder_theme.dart';
import '../finder_scope.dart';
import '../formatting.dart';

/// "12 items, 40.2 GB available".
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scope = FinderScope.of(context);
    final palette = context.palette;
    return Container(
      height: context.scaled(FinderMetrics.statusBarHeight),
      decoration: BoxDecoration(
        color: palette.toolbar,
        border: Border(top: BorderSide(color: palette.separator, width: 0.5)),
      ),
      alignment: Alignment.center,
      child: ListenableBuilder(
        listenable: scope.browser,
        builder: (context, _) {
          final b = scope.browser;
          final count = b.entries.length;
          final selected = b.selection.length;
          final parts = [
            selected > 0
                ? l10n.selectedOfCount(selected, count)
                : l10n.itemCount(count),
            if (b.freeBytes case final free?)
              l10n.spaceAvailable(formatBytes(free)),
          ];
          return Text(
            parts.join(', '),
            style: TextStyle(
              fontSize: FinderMetrics.fontSizeSmall,
              color: palette.textSecondary,
            ),
          );
        },
      ),
    );
  }
}
