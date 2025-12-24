import 'package:photo_manager_app/features/sync_session/domain/entities/sync_session.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';


class StartSyncSessionUseCase {

  final SyncSessionRepository _syncSessionRepository;
  StartSyncSessionUseCase(this._syncSessionRepository);

  Future<SyncSession> call({required String deviceUuid}) async {
    if(deviceUuid.trim().isEmpty) {
      throw Exception("Invalid Device UUID");
    }

    return await _syncSessionRepository.startSyncSession(deviceUuid: deviceUuid.trim());
  }
}