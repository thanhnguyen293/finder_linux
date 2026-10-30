import 'dart:io';

import 'package:path/path.dart' as p;

/// Folder to open and item to select from command-line arguments, which
/// may be a path or a `file://` URI (desktop files pass `%U`).
(String folder, String? select) resolveLaunchTarget(
  List<String> args, {
  required String home,
}) {
  final paths = args.where((a) => !a.startsWith('--')).toList();
  if (paths.isEmpty) return (home, null);
  final raw = paths.first;
  final path = p.normalize(
    raw.startsWith('file://') ? Uri.parse(raw).toFilePath() : p.absolute(raw),
  );
  return switch (FileSystemEntity.typeSync(path)) {
    FileSystemEntityType.directory => (path, null),
    FileSystemEntityType.notFound => (home, null),
    _ => (p.dirname(path), path),
  };
}

/// The window number the GTK runner gives each window (`--window-index=N`,
/// counting from 0 per process); 0 when absent.
int windowIndexOf(List<String> args) {
  const prefix = '--window-index=';
  for (final a in args) {
    if (a.startsWith(prefix)) {
      return int.tryParse(a.substring(prefix.length)) ?? 0;
    }
  }
  return 0;
}
