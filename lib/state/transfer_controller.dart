import 'package:flutter/foundation.dart';

import '../core/result.dart';
import '../services/transfer_service.dart';

/// A copy or move in progress, shown in the progress panel.
class TransferJob extends ChangeNotifier {
  TransferJob({required this.move, required this.destDir, required int items})
    : _progress = TransferProgress(
        doneBytes: 0,
        totalBytes: 0,
        doneItems: 0,
        totalItems: items,
      );

  final bool move;
  final String destDir;
  final started = DateTime.now();
  TransferProgress _progress;
  bool _cancelled = false;

  TransferProgress get progress => _progress;
  bool get cancelled => _cancelled;

  /// Bytes per second since the job started.
  double get speed {
    final seconds = DateTime.now().difference(started).inMilliseconds / 1000;
    return seconds <= 0 ? 0 : _progress.doneBytes / seconds;
  }

  /// Estimated time left, or null until there's enough to estimate.
  Duration? get remaining {
    final rate = speed;
    final left = _progress.totalBytes - _progress.doneBytes;
    if (rate <= 0 || left <= 0) return null;
    return Duration(milliseconds: (left / rate * 1000).round());
  }

  void cancel() {
    _cancelled = true;
    notifyListeners();
  }

  void _update(TransferProgress progress) {
    _progress = progress;
    notifyListeners();
  }
}

/// Runs transfers for a window: questions about conflicts first, then the
/// copy in the background while [jobs] drive the progress panel.
class TransferController extends ChangeNotifier {
  TransferController(this._service);

  final TransferService _service;
  final _jobs = <TransferJob>[];

  List<TransferJob> get jobs => List.unmodifiable(_jobs);

  /// Null outcome: the user cancelled at a conflict question.
  Future<Result<TransferOutcome?>> run({
    required List<String> sources,
    required String destDir,
    required bool move,
    required String copySuffix,
    required ConflictResolver resolve,
  }) async {
    final planned = await _service.plan(
      sources: sources,
      destDir: destDir,
      move: move,
      copySuffix: copySuffix,
      resolve: resolve,
    );
    if (planned case Err(:final failure)) return Err(failure);
    final plan = (planned as Ok<TransferPlan?>).value;
    if (plan == null) return const Ok(null);
    if (plan.items.isEmpty) return const Ok(TransferOutcome());
    final job = TransferJob(
      move: move,
      destDir: destDir,
      items: plan.items.length,
    );
    _jobs.add(job);
    notifyListeners();
    try {
      return Ok(
        await _service.execute(
          plan,
          onProgress: job._update,
          isCancelled: () => job.cancelled,
        ),
      );
    } finally {
      _jobs.remove(job);
      notifyListeners();
      job.dispose();
    }
  }
}
