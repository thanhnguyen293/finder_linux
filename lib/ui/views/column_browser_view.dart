import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;

import '../../core/result.dart';
import '../../models/file_entry.dart';
import '../../models/grouping.dart';
import '../../theme/finder_theme.dart';
import '../dnd/file_drag.dart';
import '../finder_scope.dart';
import '../formatting.dart';
import '../widgets/file_icon.dart';
import '../widgets/rename_field.dart';
import 'column_preview_pane.dart';
import 'view_common.dart';

const _minPreviewWidth = 280.0;

/// Miller columns: one column per folder from the location root down to the
/// current folder, plus the selected folder's contents or a file preview.
class ColumnBrowserView extends StatelessWidget {
  const ColumnBrowserView({super.key});

  /// Folders from the column root down to [path].
  List<String> _chain(String path, String root) {
    final parts = path == root
        ? const <String>[]
        : p.split(p.relative(path, from: root));
    return [
      for (var i = 0; i <= parts.length; i++)
        p.joinAll([root, ...parts.take(i)]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scope = FinderScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([scope.browser, scope.contentFocus]),
      builder: (context, _) {
        final b = scope.browser;
        final chain = _chain(b.path, b.columnRoot);
        final selected = b.selectedEntries;
        final single = selected.length == 1 ? selected.first : null;
        final columns = <Widget>[
          for (var i = 0; i < chain.length - 1; i++)
            _FolderColumn(
              key: ValueKey(chain[i]),
              dir: chain[i],
              highlighted: chain[i + 1],
            ),
          _CurrentColumn(
            entries: b.entries,
            groups: b.groups,
            focused: scope.contentFocus.hasFocus,
          ),
          if (single != null && single.isDirectory)
            _FolderColumn(key: ValueKey(single.path), dir: single.path),
        ];
        final preview = single != null && !single.isDirectory ? single : null;
        // A reversed scroll view starts at its end, so the deepest columns are
        // visible in the first frame; scrolling to the end after layout made
        // the view jump. The minimum width keeps short chains left-aligned.
        return LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: box.maxWidth),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...columns,
                  if (preview != null)
                    ColumnPreviewPane(
                      entry: preview,
                      // Like Finder, the preview takes the width the columns
                      // leave instead of sitting in a narrow fixed column.
                      width: math.max(
                        _minPreviewWidth,
                        box.maxWidth -
                            columns.length * FinderMetrics.columnWidth,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A column; when [dropDir] is set, files dropped on its empty space or on
/// a file row move into that folder.
class _ColumnFrame extends StatelessWidget {
  const _ColumnFrame({required this.child, this.dropDir});

  final Widget child;
  final String? dropDir;

  @override
  Widget build(BuildContext context) {
    Widget frame(bool hovering) => Container(
      width: FinderMetrics.columnWidth,
      decoration: BoxDecoration(
        color: hovering ? context.palette.accent.withValues(alpha: 0.12) : null,
        border: Border(
          right: BorderSide(color: context.palette.separator, width: 0.5),
        ),
      ),
      child: child,
    );
    final dir = dropDir;
    if (dir == null) return frame(false);
    return FolderDropTarget(
      dir: dir,
      builder: (context, hovering) => frame(hovering),
    );
  }
}

class _CurrentColumn extends StatelessWidget {
  const _CurrentColumn({
    required this.entries,
    required this.groups,
    required this.focused,
  });

  final List<FileEntry> entries;
  final List<EntryGroup> groups;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final b = FinderScope.of(context).browser;
    return _ColumnFrame(
      dropDir: b.path,
      child:
          folderPlaceholder(context) ??
          _ColumnList(
            rows: groupedRows(entries, groups),
            row: (e) => EntryGestures(
              entry: e,
              child: _ColumnRow(
                entry: e,
                highlight: b.isSelected(e.path),
                focused: focused,
                renaming: b.renamingPath == e.path,
              ),
            ),
          ),
    );
  }
}

/// Rows of one column, with group headers when the window groups items.
class _ColumnList extends StatelessWidget {
  const _ColumnList({required this.rows, required this.row});

  final List<ListRow> rows;
  final Widget Function(FileEntry entry) row;

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.symmetric(vertical: 4),
    itemExtent: context.scaled(FinderMetrics.listRowHeight),
    itemCount: rows.length,
    itemBuilder: (context, i) => switch (rows[i].item) {
      final GroupKey key => GroupHeader(
        label: groupLabel(context, key),
        height: context.scaled(FinderMetrics.listRowHeight),
        inset: 10,
      ),
      final FileEntry e => row(e),
      _ => const SizedBox.shrink(),
    },
  );
}

/// A folder other than the current one; clicking an item makes this
/// folder current with that item selected.
class _FolderColumn extends StatefulWidget {
  const _FolderColumn({super.key, required this.dir, this.highlighted});

  final String dir;
  final String? highlighted;

  @override
  State<_FolderColumn> createState() => _FolderColumnState();
}

class _FolderColumnState extends State<_FolderColumn> {
  Future<Result<List<FileEntry>>>? _listing;
  int _revision = -1;

  @override
  Widget build(BuildContext context) {
    final b = FinderScope.of(context).browser;
    if (b.revision != _revision) {
      _revision = b.revision;
      _listing = b.listDir(widget.dir);
    }
    return _ColumnFrame(
      dropDir: widget.dir,
      child: FutureBuilder<Result<List<FileEntry>>>(
        future: _listing,
        initialData: switch (b.cachedListing(widget.dir)) {
          final cached? => Ok(cached),
          null => null,
        },
        builder: (context, snap) {
          final entries = switch (snap.data) {
            Ok(:final value) => value,
            _ => const <FileEntry>[],
          };
          return _ColumnList(
            rows: groupedRows(entries, b.groupsFor(entries)),
            row: (e) => EntryGestures(
              entry: e,
              // Clicking in another folder's column makes that folder
              // current with the item selected.
              onClick: () => b.navigate(widget.dir, select: e.path),
              child: _ColumnRow(
                entry: e,
                highlight: e.path == widget.highlighted,
                focused: false,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ColumnRow extends StatelessWidget {
  const _ColumnRow({
    required this.entry,
    required this.highlight,
    required this.focused,
    this.renaming = false,
  });

  final FileEntry entry;
  final bool highlight;
  final bool focused;
  final bool renaming;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final onAccent = highlight && focused;
    return Opacity(
      opacity: entry.isHidden ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: highlight
              ? (focused ? palette.selection : palette.selectionInactive)
              : null,
          borderRadius: BorderRadius.circular(FinderMetrics.radiusSmall),
        ),
        child: Row(
          spacing: 6,
          children: [
            FileIcon(entry: entry, size: 16, thumbnail: true),
            Expanded(
              child: renaming
                  ? RenameField(name: entry.name)
                  : Text(
                      displayName(context, entry),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: FinderMetrics.fontSize,
                        color: onAccent
                            ? palette.textOnAccent
                            : palette.textPrimary,
                      ),
                    ),
            ),
            if (entry.isDirectory)
              Icon(
                CupertinoIcons.chevron_right,
                size: 11,
                color: onAccent ? palette.textOnAccent : palette.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
