import 'package:flutter/material.dart';

import '../models/sort_spec.dart';
import '../theme/finder_theme.dart';
import 'dnd/file_drag.dart';
import 'finder_scope.dart';
import 'keyboard.dart';
import 'views/column_browser_view.dart';
import 'views/file_list_view.dart';
import 'views/icon_grid_view.dart';
import 'views/view_common.dart';

/// The focusable file view; picks the layout from the current view mode.
class ContentArea extends StatefulWidget {
  const ContentArea({super.key});

  @override
  State<ContentArea> createState() => _ContentAreaState();
}

class _ContentAreaState extends State<ContentArea> {
  final _keys = ViewKeyHandler();
  int _gridColumns = 1;

  @override
  Widget build(BuildContext context) {
    final scope = FinderScope.of(context);
    return Focus(
      focusNode: scope.contentFocus,
      autofocus: true,
      onKeyEvent: (_, event) =>
          _keys.handle(context, event, gridColumns: _gridColumns),
      child: ColoredBox(
        color: context.palette.content,
        child: BackgroundGestures(
          child: ListenableBuilder(
            listenable: scope.browser,
            builder: (context, _) => FolderDropTarget(
              dir: scope.browser.path,
              onDrop: scope.browser.isTrash
                  ? (payload) => scope.actions.trashPaths(payload.paths)
                  : null,
              builder: (context, hovering) => DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: hovering
                    ? BoxDecoration(
                        border: Border.all(
                          color: context.palette.accent,
                          width: 2,
                        ),
                      )
                    : const BoxDecoration(),
                child: switch (scope.browser.viewMode) {
                  ViewMode.icons => IconGridView(
                    onColumnsChanged: (c) => _gridColumns = c,
                  ),
                  ViewMode.list => const FileListView(),
                  ViewMode.columns => const ColumnBrowserView(),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
