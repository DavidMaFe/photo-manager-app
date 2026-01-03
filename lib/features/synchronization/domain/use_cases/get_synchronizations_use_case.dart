
import 'package:photo_manager_app/features/synchronization/domain/repositories/synchronization_repository.dart';

class GetSynchronizationsUseCase {

  final SynchronizationRepository _repository;
  GetSynchronizationsUseCase(this._repository);

  Future<SynchronizationResult> call({
    required String deviceUuid,
    int page = 0,
    int pageSize = 20
  }) async {
    return await _repository.getSynchronizations(deviceUuid: deviceUuid,
        page: page, pageSize: pageSize);
  }
}