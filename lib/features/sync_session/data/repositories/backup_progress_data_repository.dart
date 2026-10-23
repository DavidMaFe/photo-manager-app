import 'package:photo_manager_app/features/sync_session/data/data_sources/local/backup_progress_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/backup_progress_repository.dart';

class BackupProgressDataRepository implements BackupProgressRepository {
  final BackupProgressLocalDataSource localDataSource;

  BackupProgressDataRepository({required this.localDataSource});

  @override
  Future<DateTime?> watermark(String userId) => localDataSource.watermark(userId);

  @override
  Future<void> saveWatermark(String userId, DateTime scanStartedAt) =>
      localDataSource.saveWatermark(userId, scanStartedAt);

  @override
  Future<Set<String>> pending(String userId) => localDataSource.pending(userId);

  @override
  Future<void> replacePending(String userId, Set<String> localIds) =>
      localDataSource.replacePending(userId, localIds);

  @override
  Future<void> addPending(String userId, Set<String> localIds) => localDataSource.addPending(userId, localIds);
}
