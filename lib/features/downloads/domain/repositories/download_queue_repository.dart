import 'package:photo_manager_app/features/downloads/domain/entities/download_progress.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/queued_download.dart';

/// The files waiting to be saved, shared by the screen that queues them and the background task that saves them.
abstract class DownloadQueueRepository {
  /// Adds [downloads] after the ones still pending; files already queued are skipped. When nothing was pending the
  /// files of the previous download are forgotten first, so the progress starts again.
  Future<void> enqueue(List<QueuedDownload> downloads);

  /// The next [limit] files to save, in order.
  Future<List<QueuedDownload>> pending({int limit = 200});

  /// Whether the file is still waiting (false once saved, failed or cancelled).
  Future<bool> isPending(String fileId);

  Future<void> markSaved(String fileId);

  Future<void> markFailed(String fileId);

  /// Files saved since the download started.
  Future<List<String>> savedIds();

  Future<DownloadProgress> progress();

  /// Removes the files still pending (the saved ones stay, for the progress).
  Future<void> cancelPending();
}
