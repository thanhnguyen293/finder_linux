import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../l10n/app_localizations.dart';
import '../../state/transfer_controller.dart';
import '../../theme/finder_theme.dart';
import '../formatting.dart';
import 'glass_panel.dart';
import 'hover_button.dart';

/// Jobs shorter than this never show a panel, so quick copies don't flash.
const _showAfter = Duration(milliseconds: 400);

/// Bottom-right card listing running copies and moves: item, bytes, speed,
/// time left and a cancel button.
class TransferPanel extends StatelessWidget {
  const TransferPanel({super.key, required this.controller});

  final TransferController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final jobs = controller.jobs;
        if (jobs.isEmpty) return const SizedBox.shrink();
        return Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 16, 56),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [for (final job in jobs) _JobCard(job: job)],
            ),
          ),
        );
      },
    );
  }
}

class _JobCard extends StatefulWidget {
  const _JobCard({required this.job});

  final TransferJob job;

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  late bool _visible =
      DateTime.now().difference(widget.job.started) >= _showAfter;
  Timer? _reveal;

  @override
  void initState() {
    super.initState();
    if (!_visible) {
      _reveal = Timer(_showAfter, () => setState(() => _visible = true));
    }
  }

  @override
  void dispose() {
    _reveal?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final secondary = TextStyle(
      fontSize: FinderMetrics.fontSizeSmall,
      color: palette.textSecondary,
    );
    return ListenableBuilder(
      listenable: widget.job,
      builder: (context, _) {
        final job = widget.job;
        final progress = job.progress;
        final dest = p.basename(job.destDir);
        final remaining = job.remaining;
        return GlassPanel(
          tint: palette.toolbar,
          child: Container(
            width: 340,
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Text(
                        job.move
                            ? l10n.transferMoving(progress.totalItems, dest)
                            : l10n.transferCopying(progress.totalItems, dest),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: FinderMetrics.fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      LinearProgressIndicator(
                        value: progress.fraction,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(3),
                        color: palette.accent,
                        backgroundColor: palette.controlHover,
                      ),
                      Text(
                        [
                          if (progress.totalBytes > 0)
                            l10n.transferBytes(
                              formatBytes(progress.doneBytes),
                              formatBytes(progress.totalBytes),
                            ),
                          if (job.speed > 0)
                            '${formatBytes(job.speed.round())}/s',
                          if (remaining != null)
                            l10n.transferRemaining(_clock(remaining)),
                        ].join(' — '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: secondary,
                      ),
                      if (progress.current case final current?)
                        Text(
                          current,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: secondary,
                        ),
                    ],
                  ),
                ),
                HoverButton(
                  tooltip: l10n.buttonCancel,
                  padding: const EdgeInsets.all(4),
                  onPressed: job.cancelled ? null : job.cancel,
                  child: const Icon(CupertinoIcons.xmark_circle_fill, size: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// m:ss, or h:mm:ss for long copies.
  static String _clock(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '$m:${two(s)}';
  }
}
