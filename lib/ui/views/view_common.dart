import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/file_entry.dart';
import '../../models/grouping.dart';
import '../../theme/finder_theme.dart';
import '../commands.dart';
import '../dnd/file_drag.dart';
import '../finder_scope.dart';
import '../formatting.dart';
import '../widgets/context_menus.dart';

const _doubleClickWindow = Duration(milliseconds: 400);

/// Pointer handling for one file item. Uses raw pointer events instead of
/// gesture recognizers so selection reacts on mouse-down with no
/// double-tap delay, like a native file manager.
class EntryGestures extends StatelessWidget {
  const EntryGestures({
    super.key,
    required this.entry,
    required this.child,
    this.onClick,
  });

  final FileEntry entry;
  final Widget child;

  /// Plain-click action; selects [entry] by default. Column rows of other
  /// folders navigate instead.
  final VoidCallback? onClick;

  static String? _lastClickPath;
  static DateTime _lastClickAt = DateTime(0);

  /// Pointer id claimed by an item, so the background under it ignores it.
  static int? claimedPointer;

  // A plain click selects on release, not on press: pressing an item and
  // dragging it must leave the selection (and the columns it opened)
  // alone, so the files can be dropped into a column that is showing.
  static int? _pendingPointer;
  static VoidCallback? _pendingClick;

  /// Called when a drag starts: the press was a drag, not a click.
  static void cancelPendingClick() {
    _pendingPointer = null;
    _pendingClick = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        claimedPointer = event.pointer;
        cancelPendingClick();
        final scope = FinderScope.of(context);
        // Clicks inside the inline rename field belong to the text field.
        if (scope.browser.renamingPath == entry.path) return;
        final cmd = FinderCommands(context);
        if (event.buttons & kSecondaryMouseButton != 0) {
          cmd.secondaryClickEntry(entry);
          showEntryMenu(context, event.position, entry);
          return;
        }
        // Middle-click opens a folder in a background tab, as in Chrome.
        if (event.buttons & kMiddleMouseButton != 0) {
          if (entry.isDirectory) cmd.newTab(entry.path, false);
          return;
        }
        if (event.buttons & kPrimaryMouseButton == 0) return;
        scope.contentFocus.requestFocus();
        final now = DateTime.now();
        final isDouble =
            _lastClickPath == entry.path &&
            now.difference(_lastClickAt) < _doubleClickWindow;
        _lastClickPath = entry.path;
        _lastClickAt = isDouble ? DateTime(0) : now;
        if (isDouble) {
          scope.actions.open(entry);
          return;
        }
        final keys = HardwareKeyboard.instance;
        final click = onClick ?? () => cmd.clickEntry(entry);
        // Ctrl/Shift clicks only change the selection; apply them at once.
        if (keys.isControlPressed || keys.isShiftPressed) {
          click();
        } else {
          _pendingPointer = event.pointer;
          _pendingClick = click;
        }
      },
      onPointerUp: (event) {
        if (event.pointer != _pendingPointer) return;
        final click = _pendingClick;
        cancelPendingClick();
        click?.call();
      },
      onPointerCancel: (_) => cancelPendingClick(),
      child: FileDraggable(
        entry: entry,
        onDragStarted: cancelPendingClick,
        child: entry.isDirectory
            ? FolderDropTarget(
                dir: entry.path,
                builder: (context, hovering) => hovering
                    ? DecoratedBox(
                        decoration: dropHighlight(context),
                        child: child,
                      )
                    : child,
              )
            : child,
      ),
    );
  }
}

/// Empty-area handling: click clears selection, right-click opens the
/// folder menu.
class BackgroundGestures extends StatelessWidget {
  const BackgroundGestures({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        if (event.pointer == EntryGestures.claimedPointer) return;
        final scope = FinderScope.of(context);
        scope.contentFocus.requestFocus();
        scope.browser.clearSelection();
        if (event.buttons & kSecondaryMouseButton != 0) {
          showBackgroundMenu(context, event.position);
        }
      },
      child: child,
    );
  }
}

/// Loading / error / empty placeholder; returns null when [entries] is
/// non-empty and the view should render normally.
Widget? folderPlaceholder(BuildContext context) {
  final b = FinderScope.of(context).browser;
  if (b.entries.isNotEmpty) return null;
  final l10n = AppLocalizations.of(context);
  final palette = context.palette;
  final String text;
  if (b.loading) {
    return const SizedBox.shrink();
  } else if (b.loadFailure case final failure?) {
    text = failureMessage(l10n, failure);
  } else if (b.query.isNotEmpty) {
    text = l10n.noResults(b.query);
  } else {
    text = l10n.emptyFolder;
  }
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: palette.textSecondary),
      ),
    ),
  );
}

/// Scrolls just enough to bring the item spanning [top]..[top]+[extent]
/// into view.
void revealRange(ScrollController scroll, double top, double extent) {
  if (!scroll.hasClients) return;
  final pos = scroll.position;
  final bottom = top + extent;
  if (top < pos.pixels) {
    scroll.jumpTo(top.clamp(0, pos.maxScrollExtent));
  } else if (bottom > pos.pixels + pos.viewportDimension) {
    scroll.jumpTo(
      (bottom - pos.viewportDimension).clamp(0, pos.maxScrollExtent),
    );
  }
}

/// Items that were cut render dimmed until pasted.
bool isCut(BuildContext context, FileEntry entry) {
  final clip = FinderScope.of(context).browser.clipboard;
  return clip != null && clip.cut && clip.paths.contains(entry.path);
}

/// Section title above a group of items (Finder's "Use Groups").
class GroupHeader extends StatelessWidget {
  const GroupHeader({
    super.key,
    required this.label,
    required this.height,
    this.inset = 0,
  });

  final String label;
  final double height;
  final double inset;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: inset),
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: palette.separator, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: FinderMetrics.fontSizeSmall + 1,
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// A list line: a [GroupKey] header or a [FileEntry]. [stripe] restarts in
/// each group so row shading lines up under its header.
typedef ListRow = ({Object item, int stripe});

/// Rows for a list or column, with a header line before each group when
/// grouping is on. Headers are one row tall, so scroll math stays
/// index-based.
List<ListRow> groupedRows(List<FileEntry> entries, List<EntryGroup> groups) => [
  if (groups.isEmpty)
    for (final (i, e) in entries.indexed) (item: e, stripe: i)
  else
    for (final g in groups) ...[
      (item: g.key, stripe: 0),
      for (final (i, e) in g.entries.indexed) (item: e, stripe: i),
    ],
];
