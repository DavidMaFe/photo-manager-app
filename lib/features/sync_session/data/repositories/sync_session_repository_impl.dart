import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/remote/sync_session_remote_data_source.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/duplicate_files_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/encrypted_upload.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_session.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';


class SyncSessionRepositoryImpl implements SyncSessionRepository {

  final SyncSessionRemoteDataSource remoteDataSource;

  SyncSessionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SyncSession> startSyncSession({required String deviceUuid}) async {
    return await remoteDataSource.startSyncSession(deviceUuid);
  }

  @override
  Future<DuplicateFilesResult> checkDuplicates({required String sessionId, required List<String> fileHashes}) async {
    return await remoteDataSource.checkDuplicates(sessionId, fileHashes);
  }

  @override
  Future<String> uploadFile({required String sessionId, required EncryptedUpload upload}) async {
    try {
      final result = await remoteDataSource.uploadFile(sessionId, upload);
      return result.fileId;
    } on ApiException catch (e) {
      // The current key of the account is not the one of this device: it changed on another device
      if (e.code == 'INVALID_FILE_KEY_VERSION') {
        throw const OutdatedKeysFailure();
      }
      rethrow;
    }
  }

  @override
  Future<SyncResult> completeSyncSession({required String sessionId}) async {
    return await remoteDataSource.completeSyncSession(sessionId);
  }

  @override
  Future<void> cancelSyncSession({required String sessionId}) async {
    await remoteDataSource.cancelSyncSession(sessionId);
  }
}