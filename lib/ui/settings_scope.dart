import 'package:flutter/widgets.dart';

import '../models/finder_settings.dart';
import '../state/settings_controller.dart';

/// Provides [SettingsController] above the app so preferences (theme,
/// language, thumbnails, sidebar items) can rebuild exactly what uses them.
class SettingsScope extends InheritedNotifier<SettingsController> {
  const SettingsScope({
    super.key,
    required SettingsController super.notifier,
    required super.child,
  });

  /// Current settings; the caller rebuilds when they change.
  static FinderSettings of(BuildContext context) => controllerOf(context).value;

  static SettingsController controllerOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'SettingsScope missing above $context');
    return scope!.notifier!;
  }

  /// Reads without subscribing, for event handlers.
  static SettingsController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'SettingsScope missing above $context');
    return scope!.notifier!;
  }
}
