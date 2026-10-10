import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:photo_manager_app/core/services/sync_notification_service.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/sync_keep_alive.dart';

/// Keeps the sync alive on Android with:
/// - a data sync foreground service with the progress notification, so the OS does not freeze or kill the app
/// - a partial wake lock (MainActivity.kt), so the CPU does not sleep with the screen off. It has a timeout, in
///   case the app dies without releasing it, and is renewed while the sync runs.
///
/// The WorkManager isolate has no MainActivity, so the wake lock is not there: WorkManager already holds its own
/// while the task runs. On iOS it does nothing.
class AndroidSyncKeepAlive implements SyncKeepAlive {
  static const channelName = 'com.photomanagerpro.app/wake_lock';
  static const wakeLockTimeout = Duration(minutes: 10);
  static const wakeLockRenewal = Duration(minutes: 5);

  final SyncNotificationService notificationService;
  final MethodChannel channel;
  final bool isAndroid;
  final Duration renewal;
  Timer? _renewal;

  AndroidSyncKeepAlive(
    this.notificationService, {
    this.channel = const MethodChannel(channelName),
    bool? isAndroid,
    this.renewal = wakeLockRenewal,
  }) : isAndroid = isAndroid ?? Platform.isAndroid;

  @override
  Future<void> start() async {
    if (!isAndroid) return;

    await notificationService.showForegroundNotification();
    await _acquireWakeLock();
    _renewal?.cancel();
    _renewal = Timer.periodic(renewal, (_) => _acquireWakeLock());
  }

  @override
  Future<void> update({required int current, required int total}) async {
    if (!isAndroid) return;

    await notificationService.updateForegroundNotification(current: current, total: total);
  }

  @override
  Future<void> stop() async {
    if (!isAndroid) return;

    _renewal?.cancel();
    _renewal = null;
    await _invoke('release');
    await notificationService.hideForegroundNotification();
  }

  Future<void> _acquireWakeLock() => _invoke('acquire', {'timeoutMs': wakeLockTimeout.inMilliseconds});

  /// The sync goes on without the wake lock if the channel is not there (WorkManager isolate) or fails.
  Future<void> _invoke(String method, [Map<String, Object>? arguments]) async {
    try {
      await channel.invokeMethod<void>(method, arguments);
    } on MissingPluginException {
      // WorkManager isolate
    } on PlatformException {
      // The foreground service alone still keeps the app running
    }
  }
}
