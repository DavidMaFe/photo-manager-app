import 'package:shared_preferences/shared_preferences.dart';

/// Result of checking the sync lock.
enum SyncLockStatus {
  /// No sync is running.
  free,

  /// A sync is running (the lock is recent).
  held,

  /// The lock was stale (older than [SyncLock.maxDuration], or without a valid
  /// timestamp) and has been released.
  releasedStale,
}

/// Outcome of [SyncLock.check], with the details needed to log it.
class SyncLockCheck {
  final SyncLockStatus status;

  /// How long the lock has been held, when it has a valid timestamp.
  final Duration? age;

  const SyncLockCheck(this.status, {this.age});

  bool get isHeld => status == SyncLockStatus.held;
}

/// Lock shared by the manual sync (UI isolate) and the background sync
/// (WorkManager isolate) so that only one of them runs at a time.
///
/// The lock lives in [SharedPreferences], whose values are cached per isolate:
/// a lock taken or released by the other isolate is not visible until the
/// cache is reloaded. [check] always reloads from disk before reading.
///
/// If the OS kills the WorkManager process mid-sync (e.g. during Doze mode at
/// 2 AM), the lock is never released. A lock older than [maxDuration] is
/// considered stale and is released by [check].
class SyncLock {
  static const String lockKey = 'SYNC_IN_PROGRESS';
  static const String acquiredAtKey = 'SYNC_LOCK_ACQUIRED_AT';
  static const Duration maxDuration = Duration(minutes: 30);

  final SharedPreferences sharedPreferences;
  final DateTime Function() _clock;

  SyncLock({required this.sharedPreferences, DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  /// Reloads the lock from disk and tells whether a sync is running,
  /// releasing the lock first if it is stale.
  Future<SyncLockCheck> check() async {
    await sharedPreferences.reload();

    final isLocked = sharedPreferences.getBool(lockKey) ?? false;
    if (!isLocked) return const SyncLockCheck(SyncLockStatus.free);

    final acquiredAt = DateTime.tryParse(sharedPreferences.getString(acquiredAtKey) ?? '');
    if (acquiredAt == null) {
      // Lock without a valid timestamp (legacy or corrupted): treat it as stale.
      await release();
      return const SyncLockCheck(SyncLockStatus.releasedStale);
    }

    final age = _clock().difference(acquiredAt);
    if (age > maxDuration) {
      await release();
      return SyncLockCheck(SyncLockStatus.releasedStale, age: age);
    }

    return SyncLockCheck(SyncLockStatus.held, age: age);
  }

  Future<void> acquire() async {
    await sharedPreferences.setBool(lockKey, true);
    await sharedPreferences.setString(acquiredAtKey, _clock().toIso8601String());
  }

  Future<void> release() async {
    await sharedPreferences.setBool(lockKey, false);
    await sharedPreferences.remove(acquiredAtKey);
  }
}
