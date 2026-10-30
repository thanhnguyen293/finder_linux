/// Finder's seven color tags. Stored by English name in the file's
/// `user.xdg.tags` attribute, so KDE's Dolphin shows the same tags.
enum TagColor {
  red,
  orange,
  yellow,
  green,
  blue,
  purple,
  gray;

  /// The tag's name as written to disk.
  String get tagName => '${name[0].toUpperCase()}${name.substring(1)}';

  /// The color a stored tag names (any case; "grey" too), or null for
  /// other tags, which are kept but not drawn.
  static TagColor? fromTag(String tag) {
    final lower = tag.trim().toLowerCase();
    if (lower == 'grey') return TagColor.gray;
    for (final c in values) {
      if (c.name == lower) return c;
    }
    return null;
  }
}

/// `user.xdg.tags` holds tags separated by commas.
List<String> decodeTags(String raw) => [
  for (final t in raw.split(','))
    if (t.trim().isNotEmpty) t.trim(),
];

String encodeTags(List<String> tags) => tags.join(',');

/// [tags] with [color] added, or removed when [remove]; other tags (from
/// other apps) are kept as they are.
List<String> withTag(
  List<String> tags,
  TagColor color, {
  required bool remove,
}) => [
  for (final t in tags)
    if (TagColor.fromTag(t) != color) t,
  if (!remove) color.tagName,
];
