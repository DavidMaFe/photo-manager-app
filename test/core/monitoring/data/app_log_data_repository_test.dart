import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/monitoring/data/app_log_data_repository.dart';
import 'package:photo_manager_app/core/monitoring/data/app_log_entry_model.dart';
import 'package:photo_manager_app/core/monitoring/data/app_log_queue_local_data_source.dart';
import 'package:photo_manager_app/core/monitoring/data/client_logs_remote_data_source.dart';
import 'package:photo_manager_app/core/monitoring/data/device_context.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_log_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockClientLogsRemoteDataSource extends Mock implements ClientLogsRemoteDataSource {}

class FakeDeviceContextProvider implements DeviceContextProvider {
  @override
  Future<DeviceContext> get() async => const DeviceContext(
      appVersion: '1.4.0', build: '11', platform: 'android', osVersion: '16', deviceModel: 'SM-S911B');
}

void main() {
  late AppLogQueueLocalDataSource queue;
  late MockClientLogsRemoteDataSource remote;
  late AppLogDataRepository repository;

  AppLogEntry entry(int i) => AppLogEntry(level: AppLogLevel.error, event: 'EVENT_$i', occurredAt: DateTime.utc(2026));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    queue = AppLogQueueLocalDataSource(sharedPreferences: await SharedPreferences.getInstance());
    remote = MockClientLogsRemoteDataSource();
    when(() => remote.send(any())).thenAnswer((_) async {});
    repository = AppLogDataRepository(
        localDataSource: queue, remoteDataSource: remote, deviceContextProvider: FakeDeviceContextProvider());
  });

  group('AppLogDataRepository', () {
    test('should send the queue with the device and empty it', () async {
      await repository.enqueue(entry(1));
      await repository.enqueue(entry(2));

      expect(await repository.flush(), 2);

      final sent = verify(() => remote.send(captureAny())).captured.single as List<Map<String, dynamic>>;
      expect(sent.map((line) => line['event']), ['EVENT_1', 'EVENT_2']);
      expect(sent.first['deviceModel'], 'SM-S911B');
      expect(await queue.getAll(), isEmpty);
    });

    test('should send in batches of fifty', () async {
      for (var i = 0; i < 120; i++) {
        await queue.add(AppLogEntryModel.fromEntity(entry(i)));
      }

      expect(await repository.flush(), 120);

      final batches = verify(() => remote.send(captureAny())).captured.cast<List>();
      expect(batches.map((batch) => batch.length), [50, 50, 20]);
    });

    test('should keep the lines when the sending fails', () async {
      when(() => remote.send(any())).thenThrow(Exception('offline'));
      await repository.enqueue(entry(1));

      expect(() => repository.flush(), throwsException);
      await untilCalled(() => remote.send(any()));
      expect(await queue.getAll(), hasLength(1));
    });

    test('should send nothing with an empty queue', () async {
      expect(await repository.flush(), 0);
      verifyNever(() => remote.send(any()));
    });
  });
}
