import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../core/result.dart';
import '../models/finder_settings.dart';

/// Reads and writes `$XDG_CONFIG_HOME/finder-linux/settings.json`.
class SettingsStore {
  SettingsStore({Map<String, String>? environment})
    : _env = environment ?? Platform.environment;

  final Map<String, String> _env;

  File get file {
    final config =
        _env['XDG_CONFIG_HOME'] ?? p.join(_env['HOME'] ?? '/', '.config');
    return File(p.join(config, 'finder-linux', 'settings.json'));
  }

  /// Defaults when the file is missing or unreadable.
  Future<FinderSettings> load() async {
    try {
      final json = jsonDecode(await file.readAsString());
      if (json is Map<String, Object?>) return FinderSettings.fromJson(json);
    } on FileSystemException {
      // First run: no settings yet.
    } on FormatException {
      // A corrupt file shouldn't stop the app; it is rewritten on next save.
    }
    return const FinderSettings();
  }

  Future<Result<void>> save(FinderSettings settings) async {
    try {
      await file.parent.create(recursive: true);
      // Write then rename, so a crash mid-write never leaves half a file.
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(
        const JsonEncoder.withIndent('  ').convert(settings.toJson()),
      );
      await tmp.rename(file.path);
      return const Ok(null);
    } on FileSystemException catch (e) {
      return Err(Failure(FailureKind.other, e.osError?.message ?? e.message));
    }
  }
}
