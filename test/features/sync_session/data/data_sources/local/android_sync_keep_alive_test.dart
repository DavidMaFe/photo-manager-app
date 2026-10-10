import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/services/sync_notification_service.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/android_sync_keep_alive.dart';

class MockSyncNotificationService extends Mock implements SyncNotificationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(AndroidSyncKeepAlive.channelName);
  late MockSyncNotificationService notifications;
  late List<MethodCall> calls;

  setUp(() {
    notifications = MockSyncNotificationService();
    when(() => notifications.showForegroundNotification()).thenAnswer((_) async {});
    when(() => notifications.updateForegroundNotification(current: any(named: 'current'), total: any(named: 'total')))
        .thenAnswer((_) async {});
    when(() => notifications.hideForegroundNotification()).thenAnswer((_) async {});

    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  AndroidSyncKeepAlive build({bool isAndroid = true, Duration renewal = AndroidSyncKeepAlive.wakeLockRenewal}) {
    final keepAlive = AndroidSyncKeepAlive(notifications, isAndroid: isAndroid, renewal: renewal);
    addTearDown(keepAlive.stop);
    return keepAlive;
  }

  group('AndroidSyncKeepAlive', () {
    group('start', () {
      // ==================== HAPPY PATH TESTS ====================

      test('should start the foreground service and take the wake lock with a timeout', () async {
        // Arrange
        final keepAlive = build();

        // Act
        await keepAlive.start();

        // Assert
        verify(() => notifications.showForegroundNotification()).called(1);
        expect(calls.single.method, 'acquire');
        expect(calls.single.arguments, {'timeoutMs': AndroidSyncKeepAlive.wakeLockTimeout.inMilliseconds});
      });

      test('should renew the wake lock while the sync runs', () async {
        // Arrange
        final keepAlive = build(renewal: const Duration(milliseconds: 20));

        // Act
        await keepAlive.start();
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(calls.where((call) => call.method == 'acquire').length, greaterThan(2));
      });

      // ==================== EDGE CASE TESTS ====================

      test('should keep the sync going when the wake lock channel is not there', () async {
        // Arrange: the WorkManager isolate has no MainActivity
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
        final keepAlive = build();

        // Act & Assert
        await keepAlive.start();
        verify(() => notifications.showForegroundNotification()).called(1);
      });

      test('should keep the sync going when the wake lock fails', () async {
        // Arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel,
            (call) async => throw PlatformException(code: 'error'));
        final keepAlive = build();

        // Act & Assert
        await keepAlive.start();
        await keepAlive.stop();
        verify(() => notifications.hideForegroundNotification()).called(1);
      });

      test('should do nothing outside Android', () async {
        // Arrange
        final keepAlive = build(isAndroid: false);

        // Act
        await keepAlive.start();
        await keepAlive.update(current: 1, total: 2);
        await keepAlive.stop();

        // Assert
        verifyZeroInteractions(notifications);
        expect(calls, isEmpty);
      });
    });

    group('update', () {
      test('should show the progress in the notification', () async {
        // Arrange
        final keepAlive = build();

        // Act
        await keepAlive.update(current: 3, total: 22);

        // Assert
        verify(() => notifications.updateForegroundNotification(current: 3, total: 22)).called(1);
      });
    });

    group('stop', () {
      test('should release the wake lock and stop the foreground service', () async {
        // Arrange
        final keepAlive = build();
        await keepAlive.start();
        calls.clear();

        // Act
        await keepAlive.stop();

        // Assert
        expect(calls.single.method, 'release');
        verify(() => notifications.hideForegroundNotification()).called(1);
      });

      test('should stop renewing the wake lock', () async {
        // Arrange
        final keepAlive = build(renewal: const Duration(milliseconds: 20));
        await keepAlive.start();

        // Act
        await keepAlive.stop();
        calls.clear();
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(calls, isEmpty);
      });
    });
  });
}
