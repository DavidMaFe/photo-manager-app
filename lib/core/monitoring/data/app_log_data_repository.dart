import 'package:photo_manager_app/core/monitoring/data/app_log_entry_model.dart';
import 'package:photo_manager_app/core/monitoring/data/app_log_queue_local_data_source.dart';
import 'package:photo_manager_app/core/monitoring/data/client_logs_remote_data_source.dart';
import 'package:photo_manager_app/core/monitoring/data/device_context.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_log_entry.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_log_repository.dart';

class AppLogDataRepository implements AppLogRepository {
  final AppLogQueueLocalDataSource localDataSource;
  final ClientLogsRemoteDataSource remoteDataSource;
  final DeviceContextProvider deviceContextProvider;

  AppLogDataRepository({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.deviceContextProvider,
  });

  @override
  Future<void> enqueue(AppLogEntry entry) => localDataSource.add(AppLogEntryModel.fromEntity(entry));

  @override
  Future<int> flush() async {
    final device = await deviceContextProvider.get();
    var sent = 0;
    while (true) {
      final queued = await localDataSource.getAll();
      if (queued.isEmpty) {
        return sent;
      }
      final batch = queued.take(ClientLogsRemoteDataSource.maxBatch).toList();
      await remoteDataSource.send(batch.map((entry) => entry.toRequestJson(device)).toList());
      await localDataSource.removeFirst(batch.length);
      sent += batch.length;
    }
  }
}
