import 'package:photo_manager_app/features/sync_session/data/data_sources/remote/sync_session_remote_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_file_model.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/duplicate_files_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';
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
  Future<String> uploadFile({required String sessionId, required SyncFile file}) async {
    final fileModel = SyncFileModel.fromEntity(file);
    final result = await remoteDataSource.uploadFile(sessionId, fileModel);
    return result.fileId;
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