import 'dart:io';

import 'package:path/path.dart' as p;

/// Folder to open and item to select from command-line arguments, which
/// may be a path or a `file://` URI (desktop files pass `%U`).
(String folder, String? select) resolveLaunchTarget(
  List<String> args, {
  required String home,
}) {
  if (args.isEmpty) return (home, null);
  final raw = args.first;
  final path = p.normalize(
    raw.startsWith('file://') ? Uri.parse(raw).toFilePath() : p.absolute(raw),
  );
  return switch (FileSystemEntity.typeSync(path)) {
    FileSystemEntityType.directory => (path, null),
    FileSystemEntityType.notFound => (home, null),
    _ => (p.dirname(path), path),
  };
}
