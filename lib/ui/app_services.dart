import 'package:flutter/widgets.dart';

import '../services/editor_apps.dart';
import '../services/thumbnail_service.dart';
import '../state/update_controller.dart';

/// App-wide services that run desktop tools or touch the network; absent
/// in widget tests, where the features using them simply stay off.
class AppServices extends InheritedWidget {
  const AppServices({
    super.key,
    this.thumbnails,
    this.updates,
    this.editors,
    required super.child,
  });

  final ThumbnailService? thumbnails;
  final UpdateController? updates;
  final EditorAppsService? editors;

  static AppServices? _of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppServices>();

  static ThumbnailService? thumbnailsOf(BuildContext context) =>
      _of(context)?.thumbnails;

  static UpdateController? updatesOf(BuildContext context) =>
      _of(context)?.updates;

  static EditorAppsService? editorsOf(BuildContext context) =>
      _of(context)?.editors;

  @override
  bool updateShouldNotify(AppServices old) =>
      old.thumbnails != thumbnails ||
      old.updates != updates ||
      old.editors != editors;
}
