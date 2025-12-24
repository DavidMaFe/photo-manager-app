
import 'package:photo_manager_app/features/sync_session/domain/entities/duplicate_files_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_session.dart';

abstract class SyncSessionRepository {

  Future<SyncSession> startSyncSession({
    required String deviceUuid
  });

  Future<DuplicateFilesResult> checkDuplicates({
    required String sessionId,
    required List<String> fileHashes
  });

  Future<bool> uploadFile({
    required String sessionId,
    required SyncFile file
  });

  Future<SyncResult> completeSyncSession({
    required String sessionId
  });

  Future<void> cancelSyncSession({
    required String sessionId
  });
}