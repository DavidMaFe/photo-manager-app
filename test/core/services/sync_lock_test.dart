import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/services/sync_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime(2026, 10, 4, 17, 30);

  Future<SyncLock> buildLock(Map<String, Object> values,
      {DateTime Function()? clock, Duration heartbeatInterval = SyncLock.defaultHeartbeatInterval}) async {
    SharedPreferences.setMockInitialValues(values);
    final sharedPreferences = await SharedPreferences.getInstance();
    final lock = SyncLock(sharedPreferences: sharedPreferences, clock: clock ?? () => now,
        heartbeatInterval: heartbeatInterval);
    addTearDown(lock.release);
    return lock;
  }

  /// Simulates the other isolate writing the values on disk: the in-memory
  /// cache of the [SharedPreferences] instance is not updated.
  void writeFromAnotherIsolate(Map<String, Object> values) {
    SharedPreferences.setMockInitialValues(values);
  }

  group('SyncLock', () {
    group('check', () {
      test('should be free when there is no lock', () async {
        // Arrange
        final lock = await buildLock({});

        // Act
        final result = await lock.check();

        // Assert
        expect(result.status, SyncLockStatus.free);
        expect(result.isHeld, isFalse);
      });

      test('should be held when the last sign of life is recent', () async {
        // Arrange
        final lock = await buildLock({
          SyncLock.lockKey: true,
          SyncLock.acquiredAtKey: now.subtract(const Duration(minutes: 4)).toIso8601String(),
        });

        // Act
        final result = await lock.check();

        // Assert
        expect(result.status, SyncLockStatus.held);
        expect(result.isHeld, isTrue);
        expect(result.age, const Duration(minutes: 4));
      });

      test('should be free when another isolate released the lock after it was cached', () async {
        // Arrange: the lock was held when the preferences were loaded in this isolate
        final lock = await buildLock({
          SyncLock.lockKey: true,
          SyncLock.acquiredAtKey: now.subtract(const Duration(minutes: 1)).toIso8601String(),
        });
        expect(lock.sharedPreferences.getBool(SyncLock.lockKey), isTrue);
        writeFromAnotherIsolate({SyncLock.lockKey: false});

        // Act
        final result = await lock.check();

        // Assert: the lock is read from disk, not from the stale cache
        expect(result.status, SyncLockStatus.free);
      });

      test('should be held when another isolate took the lock after it was cached', () async {
        // Arrange
        final lock = await buildLock({});
        writeFromAnotherIsolate({
          SyncLock.lockKey: true,
          SyncLock.acquiredAtKey: now.subtract(const Duration(minutes: 1)).toIso8601String(),
        });

        // Act
        final result = await lock.check();

        // Assert
        expect(result.status, SyncLockStatus.held);
      });

      test('should release the lock when there is no sign of life for the maximum duration', () async {
        // Arrange: the app was frozen or killed mid-sync, so the heartbeat stopped
        final lock = await buildLock({
          SyncLock.lockKey: true,
          SyncLock.acquiredAtKey: now.subtract(const Duration(minutes: 6)).toIso8601String(),
        });

        // Act
        final result = await lock.check();

        // Assert
        expect(result.status, SyncLockStatus.releasedStale);
        expect(result.age, const Duration(minutes: 6));
        expect(lock.sharedPreferences.getBool(SyncLock.lockKey), isFalse);
        expect(lock.sharedPreferences.getString(SyncLock.acquiredAtKey), isNull);
        expect((await lock.check()).status, SyncLockStatus.free);
      });

      test('should release the lock when it has no timestamp', () async {
        // Arrange
        final lock = await buildLock({SyncLock.lockKey: true});

        // Act
        final result = await lock.check();

        // Assert
        expect(result.status, SyncLockStatus.releasedStale);
        expect(result.age, isNull);
        expect(lock.sharedPreferences.getBool(SyncLock.lockKey), isFalse);
      });

      test('should release the lock when its timestamp is not valid', () async {
        // Arrange
        final lock = await buildLock({SyncLock.lockKey: true, SyncLock.acquiredAtKey: 'not-a-date'});

        // Act
        final result = await lock.check();

        // Assert
        expect(result.status, SyncLockStatus.releasedStale);
      });
    });

    group('acquire and release', () {
      test('should store the lock with the current time when acquired', () async {
        // Arrange
        final lock = await buildLock({});

        // Act
        await lock.acquire();

        // Assert
        expect(lock.sharedPreferences.getBool(SyncLock.lockKey), isTrue);
        expect(lock.sharedPreferences.getString(SyncLock.acquiredAtKey), now.toIso8601String());
        expect((await lock.check()).status, SyncLockStatus.held);
      });

      test('should clear the lock when released', () async {
        // Arrange
        final lock = await buildLock({});
        await lock.acquire();

        // Act
        await lock.release();

        // Assert
        expect(lock.sharedPreferences.getBool(SyncLock.lockKey), isFalse);
        expect(lock.sharedPreferences.getString(SyncLock.acquiredAtKey), isNull);
        expect((await lock.check()).status, SyncLockStatus.free);
      });
    });

    group('heartbeat', () {
      test('should renew the timestamp of the lock', () async {
        // Arrange
        var time = now;
        final lock = await buildLock({}, clock: () => time);
        await lock.acquire();
        time = now.add(const Duration(minutes: 40));

        // Act
        await lock.heartbeat();

        // Assert: a sync that is still alive keeps the lock however long it takes
        expect(lock.sharedPreferences.getString(SyncLock.acquiredAtKey), time.toIso8601String());
        final result = await lock.check();
        expect(result.status, SyncLockStatus.held);
        expect(result.age, Duration.zero);
      });

      test('should renew the lock periodically while it is held', () async {
        // Arrange
        var time = now;
        final lock = await buildLock({}, clock: () => time, heartbeatInterval: const Duration(milliseconds: 20));
        await lock.acquire();
        time = now.add(const Duration(minutes: 10));

        // Act
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(lock.sharedPreferences.getString(SyncLock.acquiredAtKey), time.toIso8601String());
        expect((await lock.check()).status, SyncLockStatus.held);
      });

      test('should stop renewing the lock when it is released', () async {
        // Arrange
        final lock = await buildLock({}, heartbeatInterval: const Duration(milliseconds: 20));
        await lock.acquire();

        // Act
        await lock.release();
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(lock.sharedPreferences.getString(SyncLock.acquiredAtKey), isNull);
        expect((await lock.check()).status, SyncLockStatus.free);
      });
    });
  });
}
