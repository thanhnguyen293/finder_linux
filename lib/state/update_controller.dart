import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/result.dart';
import '../services/update_service.dart';

enum UpdateStatus {
  idle,
  checking,
  upToDate,
  available,
  installing,
  installed,
  failed,
}

/// Update state shared by the window (the "new version" notice) and
/// Settings ▸ Advanced (check / update / restart).
class UpdateController extends ChangeNotifier {
  UpdateController(this._service);

  final UpdateService _service;

  UpdateStatus _status = UpdateStatus.idle;
  String _detail = '';

  UpdateStatus get status => _status;

  /// Failure reason, or the installer's latest output line.
  String get detail => _detail;
  bool get supported => _service.supported;

  /// Once a day at startup, when the user allows it.
  Future<void> checkIfDue() async {
    if (!supported || !await _service.isDue()) return;
    await check();
  }

  Future<void> check() async {
    if (!supported || _busy) return;
    _set(UpdateStatus.checking);
    switch (await _service.check()) {
      case Ok(value: UpdateCheck.available):
        _set(UpdateStatus.available);
      case Ok():
        _set(UpdateStatus.upToDate);
      case Err(:final failure):
        _set(UpdateStatus.failed, failure.detail);
    }
  }

  Future<void> install() async {
    if (!supported || _busy) return;
    _set(UpdateStatus.installing);
    final result = await _service.install(
      onLine: (line) {
        if (line.trim().isEmpty) return;
        _detail = line.trim();
        notifyListeners();
      },
    );
    switch (result) {
      case Ok():
        _set(UpdateStatus.installed);
      case Err():
        _set(UpdateStatus.failed, _detail);
    }
  }

  Future<void> relaunch() => _service.relaunch();

  bool get _busy =>
      _status == UpdateStatus.checking || _status == UpdateStatus.installing;

  void _set(UpdateStatus status, [String detail = '']) {
    _status = status;
    _detail = detail;
    notifyListeners();
  }
}
