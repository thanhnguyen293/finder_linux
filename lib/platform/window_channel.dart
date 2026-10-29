import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bridge to the GTK window in `linux/runner/my_application.cc`, which hides
/// the system title bar so Flutter can draw Finder's toolbar.
class WindowChannel {
  WindowChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'squareCornersChanged') {
        squareCorners.value = call.arguments == true;
      }
    });
  }

  static const _channel = MethodChannel('finder/window');

  /// True while maximized, fullscreen or tiled; the window is drawn without
  /// rounded corners then.
  final squareCorners = ValueNotifier<bool>(false);

  Future<void> startDrag() => _invoke('startDrag');
  Future<void> minimize() => _invoke('minimize');
  Future<void> toggleMaximize() => _invoke('toggleMaximize');
  Future<void> close() => _invoke('close');
  Future<void> setTitle(String title) => _invoke('setTitle', title);

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
