import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';


class CompleteSyncSessionUseCase {

  final SyncSessionRepository _syncSessionRepository;
  CompleteSyncSessionUseCase(this._syncSessionRepository);

  Future<SyncResult> call({required String sessionId}) async {

    if (sessionId.trim().isEmpty) {
      throw Exception("Invalid Sync Session ID");
    }

    return await _syncSessionRepository.completeSyncSession(sessionId: sessionId.trim());
  }
}