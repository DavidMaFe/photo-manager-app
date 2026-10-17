import 'package:photo_manager_app/features/downloads/domain/repositories/download_queue_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/services/download_scheduler.dart';

/// Stops the download: the files still pending leave the queue; those already saved stay in the gallery.
class CancelDownloadUseCase {
  final DownloadQueueRepository _queue;
  final DownloadScheduler _scheduler;

  CancelDownloadUseCase(this._queue, this._scheduler);

  Future<void> call() async {
    await _queue.cancelPending();
    await _scheduler.cancel();
  }
}
