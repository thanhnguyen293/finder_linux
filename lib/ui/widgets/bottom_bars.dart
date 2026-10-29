import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;

import '../../l10n/app_localizations.dart';
import '../../theme/finder_theme.dart';
import '../commands.dart';
import '../dnd/file_drag.dart';
import '../finder_scope.dart';
import '../formatting.dart';
import '../toolbar/finder_toolbar.dart';
import 'file_icon.dart';

/// Breadcrumbs of the current folder (Finder's View ▸ Show Path Bar).
class PathBar extends StatelessWidget {
  const PathBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = FinderScope.of(context);
    final palette = context.palette;
    return Container(
      height: context.scaled(FinderMetrics.pathBarHeight),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: palette.toolbar,
        border: Border(top: BorderSide(color: palette.separator, width: 0.5)),
      ),
      child: ListenableBuilder(
        listenable: scope.browser,
        builder: (context, _) {
          final path = scope.browser.path;
          final parts = p.split(path);
          final crumbs = [
            for (var i = 1; i <= parts.length; i++) p.joinAll(parts.take(i)),
          ];
          final selected = scope.browser.selectedEntries;
          // Reversed so long paths show their end; the minimum width keeps
          // short paths left-aligned, as in Finder.
          return LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: box.maxWidth),
                child: Row(
                  children: [
                    for (final (i, crumb) in crumbs.indexed) ...[
                      if (i > 0)
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 9,
                          color: palette.textSecondary,
                        ),
                      FolderDropTarget(
                        dir: crumb,
                        builder: (context, hovering) => DecoratedBox(
                          decoration: hovering
                              ? dropHighlight(context)
                              : const BoxDecoration(),
                          child: _Crumb(
                            label: folderTitle(context, crumb),
                            icon: Icon(
                              CupertinoIcons.folder_fill,
                              size: 14,
                              color: palette.folder,
                            ),
                            onTap: () => FinderCommands(context).goTo(crumb),
                          ),
                        ),
                      ),
                    ],
                    if (selected.length == 1) ...[
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 9,
                        color: palette.textSecondary,
                      ),
                      _Crumb(
                        label: displayName(context, selected.first),
                        icon: FileIcon(entry: selected.first, size: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Crumb extends StatefulWidget {
  const _Crumb({required this.label, required this.icon, this.onTap});

  final String label;
  final Widget icon;
  final VoidCallback? onTap;

  @override
  State<_Crumb> createState() => _CrumbState();
}

class _CrumbState extends State<_Crumb> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final clickable = widget.onTap != null;
    return MouseRegion(
      cursor: clickable ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: _hover && clickable ? palette.controlHover : null,
            borderRadius: BorderRadius.circular(FinderMetrics.radiusSmall),
          ),
          child: Row(
            spacing: 4,
            children: [
              widget.icon,
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: FinderMetrics.fontSizeSmall + 0.5,
                  color: _hover && clickable
                      ? palette.textPrimary
                      : palette.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
