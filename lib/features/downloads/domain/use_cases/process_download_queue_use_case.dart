import 'package:photo_manager_app/features/downloads/domain/entities/downloadable_file.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/download_queue_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/server_files_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/save_original_to_gallery_use_case.dart';

/// Outcome of a run of the queue.
class DownloadRunResult {
  final int saved;
  final int failed;

  /// Whether files are still pending (the run stopped at its time limit).
  final bool hasPending;

  const DownloadRunResult({required this.saved, required this.failed, required this.hasPending});
}

/// Saves the queued files one after another, in batches of 200 (what the server answers at once), until the queue is
/// empty or [budget] runs out. A file that fails is marked and the rest go on. The files saved are reported to the
/// server after each batch. Files removed from the queue meanwhile (cancelled) are not saved.
class ProcessDownloadQueueUseCase {
  static const int batchSize = 200;

  final DownloadQueueRepository _queue;
  final ServerFilesRepository _serverFiles;
  final SaveOriginalToGalleryUseCase _saveOriginal;
  final DateTime Function() _clock;

  ProcessDownloadQueueUseCase(this._queue, this._serverFiles, this._saveOriginal, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  Future<DownloadRunResult> call({required Duration budget, void Function()? onFileDone}) async {
    final deadline = _clock().add(budget);
    var saved = 0;
    var failed = 0;

    while (true) {
      final batch = await _queue.pending(limit: batchSize);
      if (batch.isEmpty) {
        return DownloadRunResult(saved: saved, failed: failed, hasPending: false);
      }

      final details = {for (final file in await _serverFiles.downloadable([for (final q in batch) q.fileId])) file.id: file};
      final savedInBatch = <String>[];
      try {
        for (final queued in batch) {
          if (_clock().isAfter(deadline)) {
            return DownloadRunResult(saved: saved, failed: failed, hasPending: true);
          }
          // Cancelled while this batch was running
          if (!await _queue.isPending(queued.fileId)) {
            continue;
          }
          final DownloadableFile? file = details[queued.fileId];
          try {
            if (file == null) {
              // Sent to the trash or deleted since it was queued
              throw StateError('Not downloadable');
            }
            await _saveOriginal(file, album: queued.album);
            await _queue.markSaved(queued.fileId);
            savedInBatch.add(queued.fileId);
            saved++;
          } catch (_) {
            await _queue.markFailed(queued.fileId);
            failed++;
          }
          onFileDone?.call();
        }
      } finally {
        if (savedInBatch.isNotEmpty) {
          try {
            await _serverFiles.markOnDevice(savedInBatch);
          } catch (_) {
            // Only the "deleted from the device" mark of the uploading device: the files are saved anyway
          }
        }
      }
    }
  }
}
