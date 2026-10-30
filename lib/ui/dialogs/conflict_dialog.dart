import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../l10n/app_localizations.dart';
import '../../services/transfer_service.dart';
import '../../theme/finder_theme.dart';

/// Asks, per name conflict, whether to replace, keep both, skip or cancel,
/// with "apply to the rest" when more conflicts follow (Finder / Explorer).
ConflictResolver conflictResolver(BuildContext context) =>
    (name, destDir, remaining) async {
      if (!context.mounted) {
        return (choice: ConflictChoice.cancel, applyToAll: true);
      }
      final answer = await showDialog<ConflictAnswer>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ConflictDialog(
          name: name,
          folder: p.basename(destDir),
          remaining: remaining,
        ),
      );
      return answer ?? (choice: ConflictChoice.cancel, applyToAll: true);
    };

class _ConflictDialog extends StatefulWidget {
  const _ConflictDialog({
    required this.name,
    required this.folder,
    required this.remaining,
  });

  final String name;
  final String folder;
  final int remaining;

  @override
  State<_ConflictDialog> createState() => _ConflictDialogState();
}

class _ConflictDialogState extends State<_ConflictDialog> {
  bool _applyToAll = false;

  void _answer(ConflictChoice choice) =>
      Navigator.of(context).pop((choice: choice, applyToAll: _applyToAll));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        l10n.conflictTitle(widget.name, widget.folder),
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.conflictBody,
              style: const TextStyle(fontSize: FinderMetrics.fontSize),
            ),
            if (widget.remaining > 0) ...[
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _applyToAll,
                onChanged: (v) => setState(() => _applyToAll = v ?? false),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  l10n.conflictApplyToAll(widget.remaining),
                  style: const TextStyle(fontSize: FinderMetrics.fontSize),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _answer(ConflictChoice.cancel),
          child: Text(l10n.buttonCancel),
        ),
        TextButton(
          onPressed: () => _answer(ConflictChoice.skip),
          child: Text(l10n.conflictSkip),
        ),
        TextButton(
          onPressed: () => _answer(ConflictChoice.keepBoth),
          child: Text(l10n.conflictKeepBoth),
        ),
        FilledButton(
          onPressed: () => _answer(ConflictChoice.replace),
          child: Text(l10n.conflictReplace),
        ),
      ],
    );
  }
}
