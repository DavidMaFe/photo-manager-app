import 'dart:developer' as developer;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for managing background sync notifications
///
/// This service handles all notification-related operations for background sync:
/// - Creating notification channels
/// - Showing success/failure notifications based on user preferences
/// - Managing foreground service notifications (Android 12+)
/// - Handling notification tap actions
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

  /// Initialize notification service and create channels
  Future<void> initialize() async {
    developer.log('🔔 Initializing notification service', name: 'SyncNotificationService');

    // Android-specific initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS-specific initialization
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

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    // Success channel
    const successChannel = AndroidNotificationChannel(
      _channelIdSuccess,
      'Sync Success',
      description: 'Notifications for successful sync operations',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    // Failure channel
    const failureChannel = AndroidNotificationChannel(
      _channelIdFailure,
      'Sync Failures',
      description: 'Notifications for failed sync operations',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Progress channel (for foreground service)
    const progressChannel = AndroidNotificationChannel(
      _channelIdProgress,
      'Sync Progress',
      description: 'Shows sync progress for foreground service',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(successChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(failureChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(progressChannel);

    developer.log('✅ Notification channels created', name: 'SyncNotificationService');
  }

  /// Show foreground service notification (required for Android 12+)
  Future<void> showForegroundNotification() async {
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

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        _notificationIdProgress,
        'Syncing photos',
        'Background sync in progress...',
        notificationDetails,
      );

      developer.log('📱 Foreground notification shown', name: 'SyncNotificationService');
    } catch (e) {
      developer.log(
        '❌ Failed to show foreground notification',
        name: 'SyncNotificationService',
        error: e,
      );
    }
  }

  /// Update foreground notification with progress
  Future<void> updateForegroundNotification({
    required int current,
    required int total,
  }) async {
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

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        _notificationIdProgress,
        'Syncing photos',
        'Uploading $current of $total files...',
        notificationDetails,
      );
    } catch (e) {
      developer.log(
        '❌ Failed to update foreground notification',
        name: 'SyncNotificationService',
        error: e,
      );
    }
  }

  /// Hide foreground notification
  Future<void> hideForegroundNotification() async {
    try {
      await _notificationsPlugin.cancel(_notificationIdProgress);
      developer.log('🔕 Foreground notification hidden', name: 'SyncNotificationService');
    } catch (e) {
      developer.log(
        '❌ Failed to hide foreground notification',
        name: 'SyncNotificationService',
        error: e,
      );
    }
  }

  /// Show sync success notification
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

      final title = 'Sync completed';
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

  /// Show sync failure notification
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

  /// Request notification permissions (iOS)
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

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    developer.log(
      '👆 Notification tapped: ${response.payload}',
      name: 'SyncNotificationService',
    );

    // TODO: Navigate to sync history page
    // This will be implemented when we add navigation support
    // For now, just log the tap
  }

  /// Cancel all notifications
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
