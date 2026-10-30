import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../services/file_system_service.dart' show newWindowFlag;

/// Bridge to the GTK window in `linux/runner/my_application.cc`, which hides
/// the system title bar so Flutter can draw Finder's toolbar. All windows
/// live in one process; each has its own engine and channel.
class WindowChannel {
  WindowChannel() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'squareCornersChanged':
          squareCorners.value = call.arguments == true;
        case 'launch':
          final args = [
            for (final a in call.arguments as List<Object?>? ?? const [])
              if (a is String) a,
          ];
          return await onLaunch?.call(args) ?? false;
      }
      return null;
    });
  }

  /// Finder was launched again (a folder opened from another app, the
  /// `finder` command) while this is the active window. Returns whether
  /// this window took it (as a tab); otherwise a new window opens.
  Future<bool> Function(List<String> args)? onLaunch;

  static const _channel = MethodChannel('finder/window');

  /// True while maximized, fullscreen or tiled; the window is drawn without
  /// rounded corners then.
  final squareCorners = ValueNotifier<bool>(false);

  Future<void> startDrag() => _invoke('startDrag');
  Future<void> minimize() => _invoke('minimize');
  Future<void> toggleMaximize() => _invoke('toggleMaximize');
  Future<void> close() => _invoke('close');

  /// Raises the window (a folder was opened into it from another app).
  Future<void> present() => _invoke('present');
  Future<void> setTitle(String title) => _invoke('setTitle', title);

  /// Opens another Finder window in this process, at [dir] or at the
  /// "New windows open" folder.
  Future<void> openWindow([String? dir]) =>
      _invoke('openWindow', [newWindowFlag, ?dir]);

  void dispose() {
    _channel.setMethodCallHandler(null);
    squareCorners.dispose();
  }

  Future<void> _invoke(String method, [Object? args]) async {
    try {
      await _channel.invokeMethod<void>(method, args);
    } on MissingPluginException {
      // Widget tests and other embedders have no native window to drive.
    }
  }
}
