import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;

import '../../l10n/app_localizations.dart';
import '../../models/file_entry.dart';
import '../../models/grouping.dart';
import '../../theme/finder_theme.dart';
import '../finder_scope.dart';
import '../formatting.dart';
import '../widgets/file_icon.dart';
import '../widgets/rename_field.dart';
import '../widgets/tag_dots.dart';
import 'file_list_columns.dart';
import 'marquee.dart';
import 'view_common.dart';

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
      listenable: Listenable.merge([
        scope.browser,
        scope.contentFocus,
        scope.actions.clipboard,
      ]),
      builder: (context, _) {
        final b = scope.browser;
        final placeholder = folderPlaceholder(context);
        final rows = groupedRows(b.entries, b.groups);
        _scheduleReveal(rows);
        return LayoutBuilder(
          builder: (context, box) {
            final cols = listColumnsFor(box.maxWidth);
            return Column(
              children: [
                ListHeader(sort: b.sort, cols: cols, location: b.searchesTree),
                Expanded(
                  child:
                      placeholder ??
                      MarqueeSelector(
                        controller: _scroll,
                        hitTest: (rect) => listHits(
                          rect,
                          rows: [
                            for (final r in rows)
                              if (r.item case final FileEntry e)
                                e.path
                              else
                                null,
                          ],
                          rowHeight: context.scaled(
                            FinderMetrics.listRowHeight,
                          ),
                        ),
                        child: ListView.builder(
                          controller: _scroll,
                          itemExtent: context.scaled(
                            FinderMetrics.listRowHeight,
                          ),
                          itemCount: rows.length,
                          itemBuilder: (context, i) => switch (rows[i]) {
                            (item: final GroupKey key, stripe: _) =>
                              GroupHeader(
                                label: groupLabel(context, key),
                                height: context.scaled(
                                  FinderMetrics.listRowHeight,
                                ),
                                inset: listRowInset,
                              ),
                            (item: final FileEntry e, :final stripe) => _Row(
                              cols: cols,
                              location: b.searchesTree
                                  ? folderLabel(b.path, e.path)
                                  : null,
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
                ),
              ],
            );
          },
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
        index * context.scaled(FinderMetrics.listRowHeight),
        context.scaled(FinderMetrics.listRowHeight),
      ),
    );
  }
}

/// Where a search result sits, relative to the searched [root]
/// (empty-looking "." becomes the root's own name).
String folderLabel(String root, String path) {
  final dir = p.relative(p.dirname(path), from: root);
  return dir == '.' ? p.basename(root) : dir;
}

class _Row extends StatelessWidget {
  const _Row({
    required this.cols,
    this.location,
    required this.entry,
    required this.index,
    required this.selected,
    required this.focused,
    required this.renaming,
  });

  final ListColumns cols;

  /// Folder holding a search result, shown instead of its kind.
  final String? location;
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
          padding: const EdgeInsets.symmetric(horizontal: listRowInset - 6),
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
                    : Row(
                        spacing: 6,
                        children: [
                          Flexible(
                            child: Text(
                              displayName(context, entry),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: style(primary),
                            ),
                          ),
                          TagDots(
                            tags: entry.colorTags,
                            ring: background ?? palette.content,
                          ),
                        ],
                      ),
              ),
              if (cols.date)
                SizedBox(
                  width: listDateWidth,
                  child: Text(
                    formatModified(context, entry.modified),
                    maxLines: 1,
                    style: style(secondary),
                  ),
                ),
              if (cols.size)
                SizedBox(
                  width: listSizeWidth,
                  child: Text(
                    entry.isDirectory ? '--' : formatBytes(entry.size),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    style: style(secondary),
                  ),
                ),
              if (cols.kind) ...[
                const SizedBox(width: 16),
                SizedBox(
                  width: listKindWidth,
                  child: Text(
                    location ?? kindLabel(l10n, entry),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style(secondary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
