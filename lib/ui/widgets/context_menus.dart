import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/file_entry.dart';
import '../../models/place.dart';
import '../../models/tag_color.dart';
import '../../theme/finder_theme.dart';
import '../commands.dart';
import '../finder_scope.dart';
import 'finder_menu.dart';
import 'tag_picker.dart';

/// Width of a context menu item's label + shortcut. With the 14 px side
/// padding the item is 224 px, a whole multiple of the 56 px steps
/// Material rounds menu widths up to, so no empty strip trails the
/// shortcuts.
const contextMenuContentWidth = 196.0;

class _Action {
  const _Action(this.label, this.run, {this.shortcut});
  final String label;
  final VoidCallback? run;
  final String? shortcut;
}

/// `null` entries render as separators; [PopupMenuEntry]s (the tag row)
/// pass through.
Future<void> _show(
  BuildContext context,
  Offset at,
  List<Object?> actions,
) async {
  final palette = context.palette;
  final chosen = await showFinderMenu<VoidCallback>(context, at, [
    for (final a in actions)
      if (a == null)
        const PopupMenuDivider(height: 9)
      else if (a is PopupMenuEntry<VoidCallback>)
        a
      else if (a is _Action)
        PopupMenuItem<VoidCallback>(
          value: a.run,
          enabled: a.run != null,
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: SizedBox(
            width: contextMenuContentWidth,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    a.label,
                    style: const TextStyle(fontSize: FinderMetrics.fontSize),
                  ),
                ),
                if (a.shortcut != null)
                  Text(
                    a.shortcut!,
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
  ]);
  chosen?.call();
}

Future<void> showEntryMenu(BuildContext context, Offset at, FileEntry entry) {
  final l10n = AppLocalizations.of(context);
  final scope = FinderScope.of(context);
  final cmd = FinderCommands(context);
  final actions = scope.actions;
  if (scope.browser.isTrash) {
    return _show(context, at, [
      _Action(l10n.menuPutBack, actions.putBackSelection),
      _Action(l10n.menuDeleteImmediately, cmd.delete, shortcut: 'Del'),
      null,
      _Action(l10n.menuQuickLook, cmd.quickLook, shortcut: 'Space'),
      _Action(l10n.menuGetInfo, cmd.getInfo, shortcut: 'Ctrl+I'),
      null,
      _Action(l10n.menuEmptyTrash, cmd.emptyTrash),
    ]);
  }
  final single = scope.browser.selection.length == 1;
  final folder = single && entry.isDirectory;
  return _show(context, at, [
    _Action(l10n.menuOpen, actions.openSelection, shortcut: 'Enter'),
    null,
    _Action(l10n.menuMoveToTrash, cmd.delete, shortcut: 'Del'),
    null,
    _Action(l10n.menuGetInfo, cmd.getInfo, shortcut: 'Ctrl+I'),
    _Action(
      l10n.menuRename,
      single ? () => scope.browser.beginRename(entry.path) : null,
      shortcut: 'F2',
    ),
    _Action(l10n.menuDuplicate, cmd.duplicate, shortcut: 'Ctrl+D'),
    _Action(l10n.menuQuickLook, cmd.quickLook, shortcut: 'Space'),
    null,
    _Action(l10n.menuCopy, actions.copy, shortcut: 'Ctrl+C'),
    _Action(l10n.menuCut, actions.cut, shortcut: 'Ctrl+X'),
    _Action(l10n.menuCopyPath, cmd.copyPath, shortcut: 'Ctrl+Alt+C'),
    null,
    TagPickerEntry(
      tagged: {
        for (final c in TagColor.values)
          if (scope.browser.selectedEntries.every(
            (e) => e.colorTags.contains(c),
          ))
            c,
      },
      onToggle: actions.toggleTag,
    ),
    if (folder) ...[
      null,
      _Action(l10n.menuOpenInNewTab, () => cmd.newTab(entry.path)),
      _Action(l10n.menuOpenInTerminal, () => cmd.openInTerminal(entry.path)),
      if (!scope.sidebar.isFavorite(entry.path))
        _Action(
          l10n.menuAddToSidebar,
          () => scope.sidebar.addBookmark(entry.path),
        ),
    ],
  ]);
}

Future<void> showBackgroundMenu(BuildContext context, Offset at) {
  final l10n = AppLocalizations.of(context);
  final scope = FinderScope.of(context);
  final cmd = FinderCommands(context);
  final browser = scope.browser;
  if (browser.isTrash) {
    return _show(context, at, [
      _Action(
        l10n.menuEmptyTrash,
        browser.entries.isEmpty ? null : cmd.emptyTrash,
      ),
    ]);
  }
  final history = scope.actions.history;
  return _show(context, at, [
    _Action(
      l10n.menuUndo,
      history.canUndo ? cmd.undo : null,
      shortcut: 'Ctrl+Z',
    ),
    _Action(
      l10n.menuRedo,
      history.canRedo ? cmd.redo : null,
      shortcut: 'Ctrl+Shift+Z',
    ),
    null,
    _Action(l10n.menuNewFolder, cmd.newFolder, shortcut: 'Ctrl+Shift+N'),
    null,
    _Action(l10n.menuPaste, cmd.paste, shortcut: 'Ctrl+V'),
    null,
    _Action(l10n.menuOpenInTerminal, cmd.openInTerminal),
    _Action(l10n.tooltipNewTab, cmd.newTab, shortcut: 'Ctrl+T'),
    _Action(l10n.menuNewWindow, cmd.newWindow, shortcut: 'Ctrl+N'),
    _Action(
      l10n.menuMergeAllWindows,
      cmd.mergeAllWindows,
      shortcut: 'Ctrl+Shift+M',
    ),
    _Action(
      browser.showHidden ? l10n.menuHideHidden : l10n.menuShowHidden,
      browser.toggleHidden,
      shortcut: 'Ctrl+H',
    ),
    null,
    _Action(l10n.menuSettings, cmd.openSettings, shortcut: 'Ctrl+,'),
  ]);
}

Future<void> showPlaceMenu(BuildContext context, Offset at, Place place) {
  final l10n = AppLocalizations.of(context);
  final scope = FinderScope.of(context);
  final cmd = FinderCommands(context);
  return _show(context, at, [
    _Action(l10n.menuOpen, () => cmd.goTo(place.path)),
    _Action(l10n.menuOpenInNewTab, () => cmd.newTab(place.path)),
    if (place.kind != PlaceKind.trash) ...[
      _Action(l10n.menuNewWindow, () => scope.window.openWindow(place.path)),
      if (place.kind != PlaceKind.device)
        _Action(l10n.menuOpenInTerminal, () => cmd.openInTerminal(place.path)),
    ],
    if (place.kind == PlaceKind.trash) ...[
      null,
      _Action(l10n.menuEmptyTrash, cmd.emptyTrash),
    ],
    if (place.kind == PlaceKind.volume) ...[
      null,
      _Action(l10n.tooltipEject, () => scope.actions.eject(place.path)),
    ],
    if (place.kind == PlaceKind.bookmark) ...[
      null,
      _Action(
        l10n.menuRemoveFromSidebar,
        () => scope.sidebar.removeBookmark(place.path),
      ),
    ],
  ]);
}
