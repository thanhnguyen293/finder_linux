import 'dart:io';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/update_controller.dart';
import '../../theme/finder_theme.dart';
import '../app_services.dart';
import '../settings_scope.dart';
import 'settings_controls.dart';

/// Settings ▸ Advanced ▸ Updates: automatic checks, and check / update /
/// restart by hand.
class UpdatesSection extends StatelessWidget {
  const UpdatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final updates = AppServices.updatesOf(context);
    if (updates == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final s = SettingsScope.of(context);
    final palette = context.palette;
    return ListenableBuilder(
      listenable: updates,
      builder: (context, _) {
        final status = updates.status;
        final message = switch (status) {
          _ when !updates.supported => l10n.updateUnsupported,
          UpdateStatus.idle => '',
          UpdateStatus.checking => l10n.updateChecking,
          UpdateStatus.upToDate => l10n.updateUpToDate,
          UpdateStatus.available => l10n.updateAvailable,
          UpdateStatus.installing => l10n.updateInstalling,
          UpdateStatus.installed => l10n.updateInstalled,
          UpdateStatus.failed => l10n.updateFailed(updates.detail),
        };
        final (label, action) = switch (status) {
          UpdateStatus.available => (l10n.updateInstall, updates.install),
          UpdateStatus.installed => (
            l10n.updateRestart,
            () async {
              await updates.relaunch();
              exit(0);
            },
          ),
          UpdateStatus.checking ||
          UpdateStatus.installing => (l10n.updateCheckNow, null),
          _ => (l10n.updateCheckNow, updates.check),
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsUpdates,
              style: const TextStyle(
                fontSize: FinderMetrics.fontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            CheckRow(
              label: l10n.updateAutoCheck,
              value: s.checkForUpdates,
              onChanged: (v) =>
                  saveSettings(context, s.copyWith(checkForUpdates: v)),
            ),
            Row(
              spacing: 12,
              children: [
                OutlinedButton(
                  onPressed: updates.supported ? action : null,
                  child: Text(label),
                ),
                if (status == UpdateStatus.checking ||
                    status == UpdateStatus.installing)
                  const SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                Expanded(
                  child: Text(
                    status == UpdateStatus.installing &&
                            updates.detail.isNotEmpty
                        ? '$message\n${updates.detail}'
                        : message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: FinderMetrics.fontSizeSmall + 1,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
