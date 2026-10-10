
import 'package:photo_manager_app/features/sync_session/domain/entities/duplicate_files_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/encrypted_upload.dart';
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

  /// Uploads a file encrypted on this device. Returns the id of the file on the server.
  /// Throws OutdatedKeysFailure if the key of this device is no longer the current one of the account.
  Future<String> uploadFile({
    required String sessionId,
    required EncryptedUpload upload
  });

  Future<SyncResult> completeSyncSession({
    required String sessionId
  });

  Future<void> cancelSyncSession({
    required String sessionId
  });
}