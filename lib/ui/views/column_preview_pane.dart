import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../../models/file_entry.dart';
import '../../theme/finder_theme.dart';
import '../formatting.dart';
import '../widgets/file_icon.dart';

/// Last column of the column view when a single file is selected.
class ColumnPreviewPane extends StatelessWidget {
  const ColumnPreviewPane({
    super.key,
    required this.entry,
    required this.width,
  });

  final FileEntry entry;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final secondary = TextStyle(
      fontSize: FinderMetrics.fontSizeSmall + 1,
      color: palette.textSecondary,
    );
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          spacing: 6,
          children: [
            FileIcon(entry: entry, size: 160, thumbnail: true),
            const SizedBox(height: 8),
            Text(
              entry.name,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              '${kindLabel(l10n, entry)} — ${formatBytes(entry.size)}',
              style: secondary,
            ),
            Text(formatModified(context, entry.modified), style: secondary),
          ],
        ),
      ),
    );
  }
}
