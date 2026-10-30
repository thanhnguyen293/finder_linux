import 'package:flutter/material.dart';

import '../state/tabs_controller.dart';
import '../theme/finder_theme.dart';
import 'content_area.dart';
import 'finder_scope.dart';
import 'settings_scope.dart';
import 'toolbar/finder_toolbar.dart';
import 'toolbar/search_scope_bar.dart';
import 'widgets/bottom_bars.dart';
import 'widgets/path_bar.dart';

/// One tab's browsing area: toolbar, files, path bar and status bar, with
/// that tab's controllers in scope. In split view each side is a pane;
/// clicking a pane makes its tab the active one.
class TabPane extends StatelessWidget {
  const TabPane({super.key, required this.tab, this.inSplit = false});

  final BrowserTab tab;
  final bool inSplit;

  @override
  Widget build(BuildContext context) {
    final window = FinderScope.of(context);
    final prefs = SettingsScope.of(context);
    final tabs = window.tabs;
    Widget pane = Column(
      children: [
        FinderToolbar(searchFocus: tab.searchFocus),
        const SearchScopeBar(),
        const Expanded(child: ContentArea()),
        if (prefs.showPathBar) const PathBar(),
        if (prefs.showStatusBar) const StatusBar(),
      ],
    );
    if (inSplit) {
      final active = tabs.active == tab;
      final palette = context.palette;
      final radius = BorderRadius.circular(FinderMetrics.radiusMedium);
      pane = Listener(
        onPointerDown: (_) => tabs.activate(tabs.tabs.indexOf(tab)),
        child: ClipRRect(
          borderRadius: radius,
          child: DecoratedBox(
            // Accent outline: the side that sidebar and shortcuts act on.
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: radius,
              // A faint accent line is enough to tell the panes apart;
              // the card gutter already separates them.
              border: Border.all(
                color: active
                    ? palette.accent.withValues(alpha: 0.45)
                    : palette.separator,
              ),
            ),
            child: AnimatedOpacity(
              opacity: active ? 1 : 0.92,
              duration: const Duration(milliseconds: 120),
              child: pane,
            ),
          ),
        ),
      );
    }
    return window.forTab(
      tab,
      child: RepaintBoundary(key: tab.previewKey, child: pane),
    );
  }
}
