import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/browser_controller.dart';
import '../../theme/finder_theme.dart';
import '../finder_scope.dart';
import '../widgets/hover_button.dart';
import 'finder_toolbar.dart';
import '../widgets/tag_dots.dart';
import '../widgets/tag_picker.dart';

/// Finder's search scope bar, shown under the toolbar while a query is
/// typed: search the folder's whole tree or only the folder, by name or
/// by name and contents.
class SearchScopeBar extends StatelessWidget {
  const SearchScopeBar({super.key});

  @override
  Widget build(BuildContext context) {
    final b = FinderScope.of(context).browser;
    return ListenableBuilder(
      listenable: b,
      builder: (context, _) {
        if (b.query.trim().isEmpty && b.tag == null) {
          return const SizedBox.shrink();
        }
        final l10n = AppLocalizations.of(context);
        final palette = context.palette;
        final folder = folderTitle(context, b.path);
        Widget option(String label, bool active, VoidCallback onPressed) =>
            HoverButton(
              active: active,
              onPressed: onPressed,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: FinderMetrics.fontSizeSmall + 1,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  color: active ? palette.textPrimary : palette.textSecondary,
                ),
              ),
            );
        return Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: palette.toolbar,
            border: Border(
              bottom: BorderSide(color: palette.separator, width: 0.5),
            ),
          ),
          child: Row(
            spacing: 4,
            children: [
              if (b.tag case final tag?) ...[
                TagDots(tags: [tag], size: 10, ring: tagSwatch(tag)),
                Text(
                  l10n.taggedIn(tagLabel(l10n, tag), folder),
                  style: TextStyle(
                    fontSize: FinderMetrics.fontSizeSmall + 1,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
              ] else ...[
                Text(
                  l10n.searchIn,
                  style: TextStyle(
                    fontSize: FinderMetrics.fontSizeSmall + 1,
                    color: palette.textSecondary,
                  ),
                ),
                Flexible(
                  child: option(
                    l10n.searchScopeSubfolders(folder),
                    b.searchScope == SearchScope.subfolders,
                    () => b.setSearchScope(SearchScope.subfolders),
                  ),
                ),
                option(
                  l10n.searchScopeThisFolder,
                  b.searchScope == SearchScope.thisFolder,
                  () => b.setSearchScope(SearchScope.thisFolder),
                ),
              ],
              const Spacer(),
              if (b.searching)
                const SizedBox.square(
                  dimension: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
              if (b.tag == null && b.searchScope == SearchScope.subfolders) ...[
                option(
                  l10n.searchByName,
                  !b.searchContents,
                  () => b.setSearchContents(false),
                ),
                option(
                  l10n.searchByContents,
                  b.searchContents,
                  () => b.setSearchContents(true),
                ),
              ],
              HoverButton(
                tooltip: l10n.buttonCancel,
                padding: const EdgeInsets.all(3),
                onPressed: () =>
                    b.tag == null ? b.setQuery('') : b.showTagged(null),
                child: Icon(
                  CupertinoIcons.xmark,
                  size: 12,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
