import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../models/file_entry.dart';
import '../../services/thumbnail_service.dart';
import '../../theme/finder_theme.dart';
import '../app_services.dart';
import '../settings_scope.dart';

/// Icon artwork tint per file kind.
const _kindTint = <FileKind, Color>{
  FileKind.image: Color(0xFFAF52DE),
  FileKind.video: Color(0xFFFF9500),
  FileKind.audio: Color(0xFFFF2D55),
  FileKind.text: Color(0xFF8E8E93),
  FileKind.code: Color(0xFF5856D6),
  FileKind.pdf: Color(0xFFFF3B30),
  FileKind.archive: Color(0xFFA2845E),
  FileKind.document: Color(0xFF007AFF),
  FileKind.spreadsheet: Color(0xFF34C759),
  FileKind.presentation: Color(0xFFFF9F0A),
  FileKind.application: Color(0xFF5AC8FA),
  FileKind.other: Color(0xFF8E8E93),
};

const _kindGlyph = <FileKind, IconData>{
  FileKind.image: CupertinoIcons.photo_fill,
  FileKind.video: CupertinoIcons.film_fill,
  FileKind.audio: CupertinoIcons.music_note_2,
  FileKind.text: CupertinoIcons.doc_plaintext,
  FileKind.code: CupertinoIcons.chevron_left_slash_chevron_right,
  FileKind.pdf: CupertinoIcons.doc_richtext,
  FileKind.archive: CupertinoIcons.archivebox,
  FileKind.document: CupertinoIcons.doc_text,
  FileKind.spreadsheet: CupertinoIcons.table,
  FileKind.presentation: CupertinoIcons.chart_bar_square,
  FileKind.application: CupertinoIcons.app_badge,
  FileKind.other: CupertinoIcons.doc,
};

class FileIcon extends StatelessWidget {
  const FileIcon({
    super.key,
    required this.entry,
    required this.size,
    this.thumbnail = false,
  });

  final FileEntry entry;
  final double size;

  /// Render a preview of the file's content: images directly; PDFs,
  /// videos, documents and other formats through [ThumbnailService].
  final bool thumbnail;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (entry.isDirectory) {
      return Icon(
        CupertinoIcons.folder_fill,
        size: size,
        color: palette.folder,
      );
    }
    final tint = _kindTint[entry.kind] ?? palette.textSecondary;
    final glyph = _kindGlyph[entry.kind] ?? CupertinoIcons.doc;
    // Small rows (list, columns, path bar) get a plain glyph; larger sizes
    // draw a paper sheet. Either is the fallback while a thumbnail loads.
    final Widget page = size < 32
        ? Icon(glyph, size: size * 0.9, color: tint)
        : _DocumentPage(
            size: size,
            tint: tint,
            glyph: glyph,
            label: entry.extension,
          );
    if (!thumbnail || !SettingsScope.of(context).showThumbnails) return page;
    if (flutterDecodableImages.contains(entry.extension)) {
      return _Thumbnail(file: entry.path, size: size, fallback: page);
    }
    final service = AppServices.thumbnailsOf(context);
    if (service == null || !service.handles(entry)) return page;
    return _GeneratedThumbnail(
      service: service,
      entry: entry,
      size: size,
      fallback: page,
    );
  }
}

/// Waits for [ThumbnailService] to make a preview, showing [fallback]
/// meanwhile and if none can be made.
class _GeneratedThumbnail extends StatefulWidget {
  const _GeneratedThumbnail({
    required this.service,
    required this.entry,
    required this.size,
    required this.fallback,
  });

  final ThumbnailService service;
  final FileEntry entry;
  final double size;
  final Widget fallback;

  @override
  State<_GeneratedThumbnail> createState() => _GeneratedThumbnailState();
}

class _GeneratedThumbnailState extends State<_GeneratedThumbnail> {
  String? _file;

  @override
  void initState() {
    super.initState();
    _request();
  }

  @override
  void didUpdateWidget(_GeneratedThumbnail old) {
    super.didUpdateWidget(old);
    if (old.entry != widget.entry) _request();
  }

  void _request() {
    final entry = widget.entry;
    _file = widget.service.cached(entry);
    if (_file != null) return;
    widget.service.thumbnailFor(entry).then((file) {
      if (mounted && widget.entry == entry && file != null) {
        setState(() => _file = file);
      }
    });
  }

  @override
  Widget build(BuildContext context) => switch (_file) {
    final file? => _Thumbnail(
      file: file,
      size: widget.size,
      fallback: widget.fallback,
    ),
    null => widget.fallback,
  };
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.file,
    required this.size,
    required this.fallback,
  });

  final String file;
  final double size;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Image.file(
        File(file),
        // At least 32px decoded, so tiny row thumbnails stay crisp.
        cacheWidth:
            (math.max(size, 32) * MediaQuery.devicePixelRatioOf(context) * 1.5)
                .round(),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => fallback,
        // Fade the thumbnail in over an empty slot; swapping a document icon
        // for the picture read as a flicker.
        frameBuilder: (_, child, frame, wasSynchronouslyLoaded) =>
            wasSynchronouslyLoaded
            ? child
            : AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: child,
              ),
      ),
    );
  }
}

/// Paper sheet with a folded corner, a kind glyph and the extension label.
class _DocumentPage extends StatelessWidget {
  const _DocumentPage({
    required this.size,
    required this.tint,
    required this.glyph,
    required this.label,
  });

  final double size;
  final Color tint;
  final IconData glyph;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final width = size * 0.78;
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: CustomPaint(
          painter: _PagePainter(
            fill: palette.content,
            border: palette.separator,
          ),
          child: SizedBox(
            width: width,
            height: size,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(glyph, size: size * 0.32, color: tint),
                if (label.isNotEmpty && label.length <= 5)
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: size * 0.13,
                      fontWeight: FontWeight.w700,
                      color: tint,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PagePainter extends CustomPainter {
  _PagePainter({required this.fill, required this.border});

  final Color fill;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final fold = size.width * 0.28;
    final page = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - fold, 0)
      ..lineTo(size.width, fold)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawShadow(page, const Color(0x55000000), 1.5, false);
    canvas.drawPath(page, Paint()..color = fill);
    canvas.drawPath(
      page,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final corner = Path()
      ..moveTo(size.width - fold, 0)
      ..lineTo(size.width - fold, fold)
      ..lineTo(size.width, fold);
    canvas.drawPath(
      corner,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_PagePainter old) =>
      old.fill != fill || old.border != border;
}
