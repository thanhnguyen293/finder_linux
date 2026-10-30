import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Folders recently opened in any Finder window, newest first, kept in
/// `$XDG_CONFIG_HOME/finder-linux/recent.json` so every window and the
/// next launch share them.
class RecentFolders {
  RecentFolders({Map<String, String>? environment, this.limit = 12})
    : _env = environment ?? Platform.environment;

  final Map<String, String> _env;
  final int limit;

  File get file {
    final config =
        _env['XDG_CONFIG_HOME'] ?? p.join(_env['HOME'] ?? '/', '.config');
    return File(p.join(config, 'finder-linux', 'recent.json'));
  }

  /// Recent folders that still exist.
  Future<List<String>> load() async => [
    for (final path in await _read())
      if (await Directory(path).exists()) path,
  ];

  /// Moves [path] to the front.
  Future<void> add(String path) async {
    final paths = await _read();
    if (paths.firstOrNull == path) return;
    await _write([path, ...paths.where((x) => x != path)].take(limit).toList());
  }

  Future<void> clear() => _write(const []);

  Future<List<String>> _read() async {
    try {
      final json = jsonDecode(await file.readAsString());
      if (json is List) return json.whereType<String>().toList();
    } on FileSystemException {
      // Nothing recorded yet.
    } on FormatException {
      // Corrupt: start over; the next visit rewrites it.
    }
    return [];
  }

  Future<void> _write(List<String> paths) async {
    try {
      await file.parent.create(recursive: true);
      final tmp = File('${file.path}.$pid.tmp');
      await tmp.writeAsString(jsonEncode(paths));
      await tmp.rename(file.path);
    } on FileSystemException {
      // Recents are a convenience; failing to save them isn't worth a
      // dialog.
    }
  }
}
