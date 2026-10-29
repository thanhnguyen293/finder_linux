import 'package:flutter/foundation.dart';

import '../core/result.dart';
import '../models/finder_settings.dart';
import '../services/settings_store.dart';

/// App-wide preferences; the single owner of [FinderSettings].
class SettingsController extends ChangeNotifier {
  SettingsController(this._store, this._value);

  final SettingsStore _store;
  FinderSettings _value;

  FinderSettings get value => _value;

  /// Applies [next] immediately and persists it.
  Future<Result<void>> update(FinderSettings next) {
    if (next == _value) return Future.value(const Ok(null));
    _value = next;
    notifyListeners();
    return _store.save(next);
  }
}
