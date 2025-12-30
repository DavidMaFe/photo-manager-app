import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';

import '../entities/upload_result.dart';


class UploadFileUseCase {

  final SyncSessionRepository _syncSessionRepository;
  UploadFileUseCase(this._syncSessionRepository);

  Future<UploadResult> call({required String sessionId, required SyncFile file}) async {
    if (sessionId.trim().isEmpty) {
      throw Exception("Invalid Sync Session ID");
    }

    final serverId = await _syncSessionRepository.uploadFile(
        sessionId: sessionId, file: file
    );

    return UploadResult(serverFileId: serverId);
  }
}