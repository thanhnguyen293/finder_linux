import 'dart:io';

import 'package:path/path.dart' as p;

/// A typed location as an absolute path: `~` is [home], relative paths
/// are inside [current].
String resolveLocation(
  String raw, {
  required String home,
  required String current,
}) {
  final text = raw.trim();
  final expanded = text == '~' || text.startsWith('~/')
      ? home + text.substring(1)
      : text;
  return p.normalize(
    p.isAbsolute(expanded) ? expanded : p.join(current, expanded),
  );
}

/// Tab completion for a typed folder path, shell-style: the one folder
/// the last segment starts, or the longest prefix all candidates share.
/// Null when nothing more can be completed. Hidden folders only complete
/// when the segment starts with a dot.
String? completeLocation(
  String text, {
  required String home,
  required String current,
}) {
  final slash = text.lastIndexOf('/');
  final typedDir = slash < 0 ? '' : text.substring(0, slash + 1);
  final segment = text.substring(slash + 1);
  final dir = resolveLocation(
    typedDir.isEmpty ? '.' : typedDir,
    home: home,
    current: current,
  );
  final List<String> names;
  try {
    names = [
      for (final e in Directory(dir).listSync())
        if (e is Directory) p.basename(e.path),
    ];
  } on FileSystemException {
    return null;
  }
  bool visible(String n) => segment.startsWith('.') || !n.startsWith('.');
  var matches = [
    for (final n in names)
      if (visible(n) && n.startsWith(segment)) n,
  ];
  if (matches.isEmpty) {
    final lower = segment.toLowerCase();
    matches = [
      for (final n in names)
        if (visible(n) && n.toLowerCase().startsWith(lower)) n,
    ];
  }
  if (matches.isEmpty) return null;
  if (matches.length == 1) return '$typedDir${matches.single}/';
  var common = matches.first;
  for (final m in matches.skip(1)) {
    var i = 0;
    while (i < common.length && i < m.length && common[i] == m[i]) {
      i++;
    }
    common = common.substring(0, i);
  }
  return common.length > segment.length ? '$typedDir$common' : null;
}
