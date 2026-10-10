import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Result of checking the sync lock.
enum SyncLockStatus {
  /// No sync is running.
  free,

  /// A sync is running (the lock is recent).
  held,

  /// The lock was stale (no sign of life for [SyncLock.maxDuration], or without
  /// a valid timestamp) and has been released.
  releasedStale,
}

/// Outcome of [SyncLock.check], with the details needed to log it.
class SyncLockCheck {
  final SyncLockStatus status;

  /// Time since the last sign of life of the sync, when it has a valid timestamp.
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
/// While the sync runs, the isolate that holds the lock renews its timestamp
/// every [heartbeatInterval], so a long sync keeps it however long it takes.
/// If the OS freezes or kills the process mid-sync (e.g. the phone sleeps), the
/// lock is never released and the heartbeat stops: a lock without a sign of
/// life for [maxDuration] is considered stale and is released by [check].
class SyncLock {
  static const String lockKey = 'SYNC_IN_PROGRESS';
  static const String acquiredAtKey = 'SYNC_LOCK_ACQUIRED_AT';
  static const Duration maxDuration = Duration(minutes: 5);
  static const Duration defaultHeartbeatInterval = Duration(minutes: 1);

  final SharedPreferences sharedPreferences;
  final DateTime Function() _clock;
  final Duration heartbeatInterval;
  Timer? _heartbeat;

  SyncLock({
    required this.sharedPreferences,
    DateTime Function()? clock,
    this.heartbeatInterval = defaultHeartbeatInterval,
  }) : _clock = clock ?? DateTime.now;

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

  /// Takes the lock and keeps renewing it until [release].
  Future<void> acquire() async {
    await sharedPreferences.setBool(lockKey, true);
    await heartbeat();
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(heartbeatInterval, (_) => heartbeat());
  }

  /// Renews the timestamp of the lock: the sync is still alive.
  Future<void> heartbeat() async {
    await sharedPreferences.setString(acquiredAtKey, _clock().toIso8601String());
  }

  Future<void> release() async {
    _heartbeat?.cancel();
    _heartbeat = null;
    await sharedPreferences.setBool(lockKey, false);
    await sharedPreferences.remove(acquiredAtKey);
  }
}
