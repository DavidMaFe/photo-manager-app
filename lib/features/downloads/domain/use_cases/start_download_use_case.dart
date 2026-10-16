import 'package:photo_manager_app/features/downloads/domain/entities/download_failures.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_plan.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/queued_download.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/download_queue_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/services/download_scheduler.dart';

/// Queues the files of [DownloadPlan] and starts saving them in the background. [album] is the album of the gallery
/// they go to (the name of the album of Photo Manager); null for the main one.
class StartDownloadUseCase {
  final DownloadQueueRepository _queue;
  final DownloadScheduler _scheduler;

  StartDownloadUseCase(this._queue, this._scheduler);

  /// Throws [NotEnoughSpaceFailure] if the files do not fit.
  Future<void> call(DownloadPlan plan, {String? album}) async {
    if (plan.isEmpty) return;
    if (!plan.fits) {
      throw NotEnoughSpaceFailure(messageParams: {
        'needed': plan.bytesToDownload + DownloadPlan.reservedBytes,
        'free': plan.storage.freeBytes,
      });
    }
    await _queue.enqueue([
      for (final file in plan.toDownload) QueuedDownload(fileId: file.id, album: album, sizeBytes: file.sizeBytes),
    ]);
    await _scheduler.schedule();
  }
}
