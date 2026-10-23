import 'package:photo_manager_app/features/sync_session/domain/entities/backup_scan.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/backup_progress_repository.dart';

/// After a completed backup (ROADMAP-local-albums.md): the next one looks at the gallery from where this one started,
/// and tries again what this one skipped. A backup that did not complete (failed, cancelled) changes nothing, so the
/// next one looks at the same files again.
class CompleteBackupScanUseCase {
  final BackupProgressRepository _progress;

  CompleteBackupScanUseCase(this._progress);

  /// [skippedLocalIds]: the files of [scan] that were not uploaded nor found on the server.
  Future<void> call(BackupScan scan, Set<String> skippedLocalIds) async {
    final userId = scan.userId;
    if (userId == null) {
      return;
    }
    await _progress.replacePending(userId, {...skippedLocalIds, ...scan.unreadableIds});
    await _progress.saveWatermark(userId, scan.startedAt);
  }
}
