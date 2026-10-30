import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// One tab of a saved session.
typedef SessionTab = ({String path, String viewMode});

/// A window's tabs, saved so the next launch reopens them.
typedef Session = ({List<SessionTab> tabs, int active});

/// Reads and writes `$XDG_CONFIG_HOME/finder-linux/session.json`.
class SessionStore {
  SessionStore({Map<String, String>? environment})
    : _env = environment ?? Platform.environment;

  final Map<String, String> _env;

  File get file {
    final config =
        _env['XDG_CONFIG_HOME'] ?? p.join(_env['HOME'] ?? '/', '.config');
    return File(p.join(config, 'finder-linux', 'session.json'));
  }

  /// The saved session, keeping only folders that still exist. Null when
  /// there is nothing usable.
  Future<Session?> load() async {
    try {
      final json = jsonDecode(await file.readAsString());
      if (json case {
        'tabs': final List<Object?> raw,
        'active': final int active,
      }) {
        final tabs = <SessionTab>[
          for (final t in raw)
            if (t case {
              'path': final String path,
              'viewMode': final String view,
            } when Directory(path).existsSync())
              (path: path, viewMode: view),
        ];
        if (tabs.isEmpty) return null;
        return (tabs: tabs, active: active.clamp(0, tabs.length - 1));
      }
    } on FileSystemException {
      // No session yet.
    } on FormatException {
      // Corrupt file: start fresh; the next save rewrites it.
    }
    return null;
  }

  Future<void> save(Session session) async {
    try {
      await file.parent.create(recursive: true);
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(
        jsonEncode({
          'tabs': [
            for (final t in session.tabs)
              {'path': t.path, 'viewMode': t.viewMode},
          ],
          'active': session.active,
        }),
      );
      await tmp.rename(file.path);
    } on FileSystemException {
      // Losing the session is harmless; the app keeps working.
    }
  }
}
