import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

enum FileKind {
  folder,
  image,
  video,
  audio,
  text,
  code,
  pdf,
  archive,
  document,
  spreadsheet,
  presentation,
  application,
  other,
}

final _kindByExtension = <String, FileKind>{
  for (final e in [
    'png',
    'jpg',
    'jpeg',
    'gif',
    'webp',
    'bmp',
    'svg',
    'ico',
    'heic',
    'tif',
    'tiff',
  ])
    e: FileKind.image,
  for (final e in ['mp4', 'mkv', 'mov', 'avi', 'webm', 'm4v', 'flv', 'wmv'])
    e: FileKind.video,
  for (final e in ['mp3', 'wav', 'flac', 'ogg', 'm4a', 'aac', 'opus'])
    e: FileKind.audio,
  for (final e in ['txt', 'md', 'log', 'csv', 'ini', 'conf', 'cfg', 'rst'])
    e: FileKind.text,
  for (final e in [
    'dart',
    'js',
    'ts',
    'tsx',
    'jsx',
    'py',
    'rs',
    'go',
    'c',
    'h',
    'cc',
    'cpp',
    'hpp',
    'java',
    'kt',
    'swift',
    'rb',
    'php',
    'sh',
    'zsh',
    'json',
    'yaml',
    'yml',
    'toml',
    'xml',
    'html',
    'css',
    'scss',
    'sql',
    'gradle',
    'cmake',
  ])
    e: FileKind.code,
  'pdf': FileKind.pdf,
  for (final e in [
    'zip',
    'tar',
    'gz',
    'tgz',
    'xz',
    'bz2',
    '7z',
    'rar',
    'zst',
    'deb',
    'rpm',
  ])
    e: FileKind.archive,
  for (final e in ['doc', 'docx', 'odt', 'rtf', 'pages']) e: FileKind.document,
  for (final e in ['xls', 'xlsx', 'ods', 'numbers']) e: FileKind.spreadsheet,
  for (final e in ['ppt', 'pptx', 'odp', 'key']) e: FileKind.presentation,
  for (final e in ['appimage', 'desktop', 'run', 'flatpakref', 'snap'])
    e: FileKind.application,
};

/// Immutable snapshot of one directory entry.
@immutable
class FileEntry {
  const FileEntry({
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.modified,
    required this.mode,
    this.isSymlink = false,
  });

  final String path;
  final bool isDirectory;
  final int size;
  final DateTime modified;

  /// POSIX permission bits as reported by `stat`.
  final int mode;
  final bool isSymlink;

  String get name => p.basename(path);
  String get parent => p.dirname(path);
  bool get isHidden => name.startsWith('.');

  /// Lower-cased extension without the dot; empty for folders.
  String get extension {
    if (isDirectory) return '';
    final ext = p.extension(name);
    return ext.isEmpty ? '' : ext.substring(1).toLowerCase();
  }

  FileKind get kind => isDirectory
      ? FileKind.folder
      : (_kindByExtension[extension] ?? FileKind.other);

  @override
  bool operator ==(Object other) =>
      other is FileEntry &&
      other.path == path &&
      other.isDirectory == isDirectory &&
      other.size == size &&
      other.modified == modified &&
      other.mode == mode;

  @override
  int get hashCode => Object.hash(path, isDirectory, size, modified, mode);
}
