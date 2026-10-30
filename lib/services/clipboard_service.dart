import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:super_clipboard/super_clipboard.dart';

/// Files on the clipboard, and whether they were cut (move on paste).
typedef FileClipboard = ({List<String> paths, bool cut});

/// The clipboard that file copy / cut / paste go through.
abstract interface class FileClipboardStore {
  Future<void> write(FileClipboard clip);

  /// Files on the clipboard, from Finder or any other app; null if none.
  Future<FileClipboard?> read();

  Future<void> clear();
}

/// GNOME's format for copied files, understood by Nautilus and friends:
/// "copy" or "cut", then one file URI per line.
String encodeGnomeFiles(FileClipboard clip) => [
  clip.cut ? 'cut' : 'copy',
  for (final path in clip.paths) Uri.file(path).toString(),
].join('\n');

FileClipboard? decodeGnomeFiles(String data) {
  final lines = const LineSplitter().convert(data.trim());
  if (lines.isEmpty || (lines.first != 'copy' && lines.first != 'cut')) {
    return null;
  }
  final paths = _filePaths(lines.skip(1));
  return paths.isEmpty ? null : (paths: paths, cut: lines.first == 'cut');
}

/// `text/uri-list` (RFC 2483): comments start with '#'; non-file URIs
/// (web links) are ignored. Pasted lists are always copies.
FileClipboard? decodeUriList(String data) {
  final paths = _filePaths(
    const LineSplitter()
        .convert(data)
        .where((l) => l.trim().isNotEmpty && !l.startsWith('#')),
  );
  return paths.isEmpty ? null : (paths: paths, cut: false);
}

List<String> _filePaths(Iterable<String> uris) => [
  for (final line in uris)
    if (Uri.tryParse(line.trim()) case final uri? when uri.isScheme('file'))
      uri.toFilePath(),
];

Future<String?> _decodeUtf8(Object value, String format) async =>
    switch (value) {
      final String s => s,
      final List<int> bytes => utf8.decode(bytes, allowMalformed: true),
      _ => null,
    };

Object _encodeUtf8(String value, String format) =>
    Uint8List.fromList(utf8.encode(value));

const _gnomeCopiedFiles = SimpleValueFormat<String>(
  fallback: SimplePlatformCodec<String>(
    formats: ['x-special/gnome-copied-files'],
    onDecode: _decodeUtf8,
    onEncode: _encodeUtf8,
  ),
);

const _uriList = SimpleValueFormat<String>(
  fallback: SimplePlatformCodec<String>(
    formats: ['text/uri-list'],
    onDecode: _decodeUtf8,
    onEncode: _encodeUtf8,
  ),
);

/// The desktop clipboard, shared with every app and Finder window.
class SystemFileClipboard implements FileClipboardStore {
  SystemFileClipboard(this._clipboard);

  final SystemClipboard _clipboard;

  @override
  Future<void> write(FileClipboard clip) async {
    final item = DataWriterItem()
      ..add(_gnomeCopiedFiles(encodeGnomeFiles(clip)))
      ..add(
        _uriList(
          '${clip.paths.map((p) => Uri.file(p).toString()).join('\r\n')}\r\n',
        ),
      )
      // Plain paths, for pasting into a terminal or text editor.
      ..add(Formats.plainText(clip.paths.join('\n')));
    await _clipboard.write([item]);
  }

  @override
  Future<FileClipboard?> read() async {
    final reader = await _clipboard.read();
    if (reader.canProvide(_gnomeCopiedFiles)) {
      final data = await reader.readValue(_gnomeCopiedFiles);
      if (data != null) return decodeGnomeFiles(data);
    }
    if (reader.canProvide(_uriList)) {
      final data = await reader.readValue(_uriList);
      if (data != null) return decodeUriList(data);
    }
    return null;
  }

  @override
  Future<void> clear() => _clipboard.write([]);
}

/// In-process clipboard, used when no system clipboard is available
/// (widget tests, unusual sessions).
class MemoryFileClipboard implements FileClipboardStore {
  FileClipboard? _clip;

  @override
  Future<void> write(FileClipboard clip) async => _clip = clip;

  @override
  Future<FileClipboard?> read() async => _clip;

  @override
  Future<void> clear() async => _clip = null;
}

/// Knows what this window last put on the clipboard (to dim cut items)
/// and reads the shared clipboard on paste.
class ClipboardController extends ChangeNotifier {
  ClipboardController(this._store);

  final FileClipboardStore _store;
  FileClipboard? _written;

  /// What this window last copied or cut; drives the dimmed "cut" look.
  FileClipboard? get written => _written;

  bool isCut(String path) =>
      _written != null && _written!.cut && _written!.paths.contains(path);

  Future<void> put(FileClipboard clip) async {
    _written = clip;
    notifyListeners();
    await _store.write(clip);
  }

  Future<FileClipboard?> read() => _store.read();

  /// After a cut is pasted the files have moved; the clipboard is spent.
  Future<void> consumeCut() async {
    _written = null;
    notifyListeners();
    await _store.clear();
  }
}
