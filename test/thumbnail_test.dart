import 'dart:io';

import 'package:finder_linux/models/file_entry.dart';
import 'package:finder_linux/services/thumbnail_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Smallest PDF poppler renders: one blank page with a filled square.
const _pdf = '''%PDF-1.4
1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj
2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj
3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 200 200] /Contents 4 0 R >> endobj
4 0 obj << /Length 24 >> stream
0 0 1 rg 50 50 100 100 re f
endstream endobj
trailer << /Root 1 0 R >>
%%EOF
''';

bool _has(String tool) => Process.runSync('which', [tool]).exitCode == 0;

void main() {
  test('reads thumbnailer files and fills their fields', () {
    final table = parseThumbnailer('''[Thumbnailer Entry]
TryExec=evince-thumbnailer
Exec=evince-thumbnailer -s %s %u %o
MimeType=application/pdf;application/postscript;
''');
    expect(table.keys, ['application/pdf', 'application/postscript']);
    expect(expandExec(table['application/pdf']!, '/a b/x.pdf', '/t/o.png'), [
      'evince-thumbnailer',
      '-s',
      '$thumbnailSize',
      'file:///a%20b/x.pdf',
      '/t/o.png',
    ]);
  });

  group('ThumbnailService', () {
    late Directory root;
    late ThumbnailService service;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('finder_thumbs');
      service = ThumbnailService(
        environment: {
          'HOME': root.path,
          'XDG_CACHE_HOME': p.join(root.path, 'cache'),
          'XDG_DATA_DIRS': '/usr/share',
        },
      );
    });

    tearDown(() => root.delete(recursive: true));

    Future<FileEntry> entry(String name) async {
      final path = p.join(root.path, name);
      final stat = await File(path).stat();
      return FileEntry(
        path: path,
        isDirectory: false,
        size: stat.size,
        modified: stat.modified,
        mode: stat.mode,
      );
    }

    test('only formats with a known tool are handled', () async {
      await File(p.join(root.path, 'a.txt')).writeAsString('x');
      await File(p.join(root.path, 'b.mkv')).writeAsString('x');
      expect(service.handles(await entry('a.txt')), isFalse);
      expect(service.handles(await entry('b.mkv')), isTrue);
    });

    test(
      'PDF pages are rendered and cached',
      () async {
        await File(p.join(root.path, 'doc.pdf')).writeAsString(_pdf);
        final e = await entry('doc.pdf');
        final thumb = await service.thumbnailFor(e);
        expect(thumb, isNotNull);
        expect(p.isWithin(service.cacheDir, thumb!), isTrue);
        expect(File(thumb).lengthSync(), greaterThan(0));
        expect(service.cached(e), thumb);
      },
      skip: _has('evince-thumbnailer') ? false : 'no evince-thumbnailer',
    );

    test(
      'videos get a frame, even when shorter than the seek point',
      () async {
        final video = p.join(root.path, 'clip.mp4');
        final made = await Process.run('ffmpeg', [
          '-v',
          'error',
          '-f',
          'lavfi',
          '-i',
          'testsrc=duration=1:size=160x120:rate=5',
          video,
        ]);
        expect(made.exitCode, 0, reason: '${made.stderr}');
        expect(await service.thumbnailFor(await entry('clip.mp4')), isNotNull);
      },
      skip: _has('ffmpeg') ? false : 'no ffmpeg',
    );

    test(
      'office files use their embedded preview; failures are remembered',
      () async {
        final png = File(p.join(root.path, 'Thumbnails', 'thumbnail.png'));
        await png.create(recursive: true);
        await png.writeAsBytes([0x89, 0x50, 0x4E, 0x47]);
        final zip = await Process.run('zip', [
          '-q',
          '-r',
          'note.odt',
          'Thumbnails',
        ], workingDirectory: root.path);
        expect(zip.exitCode, 0);
        final odt = await entry('note.odt');
        expect(await service.thumbnailFor(odt), isNotNull);

        await File(p.join(root.path, 'plain.docx')).writeAsString('not zip');
        final docx = await entry('plain.docx');
        expect(await service.thumbnailFor(docx), isNull);
        final fails = Directory(
          service.cacheDir,
        ).listSync().where((f) => f.path.endsWith('.fail'));
        expect(fails, hasLength(1));
      },
      skip: _has('unzip') && _has('zip') ? false : 'no zip/unzip',
    );
  });
}
