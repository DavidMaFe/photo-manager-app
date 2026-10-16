import 'package:photo_manager_app/features/downloads/data/data_sources/download_queue_local_data_source.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_progress.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/queued_download.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/download_queue_repository.dart';

class DownloadQueueDataRepository implements DownloadQueueRepository {
  final DownloadQueueLocalDataSource localDataSource;

  DownloadQueueDataRepository({required this.localDataSource});

  @override
  Future<void> enqueue(List<QueuedDownload> downloads) => localDataSource.enqueue(downloads);

  @override
  Future<List<QueuedDownload>> pending({int limit = 200}) => localDataSource.pending(limit);

  @override
  Future<bool> isPending(String fileId) => localDataSource.isPending(fileId);

  @override
  Future<void> markSaved(String fileId) =>
      localDataSource.setState(fileId, DownloadQueueLocalDataSourceImpl.stateSaved);

  @override
  Future<void> markFailed(String fileId) =>
      localDataSource.setState(fileId, DownloadQueueLocalDataSourceImpl.stateFailed);

  @override
  Future<List<String>> savedIds() => localDataSource.savedIds();

  @override
  Future<DownloadProgress> progress() => localDataSource.progress();

  @override
  Future<void> cancelPending() => localDataSource.deletePending();
}
