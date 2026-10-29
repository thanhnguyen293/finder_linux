import 'package:flutter/widgets.dart';

import '../platform/window_channel.dart';
import '../services/window_registry.dart';
import '../state/browser_controller.dart';
import '../state/file_actions.dart';
import '../state/sidebar_controller.dart';
import '../state/tabs_controller.dart';

/// Hands the window's controllers to descendants. [browser], [actions] and
/// [contentFocus] belong to the active tab. Widgets subscribe to the
/// controllers themselves (ListenableBuilder) so only they rebuild.
class FinderScope extends InheritedWidget {
  const FinderScope({
    super.key,
    required this.browser,
    required this.actions,
    required this.sidebar,
    required this.window,
    required this.contentFocus,
    required this.tabs,
    this.registry,
    required super.child,
  });

  final BrowserController browser;
  final FileActions actions;
  final SidebarController sidebar;
  final WindowChannel window;

  /// Focus of the active tab's file view; keyboard commands apply while it
  /// has focus.
  final FocusNode contentFocus;

  final TabsController tabs;

  /// Finds other Finder windows for "Merge All Windows"; null when the
  /// session has no runtime directory.
  final WindowRegistry? registry;

  static FinderScope of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<FinderScope>();
    assert(scope != null, 'FinderScope missing above $context');
    return scope!;
  }

  @override
  bool updateShouldNotify(FinderScope oldWidget) => false;
}
