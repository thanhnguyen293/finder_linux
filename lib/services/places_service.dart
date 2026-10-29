import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/place.dart';

/// Reads sidebar locations from the same sources Nautilus uses, so favorites
/// stay in sync between the two apps.
class PlacesService {
  PlacesService({Map<String, String>? environment})
    : _env = environment ?? Platform.environment;

  final Map<String, String> _env;

  String get home => _env['HOME'] ?? '/';
  String get _configHome => _env['XDG_CONFIG_HOME'] ?? p.join(home, '.config');
  String get _dataHome =>
      _env['XDG_DATA_HOME'] ?? p.join(home, '.local', 'share');

  /// Per-user runtime directory (window sockets live here); null when the
  /// session doesn't provide one, which disables "Merge All Windows".
  String? get runtimeDir => _env['XDG_RUNTIME_DIR'];

  String get trashFilesDir => p.join(_dataHome, 'Trash', 'files');
  File get _bookmarksFile => File(p.join(_configHome, 'gtk-3.0', 'bookmarks'));

  Future<List<Place>> favorites() async {
    final userDirs = parseUserDirs(
      await _readOrEmpty(File(p.join(_configHome, 'user-dirs.dirs'))),
      home,
    );
    final places = <Place>[
      Place(
        kind: PlaceKind.home,
        path: home,
        label: _env['USER'] ?? p.basename(home),
      ),
      for (final MapEntry(key: kind, value: path) in userDirs.entries)
        if (Directory(path).existsSync())
          Place(kind: kind, path: path, label: p.basename(path)),
    ];
    final known = places.map((e) => e.path).toSet();
    for (final (path, label) in parseBookmarks(
      await _readOrEmpty(_bookmarksFile),
    )) {
      if (known.add(path) && Directory(path).existsSync()) {
        places.add(Place(kind: PlaceKind.bookmark, path: path, label: label));
      }
    }
    return places;
  }

  /// Path of a "New windows show" choice, falling back to home when that
  /// user directory doesn't exist.
  Future<String> folderFor(PlaceKind kind) async {
    if (kind == PlaceKind.computer) return '/';
    final match = (await favorites()).where((p) => p.kind == kind).firstOrNull;
    return match?.path ?? home;
  }

  Future<List<Place>> locations() async {
    final mounts = parseMounts(await _readOrEmpty(File('/proc/mounts')));
    return [
      const Place(kind: PlaceKind.computer, path: '/', label: ''),
      for (final m in mounts)
        Place(kind: PlaceKind.volume, path: m, label: p.basename(m)),
      Place(kind: PlaceKind.trash, path: trashFilesDir, label: ''),
    ];
  }

  Future<void> addBookmark(String path) async {
    final lines = (await _readOrEmpty(_bookmarksFile)).split('\n')
      ..removeWhere((l) => l.trim().isEmpty);
    lines.add(Uri.file(path).toString());
    await _bookmarksFile.parent.create(recursive: true);
    await _bookmarksFile.writeAsString('${lines.join('\n')}\n');
  }

  Future<void> removeBookmark(String path) async {
    final lines = (await _readOrEmpty(_bookmarksFile)).split('\n')
      ..removeWhere((l) => l.trim().isEmpty || _bookmarkPath(l) == path);
    await _bookmarksFile.writeAsString(
      lines.isEmpty ? '' : '${lines.join('\n')}\n',
    );
  }

  Future<String> _readOrEmpty(File f) async {
    try {
      return await f.readAsString();
    } on FileSystemException {
      return '';
    }
  }
}

const _userDirKeys = {
  'XDG_DESKTOP_DIR': PlaceKind.desktop,
  'XDG_DOCUMENTS_DIR': PlaceKind.documents,
  'XDG_DOWNLOAD_DIR': PlaceKind.downloads,
  'XDG_PICTURES_DIR': PlaceKind.pictures,
  'XDG_MUSIC_DIR': PlaceKind.music,
  'XDG_VIDEOS_DIR': PlaceKind.videos,
};

/// Parses `user-dirs.dirs`, returning entries in sidebar order. Dirs that
/// point at the home folder itself (the spec's "disabled" value) are dropped.
Map<PlaceKind, String> parseUserDirs(String content, String home) {
  final found = <PlaceKind, String>{};
  for (final line in content.split('\n')) {
    final match = RegExp(r'^(XDG_\w+_DIR)="(.*)"\s*$').firstMatch(line.trim());
    final kind = _userDirKeys[match?[1]];
    if (match == null || kind == null) continue;
    final path = p.normalize(match[2]!.replaceFirst(r'$HOME', home));
    if (path != p.normalize(home)) found[kind] = path;
  }
  return {for (final kind in _userDirKeys.values) kind: ?found[kind]};
}

/// Parses GTK bookmarks (`file:///path Optional Label`), local folders only.
List<(String, String)> parseBookmarks(String content) => [
  for (final line in content.split('\n'))
    if (_bookmarkPath(line) case final path?)
      (path, _bookmarkLabel(line) ?? p.basename(path)),
];

String? _bookmarkPath(String line) {
  final uri = line.trim().split(' ').first;
  if (!uri.startsWith('file://')) return null;
  return Uri.parse(uri).toFilePath();
}

String? _bookmarkLabel(String line) {
  final space = line.trim().indexOf(' ');
  return space < 0 ? null : line.trim().substring(space + 1);
}

/// Mount points of removable media from `/proc/mounts`.
List<String> parseMounts(String content) => [
  for (final line in content.split('\n'))
    if (line.split(' ') case [_, final raw, ...])
      if (_unescapeMount(raw) case final m
          when m.startsWith('/media/') || m.startsWith('/run/media/'))
        m,
];

String _unescapeMount(String s) => s.replaceAllMapped(
  RegExp(r'\\([0-7]{3})'),
  (m) => String.fromCharCode(int.parse(m[1]!, radix: 8)),
);
