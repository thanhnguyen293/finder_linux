import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/sort_spec.dart';
import '../../theme/finder_theme.dart';
import '../finder_scope.dart';
import '../widgets/finder_menu.dart';
import '../widgets/hover_button.dart';
import '../widgets/window_drag_area.dart';
import 'history_menus.dart';
import 'search_field.dart';

class FinderToolbar extends StatelessWidget {
  const FinderToolbar({super.key, required this.searchFocus});

  final FocusNode searchFocus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scope = FinderScope.of(context);
    final palette = context.palette;
    // The coloured box stays outside the drag area: a painted decoration is
    // hit-testable and would cover the drag layer behind the buttons.
    return Container(
      height: FinderMetrics.toolbarHeight,
      decoration: BoxDecoration(
        color: palette.toolbar,
        border: Border(
          bottom: BorderSide(color: palette.separator, width: 0.5),
        ),
      ),
      child: WindowDragArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListenableBuilder(
            listenable: scope.browser,
            builder: (context, _) {
              final b = scope.browser;
              return Row(
                children: [
                  _WithHistoryMenu(
                    back: true,
                    child: HoverButton(
                      tooltip: l10n.tooltipBack,
                      onPressed: b.canGoBack ? b.back : null,
                      child: const Icon(CupertinoIcons.chevron_left),
                    ),
                  ),
                  _WithHistoryMenu(
                    back: false,
                    child: HoverButton(
                      tooltip: l10n.tooltipForward,
                      onPressed: b.canGoForward ? b.forward : null,
                      child: const Icon(CupertinoIcons.chevron_right),
                    ),
                  ),
                  if (scope.recents != null)
                    HoverButton(
                      tooltip: l10n.tooltipRecentFolders,
                      onPressedAt: (at) => showRecentFoldersMenu(context, at),
                      child: const Icon(CupertinoIcons.clock),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    // Let drags and double-clicks on the title reach the
                    // window drag layer, as on macOS.
                    child: IgnorePointer(
                      child: Text(
                        folderTitle(context, b.path),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  _ViewModeSwitcher(mode: b.viewMode),
                  const SizedBox(width: 6),
                  HoverButton(
                    tooltip: l10n.tooltipGroupSort,
                    onPressedAt: (at) => _showGroupSortMenu(context, at),
                    child: const Icon(CupertinoIcons.arrow_up_arrow_down),
                  ),
                  const SizedBox(width: 10),
                  SearchField(focusNode: searchFocus),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Finder's "Group" toolbar menu: grouping on top, sort order below.
  Future<void> _showGroupSortMenu(BuildContext context, Offset at) async {
    final l10n = AppLocalizations.of(context);
    final b = FinderScope.of(context).browser;
    final groupLabels = {
      GroupBy.none: l10n.groupNone,
      GroupBy.kind: l10n.columnKind,
      GroupBy.modified: l10n.columnModified,
      GroupBy.size: l10n.columnSize,
    };
    final sortLabels = {
      SortField.name: l10n.columnName,
      SortField.kind: l10n.columnKind,
      SortField.modified: l10n.columnModified,
      SortField.size: l10n.columnSize,
    };
    final choice = await showFinderMenu<Object>(context, at.translate(0, 12), [
      menuHeader(context, l10n.menuGroupBy),
      for (final MapEntry(key: g, value: label) in groupLabels.entries)
        menuCheckItem(value: g, label: label, checked: b.groupBy == g),
      const PopupMenuDivider(height: 9),
      menuHeader(context, l10n.menuSortBy),
      for (final MapEntry(key: f, value: label) in sortLabels.entries)
        menuCheckItem(
          value: f,
          label: label,
          checked: b.sort.field == f,
          mark: b.sort.ascending
              ? CupertinoIcons.chevron_up
              : CupertinoIcons.chevron_down,
        ),
    ]);
    switch (choice) {
      case GroupBy g:
        b.setGroupBy(g);
      case SortField f:
        b.sortBy(f);
    }
  }
}

/// Toolbar title / path bar label for a folder.
String folderTitle(BuildContext context, String path) {
  final scope = FinderScope.of(context);
  final l10n = AppLocalizations.of(context);
  if (path == '/') return l10n.placeComputer;
  if (path == scope.sidebar.trashDir) return l10n.placeTrash;
  for (final place in scope.sidebar.favorites) {
    if (place.path == path) return place.label;
  }
  return path.split('/').last;
}

/// Right-click lists the history in that direction.
class _WithHistoryMenu extends StatelessWidget {
  const _WithHistoryMenu({required this.back, required this.child});

  final bool back;
  final Widget child;

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (e) {
      if (e.buttons & kSecondaryMouseButton != 0) {
        showHistoryMenu(context, e.position, back: back);
      }
    },
    child: child,
  );
}

class _ViewModeSwitcher extends StatelessWidget {
  const _ViewModeSwitcher({required this.mode});

  final ViewMode mode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final b = FinderScope.of(context).browser;
    final modes = {
      ViewMode.icons: (CupertinoIcons.square_grid_2x2, l10n.tooltipViewIcons),
      ViewMode.list: (CupertinoIcons.list_bullet, l10n.tooltipViewList),
      ViewMode.columns: (
        CupertinoIcons.rectangle_split_3x1,
        l10n.tooltipViewColumns,
      ),
    };
    return Row(
      spacing: 2,
      children: [
        for (final MapEntry(key: option, value: (icon, tip)) in modes.entries)
          HoverButton(
            tooltip: tip,
            active: mode == option,
            onPressed: () => b.setViewMode(option),
            child: Icon(icon),
          ),
      ],
    );
  }
}
