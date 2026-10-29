import 'package:flutter/cupertino.dart';

import '../../l10n/app_localizations.dart';
import '../../models/file_entry.dart';
import '../../models/grouping.dart';
import '../../models/sort_spec.dart';
import '../../theme/finder_theme.dart';
import '../finder_scope.dart';
import '../formatting.dart';
import '../widgets/file_icon.dart';
import '../widgets/rename_field.dart';
import 'view_common.dart';

const _dateWidth = 190.0;
const _sizeWidth = 90.0;
const _kindWidth = 150.0;
const _rowInset = 10.0;

class FileListView extends StatefulWidget {
  const FileListView({super.key});

  @override
  State<FileListView> createState() => _FileListViewState();
}

class _FileListViewState extends State<FileListView> {
  final _scroll = ScrollController();
  String? _revealed;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = FinderScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([scope.browser, scope.contentFocus]),
      builder: (context, _) {
        final b = scope.browser;
        final placeholder = folderPlaceholder(context);
        final rows = groupedRows(b.entries, b.groups);
        _scheduleReveal(rows);
        return Column(
          children: [
            _Header(sort: b.sort),
            Expanded(
              child:
                  placeholder ??
                  ListView.builder(
                    controller: _scroll,
                    itemExtent: FinderMetrics.listRowHeight,
                    itemCount: rows.length,
                    itemBuilder: (context, i) => switch (rows[i]) {
                      (item: final GroupKey key, stripe: _) => GroupHeader(
                        label: groupLabel(context, key),
                        height: FinderMetrics.listRowHeight,
                        inset: _rowInset,
                      ),
                      (item: final FileEntry e, :final stripe) => _Row(
                        entry: e,
                        index: stripe,
                        selected: b.isSelected(e.path),
                        focused: scope.contentFocus.hasFocus,
                        renaming: b.renamingPath == e.path,
                      ),
                      _ => const SizedBox.shrink(),
                    },
                  ),
            ),
          ],
        );
      },
    );
  }

  void _scheduleReveal(List<ListRow> rows) {
    final cursor = FinderScope.of(context).browser.cursor;
    if (cursor == null || cursor == _revealed) return;
    _revealed = cursor;
    final index = rows.indexWhere(
      (r) => r.item is FileEntry && (r.item as FileEntry).path == cursor,
    );
    if (index < 0) return;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => revealRange(
        _scroll,
        index * FinderMetrics.listRowHeight,
        FinderMetrics.listRowHeight,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.sort});

  final SortSpec sort;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Container(
      height: FinderMetrics.listHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: _rowInset),
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
          SizedBox(
            width: _dateWidth,
            child: _HeaderCell(
              sort: sort,
              label: l10n.columnModified,
              field: SortField.modified,
            ),
          ),
          SizedBox(
            width: _sizeWidth,
            child: _HeaderCell(
              sort: sort,
              label: l10n.columnSize,
              field: SortField.size,
              alignEnd: true,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: _kindWidth,
            child: _HeaderCell(
              sort: sort,
              label: l10n.columnKind,
              field: SortField.kind,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.sort,
    required this.label,
    required this.field,
    this.alignEnd = false,
  });

  final SortSpec sort;
  final String label;
  final SortField field;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final b = FinderScope.of(context).browser;
    final palette = context.palette;
    final active = sort.field == field;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => b.sortBy(field),
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

class _Row extends StatelessWidget {
  const _Row({
    required this.entry,
    required this.index,
    required this.selected,
    required this.focused,
    required this.renaming,
  });

  final FileEntry entry;
  final int index;
  final bool selected;
  final bool focused;
  final bool renaming;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final Color? background = selected
        ? (focused ? palette.selection : palette.selectionInactive)
        : (index.isOdd ? palette.rowAlternate : null);
    final primary = selected && focused
        ? palette.textOnAccent
        : palette.textPrimary;
    final secondary = selected && focused
        ? palette.textOnAccent
        : palette.textSecondary;
    TextStyle style(Color c) =>
        TextStyle(fontSize: FinderMetrics.fontSize, color: c);

    return Opacity(
      opacity: isCut(context, entry) || entry.isHidden ? 0.55 : 1,
      child: EntryGestures(
        entry: entry,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: _rowInset - 6),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(FinderMetrics.radiusSmall),
          ),
          child: Row(
            children: [
              FileIcon(entry: entry, size: 16, thumbnail: true),
              const SizedBox(width: 6),
              Expanded(
                child: renaming
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: RenameField(name: entry.name),
                      )
                    : Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style(primary),
                      ),
              ),
              SizedBox(
                width: _dateWidth,
                child: Text(
                  formatModified(context, entry.modified),
                  maxLines: 1,
                  style: style(secondary),
                ),
              ),
              SizedBox(
                width: _sizeWidth,
                child: Text(
                  entry.isDirectory ? '--' : formatBytes(entry.size),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  style: style(secondary),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: _kindWidth,
                child: Text(
                  kindLabel(l10n, entry),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style(secondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
