import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for managing background sync notifications
///
/// This service handles all notification-related operations for background sync:
/// - Creating notification channels
/// - Showing success/failure notifications based on user preferences
/// - Managing foreground service notifications (Android 12+)
/// - Handling notification tap actions
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

  SyncNotificationService(this._notificationsPlugin);

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

    const successChannel = AndroidNotificationChannel(
      _channelIdSuccess,
      'Sync Success',
      description: 'Notifications for successful sync operations',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    const failureChannel = AndroidNotificationChannel(
      _channelIdFailure,
      'Sync Failures',
      description: 'Notifications for failed sync operations',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const progressChannel = AndroidNotificationChannel(
      _channelIdProgress,
      'Sync Progress',
      description: 'Shows sync progress for foreground service',
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
      const androidDetails = AndroidNotificationDetails(
        _channelIdProgress,
        'Sync Progress',
        channelDescription: 'Shows sync progress for foreground service',
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
            'Syncing photos',
            'Background sync in progress...',
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
      final androidDetails = AndroidNotificationDetails(
        _channelIdProgress,
        'Sync Progress',
        channelDescription: 'Shows sync progress for foreground service',
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
            'Syncing photos',
            'Uploading $current of $total files...',
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

  /// Show a sync success notification.
  Future<void> showSyncSuccessNotification({
    required int filesUploaded,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelIdSuccess,
        'Sync Success',
        channelDescription: 'Notifications for successful sync operations',
        importance: Importance.low,
        priority: Priority.low,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      const title = 'Sync completed';
      final body = filesUploaded == 0
          ? 'All files already synced'
          : filesUploaded == 1
              ? '1 file uploaded successfully'
              : '$filesUploaded files uploaded successfully';

      await _notificationsPlugin.show(
        _notificationIdSuccess,
        title,
        body,
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

  /// Show a sync failure notification.
  Future<void> showSyncFailureNotification({
    required String errorMessage,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelIdFailure,
        'Sync Failures',
        channelDescription: 'Notifications for failed sync operations',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails();

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        _notificationIdFailure,
        'Sync failed',
        errorMessage,
        notificationDetails,
        payload: 'sync_history',
      );

      developer.log(
        '⚠️ Failure notification shown: $errorMessage',
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
