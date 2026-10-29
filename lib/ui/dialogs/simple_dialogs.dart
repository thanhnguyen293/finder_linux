import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../l10n/app_localizations.dart';
import '../../models/file_entry.dart';
import '../../services/file_system_service.dart';
import '../../theme/finder_theme.dart';
import '../formatting.dart';
import '../widgets/file_icon.dart';

Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.palette.trafficClose,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(action),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Returns the absolute path typed by the user (with `~` expanded).
Future<String?> askGoToFolder(
  BuildContext context, {
  required String home,
  required String current,
}) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController();
  String resolve(String raw) {
    final text = raw.trim();
    final expanded = text == '~' || text.startsWith('~/')
        ? home + text.substring(1)
        : text;
    return p.normalize(
      p.isAbsolute(expanded) ? expanded : p.join(current, expanded),
    );
  }

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        l10n.goToFolderTitle,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.goToFolderHint,
            isDense: true,
          ),
          onSubmitted: (v) => Navigator.pop(context, resolve(v)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, resolve(controller.text)),
          child: Text(l10n.buttonGo),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}

Future<void> showGetInfo(
  BuildContext context,
  FileEntry entry,
  FileSystemService fs,
) {
  final l10n = AppLocalizations.of(context);
  final palette = context.palette;
  Widget row(String label, Widget value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            '$label:',
            textAlign: TextAlign.end,
            style: TextStyle(color: palette.textSecondary),
          ),
        ),
        const SizedBox(width: FinderMetrics.gap),
        Expanded(child: value),
      ],
    ),
  );

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      content: SizedBox(
        width: 380,
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontSize: FinderMetrics.fontSize),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 12,
                children: [
                  FileIcon(entry: entry, size: 48, thumbnail: true),
                  Expanded(
                    child: Text(
                      entry.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              row(l10n.infoKind, Text(kindLabel(l10n, entry))),
              row(
                l10n.infoSize,
                entry.isDirectory
                    ? FutureBuilder<int?>(
                        future: fs.directorySize(entry.path),
                        builder: (_, s) => Text(
                          s.connectionState == ConnectionState.done
                              ? (s.data == null ? '--' : formatBytes(s.data!))
                              : l10n.infoCalculating,
                        ),
                      )
                    : Text(formatBytes(entry.size)),
              ),
              row(l10n.infoWhere, SelectableText(entry.parent)),
              row(
                l10n.infoModified,
                Text(formatModified(context, entry.modified)),
              ),
              row(
                l10n.infoPermissions,
                Text(
                  permissionString(entry.mode),
                  style: const TextStyle(fontFamily: 'Ubuntu Sans Mono'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.buttonOk),
        ),
      ],
    ),
  );
}

/// `rwxr-xr-x` from POSIX mode bits.
String permissionString(int mode) {
  const flags = 'rwxrwxrwx';
  return [
    for (var i = 0; i < 9; i++) (mode >> (8 - i)) & 1 == 1 ? flags[i] : '-',
  ].join();
}
