import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';


class UploadFileUseCase {

  final SyncSessionRepository _syncSessionRepository;
  UploadFileUseCase(this._syncSessionRepository);

  Future<bool> call({required String sessionId, required SyncFile file}) async {
    try {
      if (sessionId.trim().isEmpty) {
        throw Exception("Invalid Sync Session ID");
      }

      if (!file.file.existsSync()) {
        return false;
      }

      final maxSizeMB = file.isImage ? 20 : 100;
      if (file.sizeMB > maxSizeMB) {
        return false;
      }

      if (file.hash.trim().isEmpty) {
        return false;
      }

      if (!file.isImage && !file.isVideo) {
        return false;
      }

      return await _syncSessionRepository.uploadFile(
          sessionId: sessionId, file: file
      );

    } catch(e) {
      return false;
    }
  }
}