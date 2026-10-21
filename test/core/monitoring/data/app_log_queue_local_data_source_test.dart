import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/monitoring/data/app_log_entry_model.dart';
import 'package:photo_manager_app/core/monitoring/data/app_log_queue_local_data_source.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_log_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppLogQueueLocalDataSource queue;

  AppLogEntryModel entry(int i) =>
      AppLogEntryModel(level: AppLogLevel.warn, event: 'EVENT_$i', occurredAt: DateTime.utc(2026, 1, 1, 0, i));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    queue = AppLogQueueLocalDataSource(sharedPreferences: await SharedPreferences.getInstance());
  });

  group('AppLogQueueLocalDataSource', () {
    test('should keep the lines in order', () async {
      await queue.add(entry(1));
      await queue.add(entry(2));

      expect((await queue.getAll()).map((line) => line.event), ['EVENT_1', 'EVENT_2']);
    });

    test('should drop the oldest lines when it is full', () async {
      for (var i = 0; i < AppLogQueueLocalDataSource.maxEntries + 5; i++) {
        await queue.add(entry(i % 60));
      }

      final lines = await queue.getAll();
      expect(lines, hasLength(AppLogQueueLocalDataSource.maxEntries));
      expect(lines.first.event, 'EVENT_5');
    });

    test('should remove the lines sent', () async {
      for (var i = 1; i <= 3; i++) {
        await queue.add(entry(i));
      }

      await queue.removeFirst(2);

      expect((await queue.getAll()).map((line) => line.event), ['EVENT_3']);
    });

    test('should drop a broken queue', () async {
      SharedPreferences.setMockInitialValues({AppLogQueueLocalDataSource.key: 'not json'});
      queue = AppLogQueueLocalDataSource(sharedPreferences: await SharedPreferences.getInstance());

      expect(await queue.getAll(), isEmpty);
    });
  });
}
