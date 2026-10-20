import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:photo_manager_app/core/utils/app_locale.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Service for managing background sync notifications
///
/// This service handles all notification-related operations for background sync:
/// - Creating notification channels
/// - Showing success/failure notifications based on user preferences
/// - Managing foreground service notifications (Android 12+)
/// - Handling notification tap actions
///
/// Texts in the language of the device ([AppLocale]), also in the WorkManager isolate.
///
/// IMPORTANT: There are two initialization paths:
/// - [initialize]: full init called from main.dart (foreground app)
/// - [initializeForBackground]: lightweight init called from the WorkManager
///   background isolate before using any notification methods
class SyncNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  // Notification channels
  static const String _channelIdSuccess = 'sync_success';
  static const String _channelIdFailure = 'sync_failure';
  static const String _channelIdProgress = 'sync_progress';

  // Notification IDs
  static const int _notificationIdProgress = 1;
  static const int _notificationIdSuccess = 2;
  static const int _notificationIdFailure = 3;

  /// Texts of the notifications; read on every notification, so a change of the device language applies at once.
  final AppLocalizations Function() _strings;

  SyncNotificationService(this._notificationsPlugin, {AppLocalizations Function()? strings})
      : _strings = strings ?? AppLocale.strings;

  /// Full initialization — called from main.dart (foreground context).
  ///
  /// Sets up the plugin, registers tap callbacks, and creates channels.
  Future<void> initialize() async {
    developer.log('🔔 Initializing notification service', name: 'SyncNotificationService');

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannels();

    developer.log('✅ Notification service initialized', name: 'SyncNotificationService');
  }

  /// Lightweight initialization for the WorkManager background isolate.
  ///
  /// In the background isolate a fresh FlutterEngine is spun up, so the plugin
  /// must be re-initialized before any notification methods are called.
  /// No tap callback is registered here because there is no UI to navigate to.
  Future<void> initializeForBackground() async {
    developer.log(
      '🔔 Initializing notification service (background)',
      name: 'SyncNotificationService',
    );

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);

    await _createNotificationChannels();

    developer.log(
      '✅ Notification service initialized (background)',
      name: 'SyncNotificationService',
    );
  }

  /// Create notification channels for Android.
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    final l10n = _strings();

    // Creating a channel again updates its name and description (the language of the device may have changed)
    final successChannel = AndroidNotificationChannel(
      _channelIdSuccess,
      l10n.notificationChannelFinishedName,
      description: l10n.notificationChannelFinishedDescription,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    final failureChannel = AndroidNotificationChannel(
      _channelIdFailure,
      l10n.notificationChannelFailureName,
      description: l10n.notificationChannelFailureDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final progressChannel = AndroidNotificationChannel(
      _channelIdProgress,
      l10n.notificationChannelProgressName,
      description: l10n.notificationChannelProgressDescription,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(successChannel);
    await androidPlugin?.createNotificationChannel(failureChannel);
    await androidPlugin?.createNotificationChannel(progressChannel);

    developer.log('✅ Notification channels created', name: 'SyncNotificationService');
  }

  /// Start an Android foreground service with an indeterminate progress notification.
  ///
  /// This is the correct approach for background sync on Android 12+.
  /// Using [startForegroundService] keeps the process alive while syncing,
  /// preventing the OS from killing the task mid-upload.
  ///
  /// On iOS or non-Android platforms this is a no-op.
  Future<void> showForegroundNotification() async {
    if (!Platform.isAndroid) return;

    try {
      final l10n = _strings();
      final androidDetails = AndroidNotificationDetails(
        _channelIdProgress,
        l10n.notificationChannelProgressName,
        channelDescription: l10n.notificationChannelProgressDescription,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showProgress: true,
        indeterminate: true,
        icon: '@mipmap/ic_launcher',
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.startForegroundService(
            _notificationIdProgress,
            l10n.notificationBackupRunningTitle,
            l10n.notificationBackupPreparing,
            notificationDetails: androidDetails,
            foregroundServiceTypes: {
              AndroidServiceForegroundType.foregroundServiceTypeDataSync,
            },
          );

      developer.log('📱 Foreground service started', name: 'SyncNotificationService');
    } catch (e) {
      developer.log(
        '❌ Failed to start foreground service',
        name: 'SyncNotificationService',
        error: e,
      );
    }
  }

  /// Update the foreground service notification with deterministic progress.
  Future<void> updateForegroundNotification({
    required int current,
    required int total,
  }) async {
    if (!Platform.isAndroid) return;

    try {
      final l10n = _strings();
      final androidDetails = AndroidNotificationDetails(
        _channelIdProgress,
        l10n.notificationChannelProgressName,
        channelDescription: l10n.notificationChannelProgressDescription,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showProgress: true,
        maxProgress: total,
        progress: current,
        icon: '@mipmap/ic_launcher',
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.startForegroundService(
            _notificationIdProgress,
            l10n.notificationBackupRunningTitle,
            l10n.notificationBackupProgress(current, total),
            notificationDetails: androidDetails,
            foregroundServiceTypes: {
              AndroidServiceForegroundType.foregroundServiceTypeDataSync,
            },
          );
    } catch (e) {
      developer.log(
        '❌ Failed to update foreground notification',
        name: 'SyncNotificationService',
        error: e,
      );
    }
  }

  /// Stop the foreground service and remove the progress notification.
  Future<void> hideForegroundNotification() async {
    if (!Platform.isAndroid) return;

    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.stopForegroundService();

      developer.log('🔕 Foreground service stopped', name: 'SyncNotificationService');
    } catch (e) {
      developer.log(
        '❌ Failed to stop foreground service',
        name: 'SyncNotificationService',
        error: e,
      );
    }
  }

  /// Foreground notification of a download to the gallery It shares
  /// the id of the sync progress: a download and a sync never run at the same time (SyncLock).
  Future<void> showDownloadProgress({required int saved, required int total}) async {
    if (!Platform.isAndroid) return;

    try {
      final l10n = _strings();
      final androidDetails = AndroidNotificationDetails(
        _channelIdProgress,
        l10n.notificationChannelProgressName,
        channelDescription: l10n.notificationChannelProgressDescription,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showProgress: true,
        maxProgress: total,
        progress: saved,
        icon: '@mipmap/ic_launcher',
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.startForegroundService(
            _notificationIdProgress,
            l10n.notificationDownloadRunningTitle,
            l10n.notificationDownloadProgress(saved, total),
            notificationDetails: androidDetails,
            foregroundServiceTypes: {
              AndroidServiceForegroundType.foregroundServiceTypeDataSync,
            },
          );
    } catch (e) {
      developer.log('❌ Failed to show download progress', name: 'SyncNotificationService', error: e);
    }
  }

  /// Notification at the end of a download to the gallery.
  Future<void> showDownloadFinished({required int saved, required int failed}) async {
    try {
      final l10n = _strings();
      final androidDetails = AndroidNotificationDetails(
        _channelIdSuccess,
        l10n.notificationChannelFinishedName,
        channelDescription: l10n.notificationChannelFinishedDescription,
        importance: Importance.low,
        priority: Priority.low,
        icon: '@mipmap/ic_launcher',
      );
      final notificationDetails = NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails());

      final body = l10n.notificationDownloadDoneBody(saved);
      await _notificationsPlugin.show(
        _notificationIdSuccess,
        l10n.notificationDownloadDoneTitle,
        failed == 0 ? body : '$body · ${l10n.notificationDownloadFailedSuffix(failed)}',
        notificationDetails,
      );
    } catch (e) {
      developer.log('❌ Failed to show download finished', name: 'SyncNotificationService', error: e);
    }
  }

  /// Show a sync success notification.
  Future<void> showSyncSuccessNotification({
    required int filesUploaded,
  }) async {
    try {
      final l10n = _strings();
      final androidDetails = AndroidNotificationDetails(
        _channelIdSuccess,
        l10n.notificationChannelFinishedName,
        channelDescription: l10n.notificationChannelFinishedDescription,
        importance: Importance.low,
        priority: Priority.low,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails();

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        _notificationIdSuccess,
        l10n.notificationBackupDoneTitle,
        l10n.notificationBackupDoneBody(filesUploaded),
        notificationDetails,
        payload: 'sync_history',
      );

      developer.log(
        '✅ Success notification shown: $filesUploaded files',
        name: 'SyncNotificationService',
      );
    } catch (e) {
      developer.log(
        '❌ Failed to show success notification',
        name: 'SyncNotificationService',
        error: e,
      );
    }
  }

  /// Show a sync failure notification. The technical error stays in the log ([SyncLogService]); the notification
  /// only says what the user can do.
  Future<void> showSyncFailureNotification({
    required bool sessionExpired,
    bool planLimit = false,
  }) async {
    try {
      final l10n = _strings();
      final androidDetails = AndroidNotificationDetails(
        _channelIdFailure,
        l10n.notificationChannelFailureName,
        channelDescription: l10n.notificationChannelFailureDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails();

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        _notificationIdFailure,
        l10n.notificationBackupFailedTitle,
        sessionExpired
            ? l10n.notificationBackupSessionExpired
            : planLimit
                ? l10n.notificationBackupPlanLimit
                : l10n.notificationBackupFailedBody,
        notificationDetails,
        payload: 'sync_history',
      );

      developer.log(
        '⚠️ Failure notification shown (sessionExpired=$sessionExpired)',
        name: 'SyncNotificationService',
      );
    } catch (e) {
      developer.log(
        '❌ Failed to show failure notification',
        name: 'SyncNotificationService',
        error: e,
      );
    }
  }

  /// Request notification permissions (iOS).
  Future<bool> requestPermissions() async {
    try {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      developer.log(
        '🔔 Notification permissions: ${result ?? true}',
        name: 'SyncNotificationService',
      );

      return result ?? true;
    } catch (e) {
      developer.log(
        '❌ Failed to request notification permissions',
        name: 'SyncNotificationService',
        error: e,
      );
      return false;
    }
  }

  /// Handle notification tap.
  void _onNotificationTapped(NotificationResponse response) {
    developer.log(
      '👆 Notification tapped: ${response.payload}',
      name: 'SyncNotificationService',
    );

    // TODO: Navigate to sync history page
    // This will be implemented when we add navigation support
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
      developer.log('🔕 All notifications cancelled', name: 'SyncNotificationService');
    } catch (e) {
      developer.log(
        '❌ Failed to cancel notifications',
        name: 'SyncNotificationService',
        error: e,
      );
    }
  }
}
