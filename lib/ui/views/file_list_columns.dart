import 'package:flutter/cupertino.dart';

import '../../l10n/app_localizations.dart';
import '../../models/sort_spec.dart';
import '../../theme/finder_theme.dart';
import '../finder_scope.dart';

const listDateWidth = 190.0;
const listSizeWidth = 90.0;
const listKindWidth = 150.0;
const listRowInset = 10.0;
const _minNameWidth = 200.0;

typedef ListColumns = ({bool date, bool size, bool kind});

/// Columns that fit beside a readable name, dropped Kind first, then Date,
/// then Size as the view narrows (split view, small windows), as Finder
/// does.
ListColumns listColumnsFor(double width) {
  final room = width - _minNameWidth - 2 * listRowInset - 30;
  return (
    size: room >= listSizeWidth,
    date: room >= listSizeWidth + listDateWidth,
    kind: room >= listSizeWidth + listDateWidth + 16 + listKindWidth,
  );
}

class ListHeader extends StatelessWidget {
  const ListHeader({
    super.key,
    required this.sort,
    required this.cols,
    this.location = false,
  });

  final SortSpec sort;
  final ListColumns cols;

  /// Search results from subfolders: the Kind slot shows where each is.
  final bool location;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Container(
      height: context.scaled(FinderMetrics.listHeaderHeight),
      padding: const EdgeInsets.symmetric(horizontal: listRowInset),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: palette.separator, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HeaderCell(
              sort: sort,
              label: l10n.columnName,
              field: SortField.name,
            ),
          ),
          if (cols.date)
            SizedBox(
              width: listDateWidth,
              child: _HeaderCell(
                sort: sort,
                label: l10n.columnModified,
                field: SortField.modified,
              ),
            ),
          if (cols.size)
            SizedBox(
              width: listSizeWidth,
              child: _HeaderCell(
                sort: sort,
                label: l10n.columnSize,
                field: SortField.size,
                alignEnd: true,
              ),
            ),
          if (cols.kind) ...[
            const SizedBox(width: 16),
            SizedBox(
              width: listKindWidth,
              child: location
                  ? _HeaderCell(sort: sort, label: l10n.columnLocation)
                  : _HeaderCell(
                      sort: sort,
                      label: l10n.columnKind,
                      field: SortField.kind,
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.sort,
    required this.label,
    this.field,
    this.alignEnd = false,
  });

  final SortSpec sort;
  final String label;

  /// Null for columns that don't sort.
  final SortField? field;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final b = FinderScope.of(context).browser;
    final palette = context.palette;
    final field = this.field;
    final active = sort.field == field;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: field == null ? null : () => b.sortBy(field),
      child: Row(
        mainAxisAlignment: alignEnd
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        spacing: 4,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: FinderMetrics.fontSizeSmall + 1,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? palette.textPrimary : palette.textSecondary,
              ),
            ),
          ),
          if (active)
            Icon(
              sort.ascending
                  ? CupertinoIcons.chevron_up
                  : CupertinoIcons.chevron_down,
              size: 10,
              color: palette.textSecondary,
            ),
        ],
      ),
    );
  }
}
