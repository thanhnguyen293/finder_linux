import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../models/file_entry.dart';
import '../../theme/finder_theme.dart';
import '../formatting.dart';
import '../widgets/file_icon.dart';

const _maxTextPreviewBytes = 256 * 1024;

/// Space-bar preview: images, text/code, or a large icon with details.
/// [localCopy] gives a readable file for [entry] (device files are pulled).
Future<void> showQuickLook(
  BuildContext context,
  FileEntry entry, {
  required VoidCallback onOpen,
  required Future<String?> Function(String path) localCopy,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black26,
    builder: (_) => CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () =>
            Navigator.of(context).pop(),
      },
      child: Focus(
        autofocus: true,
        child: _QuickLook(entry: entry, onOpen: onOpen, localCopy: localCopy),
      ),
    ),
  );
}

class _QuickLook extends StatelessWidget {
  const _QuickLook({
    required this.entry,
    required this.onOpen,
    required this.localCopy,
  });

  final FileEntry entry;
  final VoidCallback onOpen;
  final Future<String?> Function(String path) localCopy;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.all(40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width * 0.75,
          maxHeight: size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: palette.toolbar,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: FinderMetrics.fontSize,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onOpen();
                    },
                    child: Text(AppLocalizations.of(context).menuOpen),
                  ),
                ],
              ),
            ),
            Flexible(
              child: _Preview(entry: entry, localCopy: localCopy),
            ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatefulWidget {
  const _Preview({required this.entry, required this.localCopy});

  final FileEntry entry;
  final Future<String?> Function(String path) localCopy;

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  FileEntry get entry => widget.entry;

  bool get _isImage => entry.kind == FileKind.image && entry.extension != 'svg';

  bool get _isText =>
      (entry.kind == FileKind.text || entry.kind == FileKind.code) &&
      entry.size <= _maxTextPreviewBytes;

  // Only what will be shown is fetched (pulling a device video would be
  // wasted on the details view).
  late final Future<String?> _file = _isImage || _isText
      ? widget.localCopy(entry.path)
      : Future.value();

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: _file,
    builder: (context, snap) => switch (snap.data) {
      final file? => _content(file),
      null when snap.connectionState == ConnectionState.done => _Details(
        entry: entry,
      ),
      null => const SizedBox(height: 200),
    },
  );

  Widget _content(String file) {
    if (_isImage) {
      return InteractiveViewer(
        child: Image.file(
          File(file),
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _Details(entry: entry),
        ),
      );
    }
    if (_isText) {
      return FutureBuilder<String>(
        future: File(
          file,
        ).readAsBytes().then((b) => utf8.decode(b, allowMalformed: true)),
        builder: (context, snap) => snap.hasData
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  snap.data!,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu Sans Mono',
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              )
            : const SizedBox(height: 200),
      );
    }
    return _Details(entry: entry);
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.entry});

  final FileEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: FinderMetrics.gap,
        children: [
          FileIcon(entry: entry, size: 128),
          Text(
            entry.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          Text(
            [
              kindLabel(l10n, entry),
              if (!entry.isDirectory) formatBytes(entry.size),
            ].join(' — '),
            style: TextStyle(color: palette.textSecondary),
          ),
          Text(
            formatModified(context, entry.modified),
            style: TextStyle(color: palette.textSecondary),
          ),
          if (entry.kind != FileKind.folder && entry.kind != FileKind.image)
            Text(
              l10n.quickLookNoPreview,
              style: TextStyle(color: palette.textSecondary, fontSize: 11),
            ),
        ],
      ),
    );
  }
}
