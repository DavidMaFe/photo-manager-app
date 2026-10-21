import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/monitoring/data/app_log_entry_model.dart';
import 'package:photo_manager_app/core/monitoring/data/device_context.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_log_entry.dart';

void main() {
  final entry = AppLogEntryModel(
    level: AppLogLevel.error,
    event: 'UNCAUGHT_ERROR',
    occurredAt: DateTime.utc(2026, 10, 21, 16),
    message: 'Bad state',
    errorType: 'StateError',
    stackTrace: '#0 main',
    screen: 'gallery',
    requestId: 'req-12345678',
  );
  const device = DeviceContext(
      appVersion: '1.4.0', build: '11', platform: 'android', osVersion: '16', deviceModel: 'SM-S911B');

  group('AppLogEntryModel', () {
    test('should survive the queue: to JSON and back', () {
      expect(AppLogEntryModel.fromJson(entry.toJson()), entry);
    });

    test('should leave out the empty fields', () {
      final minimal = AppLogEntryModel(level: AppLogLevel.info, event: 'SYNC_FAILED', occurredAt: DateTime.utc(2026));

      expect(minimal.toJson().keys, ['level', 'event', 'occurredAt']);
    });

    test('should build the request of the backend, with the device and the level in capitals', () {
      expect(entry.toRequestJson(device), {
        'level': 'ERROR',
        'event': 'UNCAUGHT_ERROR',
        'occurredAt': '2026-10-21T16:00:00.000Z',
        'message': 'Bad state',
        'errorType': 'StateError',
        'stackTrace': '#0 main',
        'screen': 'gallery',
        'requestId': 'req-12345678',
        'appVersion': '1.4.0',
        'build': '11',
        'platform': 'android',
        'osVersion': '16',
        'deviceModel': 'SM-S911B',
      });
    });
  });
}
