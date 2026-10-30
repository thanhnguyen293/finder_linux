import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../models/file_entry.dart';

/// Pixel size of generated thumbnails (the freedesktop "large" size), so
/// the biggest icons stay sharp on HiDPI screens.
const thumbnailSize = 256;

/// Images Flutter decodes itself; everything else goes through a tool.
const flutterDecodableImages = {
  'png',
  'jpg',
  'jpeg',
  'gif',
  'webp',
  'bmp',
  'ico',
};

/// Formats a desktop thumbnailer (evince, fonts, librsvg, heif…) may
/// handle, by extension; whether one is installed is checked at runtime.
const thumbnailMimeTypes = {
  'pdf': 'application/pdf',
  'ps': 'application/postscript',
  'eps': 'image/x-eps',
  'djvu': 'image/vnd.djvu',
  'xps': 'application/vnd.ms-xpsdocument',
  'oxps': 'application/oxps',
  'cbz': 'application/vnd.comicbook+zip',
  'cbr': 'application/vnd.comicbook-rar',
  'tif': 'image/tiff',
  'tiff': 'image/tiff',
  'svg': 'image/svg+xml',
  'heic': 'image/heif',
  'heif': 'image/heif',
  'avif': 'image/avif',
  'ttf': 'font/ttf',
  'otf': 'font/otf',
  'woff': 'font/woff',
};

/// Office files carry a preview picture inside their zip container.
const officePreviewMembers = {
  'odt': 'Thumbnails/thumbnail.png',
  'ods': 'Thumbnails/thumbnail.png',
  'odp': 'Thumbnails/thumbnail.png',
  'odg': 'Thumbnails/thumbnail.png',
  'docx': 'docProps/thumbnail.jpeg',
  'xlsx': 'docProps/thumbnail.jpeg',
  'pptx': 'docProps/thumbnail.jpeg',
};

const _videoExtensions = {
  'mp4',
  'mkv',
  'mov',
  'avi',
  'webm',
  'm4v',
  'flv',
  'wmv',
};

/// Thumbnailer `Exec` line for each MIME type, from the freedesktop
/// `.thumbnailer` files.
typedef ThumbnailerTable = Map<String, List<String>>;

ThumbnailerTable parseThumbnailer(String contents) {
  List<String>? exec;
  var mimes = const <String>[];
  for (final line in const LineSplitter().convert(contents)) {
    if (line.startsWith('Exec=')) {
      exec = line.substring(5).trim().split(RegExp(r'\s+'));
    } else if (line.startsWith('MimeType=')) {
      mimes = line.substring(9).split(';').where((m) => m.isNotEmpty).toList();
    }
  }
  return {
    if (exec != null)
      for (final m in mimes) m: exec,
  };
}

/// Fills a thumbnailer command's `%s %u %i %o` fields.
List<String> expandExec(List<String> exec, String input, String output) => [
  for (final arg in exec)
    arg
        .replaceAll('%s', '$thumbnailSize')
        .replaceAll('%u', Uri.file(input).toString())
        .replaceAll('%i', input)
        .replaceAll('%o', output)
        .replaceAll('%%', '%'),
];

/// Preview pictures for PDFs, videos, office documents, fonts and images
/// Flutter can't decode, made by the desktop's own tools and cached in
/// `$XDG_CACHE_HOME/finder-linux/thumbnails` (keyed by path, size and
/// modification time, so edited files get a fresh one).
class ThumbnailService {
  ThumbnailService({Map<String, String>? environment})
    : _env = environment ?? Platform.environment;

  final Map<String, String> _env;

  static const _maxJobs = 3;
  static const _timeout = Duration(seconds: 20);

  late final String cacheDir = p.join(
    _env['XDG_CACHE_HOME'] ?? p.join(_env['HOME'] ?? '/', '.cache'),
    'finder-linux',
    'thumbnails',
  );

  late final Future<ThumbnailerTable> _thumbnailers = _loadThumbnailers();
  final _ready = <String, String?>{};
  final _inFlight = <String, Future<String?>>{};
  final _queue = <Completer<void>>[];
  var _running = 0;

  bool handles(FileEntry e) {
    if (e.isDirectory) return false;
    final ext = e.extension;
    return _videoExtensions.contains(ext) ||
        officePreviewMembers.containsKey(ext) ||
        thumbnailMimeTypes.containsKey(ext);
  }

  String _keyOf(FileEntry e) => md5
      .convert(
        utf8.encode(
          '${e.path}\n${e.size}\n${e.modified.millisecondsSinceEpoch}',
        ),
      )
      .toString();

  /// A thumbnail already made this session, so a rebuilt icon shows it in
  /// its first frame. Null if unknown (or known to fail).
  String? cached(FileEntry e) => _ready[_keyOf(e)];

  /// Path of [e]'s thumbnail, making it if needed; null if none can be.
  Future<String?> thumbnailFor(FileEntry e) {
    final key = _keyOf(e);
    if (_ready.containsKey(key)) return Future.value(_ready[key]);
    return _inFlight[key] ??= _make(e, key).then((path) {
      _inFlight.remove(key);
      if (_ready.length > 5000) _ready.clear();
      return _ready[key] = path;
    });
  }

  Future<String?> _make(FileEntry e, String key) async {
    final out = p.join(cacheDir, '$key.png');
    final failed = File('$out.fail');
    if (await File(out).exists()) return out;
    if (await failed.exists()) return null;
    await _acquire();
    // Ubuntu's AppArmor profiles only let thumbnailers (evince…) write
    // files named like GNOME's own temporaries in /tmp.
    final work = p.join(
      Directory.systemTemp.path,
      'gnome-desktop-thumbnailer-$pid-$key.png',
    );
    final part = '$out.$pid.part';
    try {
      if (await _generate(e, work) && await _nonEmpty(work)) {
        await Directory(cacheDir).create(recursive: true);
        // /tmp is often another filesystem: copy, then rename into place
        // so readers never see half a file.
        await File(work).copy(part);
        await File(part).rename(out);
        return out;
      }
      // Remember failures so broken files aren't retried on every visit.
      await Directory(cacheDir).create(recursive: true);
      await failed.create();
      return null;
    } on FileSystemException {
      return null;
    } on ProcessException {
      return null;
    } finally {
      for (final leftover in [work, part]) {
        try {
          await File(leftover).delete();
        } on FileSystemException {
          // Never written, or already moved into place.
        }
      }
      _release();
    }
  }

  static Future<bool> _nonEmpty(String path) async {
    final stat = await File(path).stat();
    return stat.type == FileSystemEntityType.file && stat.size > 0;
  }

  Future<bool> _generate(FileEntry e, String work) async {
    final ext = e.extension;
    if (_videoExtensions.contains(ext)) {
      // A few seconds in skips black intro frames; short clips fall back
      // to the first frame.
      return await _videoFrame(e.path, work, '3') ||
          await _videoFrame(e.path, work, '0');
    }
    if (officePreviewMembers[ext] case final member?) {
      return await _exec('unzip', [
            '-p',
            e.path,
            member,
          ], stdoutTo: File(work)) ==
          0;
    }
    // poppler's renderer reads any file the user can (the confined evince
    // thumbnailer can't open hidden folders); fall back to the desktop's.
    if (ext == 'pdf' && await _pdfPage(e.path, work)) return true;
    final mime = thumbnailMimeTypes[ext];
    final exec = mime == null ? null : (await _thumbnailers)[mime];
    if (exec == null || exec.isEmpty) return false;
    final args = expandExec(exec, e.path, work);
    return await _exec(args.first, args.sublist(1)) == 0;
  }

  Future<bool> _pdfPage(String path, String work) async {
    try {
      return await _exec('pdftoppm', [
                '-png',
                '-singlefile',
                '-f',
                '1',
                '-l',
                '1',
                '-scale-to',
                '$thumbnailSize',
                path,
                p.withoutExtension(work),
              ]) ==
              0 &&
          await _nonEmpty(work);
    } on ProcessException {
      return false; // poppler-utils not installed
    }
  }

  Future<bool> _videoFrame(String path, String work, String at) async =>
      await _exec('ffmpeg', [
            '-v',
            'error',
            '-y',
            '-ss',
            at,
            '-i',
            path,
            '-frames:v',
            '1',
            '-vf',
            "scale='min($thumbnailSize,iw)':-2",
            '-f',
            'image2',
            '-c:v',
            'png',
            work,
          ]) ==
          0 &&
      await _nonEmpty(work);

  Future<int> _exec(String exe, List<String> args, {File? stdoutTo}) async {
    final process = await Process.start(exe, args);
    final out = stdoutTo == null
        ? process.stdout.drain<void>()
        : process.stdout.pipe(stdoutTo.openWrite());
    unawaited(process.stderr.drain<void>());
    final code = await process.exitCode.timeout(
      _timeout,
      onTimeout: () {
        process.kill();
        return -1;
      },
    );
    await out;
    return code;
  }

  Future<void> _acquire() async {
    if (_running < _maxJobs) {
      _running++;
      return;
    }
    final turn = Completer<void>();
    _queue.add(turn);
    await turn.future;
  }

  void _release() {
    if (_queue.isNotEmpty) {
      _queue.removeAt(0).complete();
    } else {
      _running--;
    }
  }

  Future<ThumbnailerTable> _loadThumbnailers() async {
    final dataHome =
        _env['XDG_DATA_HOME'] ?? p.join(_env['HOME'] ?? '/', '.local/share');
    final dataDirs = (_env['XDG_DATA_DIRS'] ?? '/usr/local/share:/usr/share')
        .split(':')
        .where((d) => d.isNotEmpty);
    final table = <String, List<String>>{};
    // Earlier directories win, as in the spec: user, then system.
    for (final dir in [dataHome, ...dataDirs].reversed) {
      final folder = Directory(p.join(dir, 'thumbnailers'));
      if (!await folder.exists()) continue;
      await for (final file in folder.list()) {
        if (file is! File || !file.path.endsWith('.thumbnailer')) continue;
        try {
          table.addAll(parseThumbnailer(await file.readAsString()));
        } on FileSystemException {
          continue;
        }
      }
    }
    return table;
  }
}
