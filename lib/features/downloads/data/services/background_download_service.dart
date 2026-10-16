import 'package:photo_manager_app/core/services/sync_lock.dart';
import 'package:photo_manager_app/core/services/sync_log_service.dart';
import 'package:photo_manager_app/core/services/sync_notification_service.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/download_queue_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/services/download_scheduler.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/process_download_queue_use_case.dart';

/// One run of the download task of WorkManager: it takes the lock shared with the sync, saves files with a progress
/// notification for at most [budget] and appends the next run if files remain. Returns false when a sync holds the
/// lock, so WorkManager tries again later.
class BackgroundDownloadService {
  /// Below the 10 minutes after which WorkManager stops a task.
  static const Duration budget = Duration(minutes: 8);

  final ProcessDownloadQueueUseCase processQueue;
  final DownloadQueueRepository queue;
  final DownloadScheduler scheduler;
  final SyncLock lock;
  final SyncNotificationService notifications;
  final SyncLogService log;

  BackgroundDownloadService({
    required this.processQueue,
    required this.queue,
    required this.scheduler,
    required this.lock,
    required this.notifications,
    required this.log,
  });

  Future<bool> execute() async {
    if ((await queue.pending(limit: 1)).isEmpty) {
      log.write('⬇ Descarga: nada pendiente');
      return true;
    }
    final lockCheck = await lock.check();
    if (lockCheck.isHeld) {
      log.write('⬇ Descarga: hay una sincronización en curso — se reintentará');
      return false;
    }

    await lock.acquire();
    DownloadRunResult? result;
    try {
      await _notifyProgress();
      result = await processQueue(budget: budget, onFileDone: _notifyProgress);
      log.write('⬇ Descarga: ${result.saved} guardados, ${result.failed} fallidos'
          '${result.hasPending ? ' — continúa en otra tarea' : ''}');
    } finally {
      await lock.release();
      await notifications.hideForegroundNotification();
    }

    if (result.hasPending) {
      await scheduler.schedule();
    } else {
      final progress = await queue.progress();
      await notifications.showDownloadFinished(saved: progress.saved, failed: progress.failed);
    }
    return true;
  }

  Future<void> _notifyProgress() async {
    final progress = await queue.progress();
    await notifications.showDownloadProgress(saved: progress.saved + progress.failed, total: progress.total);
  }
}
