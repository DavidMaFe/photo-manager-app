import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';


class SynchronizationResult {

  final List<Synchronization> sessions;
  final bool hasNext;

  const SynchronizationResult({required this.sessions, required this.hasNext});
}


abstract class SynchronizationRepository {

  Future<SynchronizationResult> getSynchronizations({
    required String deviceUuid,
    required int page,
    int pageSize = 20
  });
}