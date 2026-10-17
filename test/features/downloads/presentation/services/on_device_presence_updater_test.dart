import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/downloads/domain/services/on_device_presence.dart';
import 'package:photo_manager_app/features/downloads/presentation/services/on_device_presence_updater.dart';

class MockOnDevicePresence extends Mock implements OnDevicePresence {}

void main() {
  late MockOnDevicePresence presence;
  late AppEventBus eventBus;
  late OnDevicePresenceUpdater updater;

  setUp(() {
    presence = MockOnDevicePresence();
    eventBus = AppEventBus();
    updater = OnDevicePresenceUpdater(presence, eventBus);
    when(() => presence.refresh()).thenAnswer((_) async {});
  });

  tearDown(() => updater.stop());

  group('OnDevicePresenceUpdater', () {
    test('should compute it when it starts', () async {
      updater.start();

      verify(() => presence.refresh()).called(1);
    });

    test('should compute it again after a sync and when files change', () async {
      updater.start();
      eventBus.fire(SyncCompletedEvent(syncSessionId: '1', newFilesCount: 3, completedAt: DateTime(2026)));
      eventBus.fire(const FileUpdatedEvent(affectedFileIds: ['1'], updateType: FileUpdateType.deleted));
      await Future<void>.delayed(Duration.zero);

      verify(() => presence.refresh()).called(3);
    });

    test('should listen only once when started twice', () async {
      updater.start();
      updater.start();
      eventBus.fire(const FileUpdatedEvent(affectedFileIds: ['1'], updateType: FileUpdateType.updated));
      await Future<void>.delayed(Duration.zero);

      verify(() => presence.refresh()).called(3);
    });

    test('should stop listening', () async {
      updater.start();
      await updater.stop();
      eventBus.fire(const FileUpdatedEvent(affectedFileIds: ['1'], updateType: FileUpdateType.updated));
      await Future<void>.delayed(Duration.zero);

      verify(() => presence.refresh()).called(1);
    });

    test('should not fail when computing it fails', () async {
      when(() => presence.refresh()).thenThrow(Exception('offline'));

      await updater.refresh();
    });
  });
}
