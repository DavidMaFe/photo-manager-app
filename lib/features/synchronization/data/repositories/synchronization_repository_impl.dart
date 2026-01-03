import 'package:photo_manager_app/features/synchronization/data/data_sources/synchronization_remote_data_source.dart';
import 'package:photo_manager_app/features/synchronization/domain/repositories/synchronization_repository.dart';


class SynchronizationRepositoryImpl implements SynchronizationRepository {

  final SynchronizationRemoteDataSource remoteDataSource;
  SynchronizationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SynchronizationResult> getSynchronizations({
    required String deviceUuid,
    required int page,
    int pageSize = 20
  }) async {

    final response = await remoteDataSource.getSynchronizations(
        deviceUuid: deviceUuid, page: page, pageSize: pageSize);

    return SynchronizationResult(sessions: response.syncSessions, hasNext: response.hasNext);
  }
}