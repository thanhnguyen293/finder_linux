import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../../core/locations.dart';
import '../../core/result.dart';
import '../../models/file_entry.dart';
import '../../theme/finder_theme.dart';
import '../commands.dart';
import '../dnd/file_drag.dart';
import '../finder_scope.dart';
import '../formatting.dart';
import '../toolbar/finder_toolbar.dart';
import 'file_icon.dart';
import 'finder_menu.dart';

/// Breadcrumbs of the current folder (Finder's View ▸ Show Path Bar).
/// Each chevron opens a menu of the folders inside the crumb before it;
/// clicking the empty part (or Ctrl+L) turns the bar into a text field.
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
          if (scope.browser.editingLocation) return const _LocationField();
          final path = scope.browser.path;
          final parts = p.split(path);
          final crumbs = [
            for (var i = 1; i <= parts.length; i++) p.joinAll(parts.take(i)),
          ];
          final selected = scope.browser.selectedEntries;
          // Reversed so long paths show their end; the minimum width keeps
          // short paths left-aligned, as in Finder.
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => scope.browser.setEditingLocation(true),
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: box.maxWidth),
                  child: Row(
                    children: [
                      for (final (i, crumb) in crumbs.indexed) ...[
                        if (i > 0) _Chevron(folder: crumbs[i - 1]),
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
                      _Chevron(folder: path),
                      if (selected.length == 1)
                        _Crumb(
                          label: displayName(context, selected.first),
                          icon: FileIcon(entry: selected.first, size: 14),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Separator that drills down: lists [folder]'s subfolders to jump into.
class _Chevron extends StatefulWidget {
  const _Chevron({required this.folder});

  final String folder;

  @override
  State<_Chevron> createState() => _ChevronState();
}

class _ChevronState extends State<_Chevron> {
  bool _hover = false;

  Future<void> _open(Offset at) async {
    final b = FinderScope.of(context).browser;
    final listing = await b.listDir(widget.folder);
    if (!mounted) return;
    final folders = switch (listing) {
      Ok(:final value) => [
        for (final e in value)
          if (e.isDirectory) e,
      ],
      Err() => const <FileEntry>[],
    };
    if (folders.isEmpty) return;
    final palette = context.palette;
    final chosen = await showFinderMenu<String>(context, at, [
      for (final f in folders)
        PopupMenuItem<String>(
          value: f.path,
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            spacing: 8,
            children: [
              Icon(CupertinoIcons.folder_fill, size: 14, color: palette.folder),
              Flexible(
                child: Text(
                  f.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: FinderMetrics.fontSize),
                ),
              ),
            ],
          ),
        ),
    ]);
    if (chosen != null && mounted) await FinderCommands(context).goTo(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapUp: (d) => _open(d.globalPosition),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          decoration: BoxDecoration(
            color: _hover ? palette.controlHover : null,
            borderRadius: BorderRadius.circular(FinderMetrics.radiusSmall),
          ),
          child: Icon(
            CupertinoIcons.chevron_right,
            size: 9,
            color: _hover ? palette.textPrimary : palette.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// The path bar while typing a location: Enter opens it, Tab completes
/// folder names, Escape (or leaving the field) cancels.
class _LocationField extends StatefulWidget {
  const _LocationField();

  @override
  State<_LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<_LocationField> {
  late final _text = TextEditingController();
  final _focus = FocusNode(debugLabel: 'location');
  late FinderScope _scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = FinderScope.of(context);
  }

  @override
  void initState() {
    super.initState();
    final path = FinderScope.of(context).browser.path;
    _text.value = TextEditingValue(
      text: path == '/' ? '/' : '$path/',
      selection: TextSelection(baseOffset: 0, extentOffset: path.length + 1),
    );
    _focus.addListener(() {
      if (!_focus.hasFocus) _close();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _close() {
    _scope.browser.setEditingLocation(false);
    _scope.contentFocus.requestFocus();
  }

  Future<void> _submit(String value) async {
    final target = resolveLocation(
      value,
      home: _scope.sidebar.home,
      current: _scope.browser.path,
    );
    final commands = FinderCommands(context);
    _close();
    await commands.openLocation(target);
  }

  void _complete() {
    final completed = completeLocation(
      _text.text,
      home: _scope.sidebar.home,
      current: _scope.browser.path,
    );
    if (completed == null) return;
    _text.value = TextEditingValue(
      text: completed,
      selection: TextSelection.collapsed(offset: completed.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _close,
        const SingleActivator(LogicalKeyboardKey.tab): _complete,
      },
      child: Center(
        child: TextField(
          controller: _text,
          focusNode: _focus,
          onSubmitted: _submit,
          style: TextStyle(
            fontSize: FinderMetrics.fontSizeSmall + 1,
            color: palette.textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: palette.content,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FinderMetrics.radiusSmall),
              borderSide: BorderSide(color: palette.accent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FinderMetrics.radiusSmall),
              borderSide: BorderSide(color: palette.accent, width: 1.5),
            ),
          ),
        ),
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
