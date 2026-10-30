import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/file_entry.dart';
import '../../models/grouping.dart';
import '../../theme/finder_theme.dart';
import '../finder_scope.dart';
import '../settings_scope.dart';
import '../formatting.dart';
import '../widgets/file_icon.dart';
import '../widgets/rename_field.dart';
import '../widgets/tag_dots.dart';
import 'marquee.dart';
import 'view_common.dart';

const _gridPadding = 12.0;
const _headerHeight = 34.0;

class IconGridView extends StatefulWidget {
  const IconGridView({super.key, required this.onColumnsChanged});

  /// Reports items-per-row so Up/Down arrows can jump a whole row.
  final ValueChanged<int> onColumnsChanged;

  @override
  State<IconGridView> createState() => _IconGridViewState();
}

class _IconGridViewState extends State<IconGridView> {
  final _scroll = ScrollController();
  String? _revealed;
  double _tileHeight = FinderMetrics.iconTileHeight;

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
      builder: (context, _) => LayoutBuilder(
        builder: (context, box) {
          final iconSize = SettingsScope.of(context).iconSize.toDouble();
          // Room for the icon plus two lines of (scaled) label.
          final tileWidth = iconSize + 40;
          _tileHeight = iconSize + 24 + context.scaled(32);
          final columns = math.max(
            1,
            (box.maxWidth - 2 * _gridPadding) ~/ tileWidth,
          );
          widget.onColumnsChanged(columns);
          final placeholder = folderPlaceholder(context);
          if (placeholder != null) return placeholder;
          final b = scope.browser;
          final sections = <_Section>[
            if (b.groups.isEmpty)
              (key: null, entries: b.entries)
            else
              for (final g in b.groups) (key: g.key, entries: g.entries),
          ];
          _scheduleReveal(sections, columns);
          return MarqueeSelector(
            controller: _scroll,
            hitTest: (rect) => gridHits(
              rect,
              sections: [
                for (final section in sections)
                  (
                    header: section.key != null,
                    paths: [for (final e in section.entries) e.path],
                  ),
              ],
              columns: columns,
              // SliverGrid stretches the cells over the padded width.
              cellWidth: (box.maxWidth - 2 * _gridPadding) / columns,
              tileHeight: _tileHeight,
              padding: _gridPadding,
              headerHeight: _headerHeight,
            ),
            child: CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(_gridPadding),
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      for (final section in sections) ...[
                        if (section.key case final key?)
                          SliverToBoxAdapter(
                            child: GroupHeader(
                              label: groupLabel(context, key),
                              height: _headerHeight,
                            ),
                          ),
                        SliverGrid.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisExtent: _tileHeight,
                              ),
                          itemCount: section.entries.length,
                          itemBuilder: (context, i) {
                            final e = section.entries[i];
                            return _IconTile(
                              entry: e,
                              iconSize: iconSize,
                              selected: b.isSelected(e.path),
                              focused: scope.contentFocus.hasFocus,
                              renaming: b.renamingPath == e.path,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Keeps the keyboard cursor on screen after arrow-key moves.
  void _scheduleReveal(List<_Section> sections, int columns) {
    final cursor = FinderScope.of(context).browser.cursor;
    if (cursor == null || cursor == _revealed) return;
    _revealed = cursor;
    var top = _gridPadding;
    for (final section in sections) {
      if (section.key != null) top += _headerHeight;
      final index = section.entries.indexWhere((e) => e.path == cursor);
      if (index >= 0) {
        top += (index ~/ columns) * _tileHeight;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => revealRange(_scroll, top, _tileHeight),
        );
        return;
      }
      top += (section.entries.length / columns).ceil() * _tileHeight;
    }
  }
}

/// One run of tiles; [key] is null when grouping is off.
typedef _Section = ({GroupKey? key, List<FileEntry> entries});

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.entry,
    required this.iconSize,
    required this.selected,
    required this.focused,
    required this.renaming,
  });

  final FileEntry entry;
  final double iconSize;
  final bool selected;
  final bool focused;
  final bool renaming;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final labelBg = selected
        ? (focused ? palette.selection : palette.selectionInactive)
        : null;
    final labelColor = selected && focused
        ? palette.textOnAccent
        : palette.textPrimary;
    return Opacity(
      opacity: isCut(context, entry) || entry.isHidden ? 0.5 : 1,
      child: EntryGestures(
        entry: entry,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Container(
                width: iconSize + 12,
                height: iconSize + 8,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? palette.controlHover : null,
                  borderRadius: BorderRadius.circular(
                    FinderMetrics.radiusSmall,
                  ),
                ),
                child: FileIcon(entry: entry, size: iconSize, thumbnail: true),
              ),
              const SizedBox(height: 4),
              if (renaming)
                RenameField(name: entry.name, textAlign: TextAlign.center)
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: labelBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: displayName(context, entry),
                      children: [
                        if (entry.colorTags case final tags
                            when tags.isNotEmpty)
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: TagDots(
                                tags: tags,
                                size: 8,
                                ring: labelBg ?? palette.content,
                              ),
                            ),
                          ),
                      ],
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: labelColor,
                      height: 1.25,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
