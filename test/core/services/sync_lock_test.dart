import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/services/sync_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime(2026, 10, 4, 17, 30);

  Future<SyncLock> buildLock(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final sharedPreferences = await SharedPreferences.getInstance();
    return SyncLock(sharedPreferences: sharedPreferences, clock: () => now);
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

      test('should be held when the lock is recent', () async {
        // Arrange
        final lock = await buildLock({
          SyncLock.lockKey: true,
          SyncLock.acquiredAtKey: now.subtract(const Duration(minutes: 5)).toIso8601String(),
        });

        // Act
        final result = await lock.check();

        // Assert
        expect(result.status, SyncLockStatus.held);
        expect(result.isHeld, isTrue);
        expect(result.age, const Duration(minutes: 5));
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

      test('should release the lock when it is older than the maximum duration', () async {
        // Arrange
        final lock = await buildLock({
          SyncLock.lockKey: true,
          SyncLock.acquiredAtKey: now.subtract(const Duration(minutes: 31)).toIso8601String(),
        });

        // Act
        final result = await lock.check();

        // Assert
        expect(result.status, SyncLockStatus.releasedStale);
        expect(result.age, const Duration(minutes: 31));
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
  });
}
