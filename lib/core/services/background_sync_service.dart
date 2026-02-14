import 'dart:async';
import 'dart:developer' as developer;

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:photo_manager_app/core/services/sync_notification_service.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/media_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/check_duplicated_files_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/complete_sync_session_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/start_sync_session_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/upload_file_use_case.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Result of a background sync operation
class _SyncResult {
  final bool success;
  final int filesUploaded;
  final String? errorMessage;

  _SyncResult({
    required this.success,
    this.filesUploaded = 0,
    this.errorMessage,
  });

  factory _SyncResult.success(int filesUploaded) {
    return _SyncResult(success: true, filesUploaded: filesUploaded);
  }

  factory _SyncResult.failure(String errorMessage) {
    return _SyncResult(success: false, errorMessage: errorMessage);
  }
}

/// Service for executing background synchronization
///
/// This service handles the complete background sync flow including:
/// - Checking device auto-sync status
/// - Loading sync configuration
/// - Validating network and battery conditions
/// - Preventing concurrent syncs
/// - Executing the sync process
/// - Error handling and logging
class BackgroundSyncService {
  final SyncDeviceRepository syncDeviceRepository;
  final SyncConfigRepository syncConfigRepository;
  final SyncSessionRepository syncSessionRepository;
  final StartSyncSessionUseCase startSyncSessionUseCase;
  final CheckDuplicatedFilesUseCase checkDuplicatesUseCase;
  final UploadFileUseCase uploadFileUseCase;
  final CompleteSyncSessionUseCase completeSyncSessionUseCase;
  final MediaLocalDataSource mediaLocalDataSource;
  final AuthRepository authRepository;
  final SharedPreferences sharedPreferences;
  final SyncNotificationService notificationService;

  static const String _syncLockKey = 'SYNC_IN_PROGRESS';
  static const String _lastSyncAttemptKey = 'LAST_SYNC_ATTEMPT';

  BackgroundSyncService({
    required this.syncDeviceRepository,
    required this.syncConfigRepository,
    required this.syncSessionRepository,
    required this.startSyncSessionUseCase,
    required this.checkDuplicatesUseCase,
    required this.uploadFileUseCase,
    required this.completeSyncSessionUseCase,
    required this.mediaLocalDataSource,
    required this.authRepository,
    required this.sharedPreferences,
    required this.notificationService,
  });

  /// Execute background sync
  ///
  /// Returns true if sync completed successfully, false otherwise
  Future<bool> execute() async {
    developer.log('🔄 Background sync triggered', name: 'BackgroundSyncService');

    try {
      // 1. Check if sync is already in progress
      if (_isSyncInProgress()) {
        developer.log('⚠️ Sync already in progress, skipping', name: 'BackgroundSyncService');
        return false;
      }

      // 2. Check authentication
      if (!await _isAuthenticated()) {
        developer.log('❌ Not authenticated, cancelling sync', name: 'BackgroundSyncService');
        return false;
      }

      // 3. Load sync configuration
      final syncConfig = await syncConfigRepository.getSyncConfig();
      if (syncConfig == null || !syncConfig.autoSyncEnabled) {
        developer.log('⚠️ Auto-sync disabled, skipping', name: 'BackgroundSyncService');
        return false;
      }

      developer.log('✅ Sync config loaded: ${syncConfig.syncFrequency.name}', name: 'BackgroundSyncService');

      // 4. Validate network conditions
      if (!await _validateNetworkConditions(syncConfig)) {
        developer.log('❌ Network conditions not met', name: 'BackgroundSyncService');
        return false;
      }

      // 5. Validate battery conditions
      if (!await _validateBatteryConditions(syncConfig)) {
        developer.log('❌ Battery conditions not met', name: 'BackgroundSyncService');
        return false;
      }

      // 6. Acquire sync lock
      _acquireSyncLock();

      try {
        // 7. Show foreground notification (required for Android 12+)
        await notificationService.showForegroundNotification();

        // 8. Execute sync
        final result = await _performSync(syncConfig);

        // 9. Hide foreground notification
        await notificationService.hideForegroundNotification();

        if (result.success) {
          developer.log('✅ Background sync completed successfully', name: 'BackgroundSyncService');
          _recordSuccessfulSync();

          // Show success notification if enabled
          if (syncConfig.notifyOnSuccess) {
            await notificationService.showSyncSuccessNotification(
              filesUploaded: result.filesUploaded,
            );
          }
        } else {
          developer.log('⚠️ Background sync completed with issues', name: 'BackgroundSyncService');

          // Show failure notification if enabled
          if (syncConfig.notifyOnFailure) {
            await notificationService.showSyncFailureNotification(
              errorMessage: result.errorMessage ?? 'Unknown error occurred',
            );
          }
        }

        return result.success;
      } finally {
        // 10. Release sync lock and hide notification
        _releaseSyncLock();
        await notificationService.hideForegroundNotification();
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ Background sync failed',
        name: 'BackgroundSyncService',
        error: e,
        stackTrace: stackTrace,
      );
      _releaseSyncLock();
      _recordFailedSync();
      return false;
    }
  }

  /// Check if sync is already in progress
  bool _isSyncInProgress() {
    return sharedPreferences.getBool(_syncLockKey) ?? false;
  }

  /// Acquire sync lock to prevent concurrent syncs
  void _acquireSyncLock() {
    sharedPreferences.setBool(_syncLockKey, true);
    developer.log('🔒 Sync lock acquired', name: 'BackgroundSyncService');
  }

  /// Release sync lock
  void _releaseSyncLock() {
    sharedPreferences.setBool(_syncLockKey, false);
    developer.log('🔓 Sync lock released', name: 'BackgroundSyncService');
  }

  /// Check if user is authenticated
  Future<bool> _isAuthenticated() async {
    try {
      final user = await authRepository.getCurrentUser();
      return user != null;
    } catch (e) {
      developer.log('❌ Authentication check failed', name: 'BackgroundSyncService', error: e);
      return false;
    }
  }

  /// Validate network conditions based on sync config
  Future<bool> _validateNetworkConditions(SyncConfig config) async {
    try {
      final connectivity = Connectivity();
      final connectivityResults = await connectivity.checkConnectivity();

      // Check if we have any connection
      if (connectivityResults.isEmpty ||
          connectivityResults.contains(ConnectivityResult.none)) {
        developer.log('❌ No network connection', name: 'BackgroundSyncService');
        return false;
      }

      // If WiFi-only is required, check for WiFi
      if (config.requiresWifiOnly) {
        final hasWifi = connectivityResults.contains(ConnectivityResult.wifi);
        if (!hasWifi) {
          developer.log('❌ WiFi required but not connected', name: 'BackgroundSyncService');
          return false;
        }
      }

      developer.log('✅ Network conditions met', name: 'BackgroundSyncService');
      return true;
    } catch (e) {
      developer.log('❌ Network validation failed', name: 'BackgroundSyncService', error: e);
      return false;
    }
  }

  /// Validate battery conditions based on sync config
  Future<bool> _validateBatteryConditions(SyncConfig config) async {
    try {
      // If any battery level is acceptable, skip validation
      if (!config.requiresBatteryCondition) {
        developer.log('✅ Battery conditions not required', name: 'BackgroundSyncService');
        return true;
      }

      // Check battery conditions: device must be charging OR battery > 15%
      final battery = Battery();

      // Check if device is charging
      final batteryState = await battery.batteryState;
      final isCharging = batteryState == BatteryState.charging ||
                         batteryState == BatteryState.full;

      if (isCharging) {
        developer.log('✅ Device is charging', name: 'BackgroundSyncService');
        return true;
      }

      // Check battery level
      final batteryLevel = await battery.batteryLevel;
      if (batteryLevel > 15) {
        developer.log(
          '✅ Battery level OK: $batteryLevel%',
          name: 'BackgroundSyncService',
        );
        return true;
      }

      developer.log(
        '❌ Battery conditions not met: level=$batteryLevel%, charging=false',
        name: 'BackgroundSyncService',
      );
      return false;
    } catch (e) {
      developer.log('❌ Battery validation failed', name: 'BackgroundSyncService', error: e);
      // In case of error checking battery, allow sync to proceed
      // Better to sync than to miss a scheduled sync due to battery check failure
      return true;
    }
  }

  /// Perform the actual sync operation
  Future<_SyncResult> _performSync(SyncConfig config) async {
    String? sessionId;

    try {
      // 1. Get device UUID
      final deviceUuid = await syncDeviceRepository.getDeviceUuid();
      developer.log('📱 Device UUID: $deviceUuid', name: 'BackgroundSyncService');

      // 2. Start sync session
      developer.log('🚀 Starting sync session...', name: 'BackgroundSyncService');
      final session = await startSyncSessionUseCase(deviceUuid: deviceUuid);
      sessionId = session.id;
      developer.log('✅ Sync session started: $sessionId', name: 'BackgroundSyncService');

      // 3. Get media files
      developer.log('📂 Fetching media files...', name: 'BackgroundSyncService');
      final mediaFiles = await mediaLocalDataSource.scanMediaFiles();
      developer.log('📊 Found ${mediaFiles.length} media files', name: 'BackgroundSyncService');

      if (mediaFiles.isEmpty) {
        developer.log('⚠️ No files to sync', name: 'BackgroundSyncService');
        await completeSyncSessionUseCase(sessionId: sessionId);
        return _SyncResult.success(0);
      }

      // 4. Check for duplicates
      developer.log('🔍 Checking for duplicates...', name: 'BackgroundSyncService');
      final hashes = mediaFiles.map((file) => file.hash).toList();
      final duplicateResult = await checkDuplicatesUseCase(
        sessionId: sessionId,
        fileHashes: hashes,
      );

      final hashesToUpload = duplicateResult.filesToUpload.toSet();
      final filesToUpload = mediaFiles
          .where((file) => hashesToUpload.contains(file.hash))
          .toList();

      developer.log(
        '📊 Files to upload: ${filesToUpload.length} (${duplicateResult.duplicatesCount} duplicates)',
        name: 'BackgroundSyncService',
      );

      // 5. Upload files
      int uploadedCount = 0;
      for (final file in filesToUpload) {
        try {
          await uploadFileUseCase(sessionId: sessionId, file: file);
          uploadedCount++;
          developer.log(
            '⬆️ Uploaded $uploadedCount/${filesToUpload.length}',
            name: 'BackgroundSyncService',
          );
        } catch (e) {
          developer.log(
            '❌ Failed to upload file: ${file.fileName}',
            name: 'BackgroundSyncService',
            error: e,
          );
          // Continue with other files
        }
      }

      // 6. Complete session
      developer.log('✅ Completing sync session...', name: 'BackgroundSyncService');
      await completeSyncSessionUseCase(sessionId: sessionId);

      developer.log(
        '🎉 Sync completed: $uploadedCount files uploaded',
        name: 'BackgroundSyncService',
      );

      return _SyncResult.success(uploadedCount);
    } catch (e, stackTrace) {
      developer.log(
        '❌ Sync execution failed',
        name: 'BackgroundSyncService',
        error: e,
        stackTrace: stackTrace,
      );

      // Cancel session if it was started
      if (sessionId != null) {
        try {
          await syncSessionRepository.cancelSyncSession(sessionId: sessionId);
          developer.log('🚫 Session cancelled: $sessionId', name: 'BackgroundSyncService');
        } catch (e) {
          developer.log('❌ Failed to cancel session', name: 'BackgroundSyncService', error: e);
        }
      }

      return _SyncResult.failure(e.toString());
    }
  }

  /// Record successful sync attempt
  void _recordSuccessfulSync() {
    final now = DateTime.now().toIso8601String();
    sharedPreferences.setString(_lastSyncAttemptKey, now);
    developer.log('📝 Recorded successful sync at $now', name: 'BackgroundSyncService');
  }

  /// Record failed sync attempt
  void _recordFailedSync() {
    final now = DateTime.now().toIso8601String();
    sharedPreferences.setString(_lastSyncAttemptKey, now);
    developer.log('📝 Recorded failed sync at $now', name: 'BackgroundSyncService');
  }

  /// Get last sync attempt time
  DateTime? getLastSyncAttempt() {
    final lastAttempt = sharedPreferences.getString(_lastSyncAttemptKey);
    if (lastAttempt != null) {
      return DateTime.tryParse(lastAttempt);
    }
    return null;
  }
}
