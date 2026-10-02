import 'dart:async';
import 'dart:developer' as developer;

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:photo_manager_app/core/database/app_database.dart';
import 'package:photo_manager_app/core/services/sync_log_service.dart';
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

/// Result of a background sync operation.
class _SyncResult {
  final bool success;
  final int filesUploaded;
  final String? errorMessage;

  /// True when the failure is caused by an authentication error (expired
  /// tokens, revoked refresh token). In this case [BackgroundTaskHandler]
  /// should skip the 1-hour retry (it will fail for the same reason) and
  /// instead schedule the next regular recurrence so the chain is maintained.
  final bool isAuthFailure;

  _SyncResult({
    required this.success,
    this.filesUploaded = 0,
    this.errorMessage,
    this.isAuthFailure = false,
  });

  factory _SyncResult.success(int filesUploaded) =>
      _SyncResult(success: true, filesUploaded: filesUploaded);

  factory _SyncResult.failure(String errorMessage) =>
      _SyncResult(success: false, errorMessage: errorMessage);

  /// Use this factory when the failure is definitively auth-related.
  factory _SyncResult.authFailure(String errorMessage) =>
      _SyncResult(success: false, errorMessage: errorMessage, isAuthFailure: true);
}

/// Service for executing background synchronization.
///
/// Every key checkpoint is written to [SyncLogService] (persisted to
/// SharedPreferences) so the result can be inspected from the UI without
/// a USB-connected logcat session.
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
  final SyncLogService syncLogService;

  static const String _syncLockKey = 'SYNC_IN_PROGRESS';
  static const String _syncLockAcquiredAtKey = 'SYNC_LOCK_ACQUIRED_AT';
  static const String _lastSyncAttemptKey = 'LAST_SYNC_ATTEMPT';
  static const String _lastSyncAuthFailureKey = 'SYNC_LAST_FAILURE_IS_AUTH';

  /// Maximum time a sync lock may be held before it is considered stale.
  ///
  /// If the OS kills the WorkManager process mid-sync (e.g. during Doze mode
  /// at 2 AM), the [_releaseSyncLock] call in the `finally` block never runs
  /// and the lock remains `true` in SharedPreferences indefinitely. Any
  /// subsequent scheduled run would see the lock and silently skip itself.
  ///
  /// To prevent this, [_isSyncInProgress] checks how long the lock has been
  /// held. If it exceeds this threshold the lock is auto-released and the
  /// current run proceeds normally.
  static const Duration _syncLockMaxDuration = Duration(minutes: 30);

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
    required this.syncLogService,
  });

  /// Execute background sync.
  ///
  /// Returns true if sync completed successfully, false otherwise.
  Future<bool> execute() async {
    syncLogService.write('— execute() iniciado');

    try {
      // 1. Check if sync is already in progress (also auto-releases stale locks)
      if (_isSyncInProgress()) {
        syncLogService.write('■ Ejecución omitida (lock activo)');
        return false;
      }

      // 2. Check authentication
      final authenticated = await _isAuthenticated();
      if (!authenticated) {
        syncLogService.write('✗ Auth: usuario no autenticado — cancelando');
        return false;
      }
      syncLogService.write('✓ Auth: OK');

      // 3. Load sync configuration
      final syncConfig = await syncConfigRepository.getSyncConfig();
      if (syncConfig == null || !syncConfig.autoSyncEnabled) {
        syncLogService.write('✗ Config: auto-sync desactivado — cancelando');
        return false;
      }
      syncLogService.write('✓ Config: ${syncConfig.syncFrequency.name}, '
          'red=${syncConfig.networkPreference.name}, '
          'batería=${syncConfig.batteryPreference.name}');

      // 4. Validate network conditions
      final networkOk = await _validateNetworkConditions(syncConfig);
      if (!networkOk) {
        return false; // reason already logged inside helper
      }

      // 5. Validate battery conditions
      final batteryOk = await _validateBatteryConditions(syncConfig);
      if (!batteryOk) {
        return false; // reason already logged inside helper
      }

      // 6. Acquire sync lock
      _acquireSyncLock();

      try {
        // 7. Start foreground service (Android 12+)
        try {
          await notificationService.showForegroundNotification();
          syncLogService.write('✓ Servicio en primer plano iniciado');
        } catch (e) {
          syncLogService.write('⚠ Servicio en primer plano falló ($e) — continúa');
        }

        // 8. Execute sync
        final result = await _performSync(syncConfig);

        // 9. Stop foreground service
        await notificationService.hideForegroundNotification();

        if (result.success) {
          _recordSuccessfulSync();
          syncLogService.writeResult(
            success: true,
            detail: '${result.filesUploaded} archivos subidos',
          );

          if (syncConfig.notifyOnSuccess) {
            await notificationService.showSyncSuccessNotification(
              filesUploaded: result.filesUploaded,
            );
          }
        } else {
          _recordFailedSync(isAuthFailure: result.isAuthFailure);
          syncLogService.writeResult(
            success: false,
            detail: result.errorMessage ?? 'Error desconocido',
          );

          if (syncConfig.notifyOnFailure) {
            await notificationService.showSyncFailureNotification(
              errorMessage: result.errorMessage ?? 'Error desconocido',
            );
          }
        }

        return result.success;
      } finally {
        _releaseSyncLock();
        await notificationService.hideForegroundNotification();
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ BackgroundSyncService.execute failed',
        name: 'BackgroundSyncService',
        error: e,
        stackTrace: stackTrace,
      );
      _releaseSyncLock();
      final isAuth = _isAuthRelatedError(e);
      _recordFailedSync(isAuthFailure: isAuth);
      syncLogService.writeResult(success: false, detail: e.toString());
      return false;
    }
  }

  /// Returns true if a sync is currently in progress.
  ///
  /// Also detects and auto-releases **stale locks** left behind when the OS
  /// killed the WorkManager process before [_releaseSyncLock] could run
  /// (e.g. Doze mode interruption at 2 AM). A lock older than
  /// [_syncLockMaxDuration] is considered stale and is cleared so the next
  /// scheduled run is not blocked forever.
  bool _isSyncInProgress() {
    final isLocked = sharedPreferences.getBool(_syncLockKey) ?? false;
    if (!isLocked) return false;

    // Check whether the lock is stale.
    final acquiredAtStr =
        sharedPreferences.getString(_syncLockAcquiredAtKey);

    if (acquiredAtStr == null) {
      // Lock exists but has no timestamp (legacy or corrupted) — treat as stale.
      syncLogService.write(
          '⚠ Lock sin timestamp detectado — liberando lock obsoleto');
      _releaseSyncLock();
      return false;
    }

    final acquiredAt = DateTime.tryParse(acquiredAtStr);
    if (acquiredAt == null) {
      syncLogService.write(
          '⚠ Timestamp de lock inválido ("$acquiredAtStr") — liberando');
      _releaseSyncLock();
      return false;
    }

    final lockAge = DateTime.now().difference(acquiredAt);
    if (lockAge > _syncLockMaxDuration) {
      syncLogService.write(
          '⚠ Lock obsoleto (${lockAge.inMinutes} min > '
          '${_syncLockMaxDuration.inMinutes} min) — '
          'liberando y continuando con la ejecución');
      _releaseSyncLock();
      return false;
    }

    syncLogService.write(
        '⚠ Sync ya en progreso (lock adquirido hace ${lockAge.inMinutes} min)');
    return true;
  }

  void _acquireSyncLock() {
    sharedPreferences.setBool(_syncLockKey, true);
    sharedPreferences.setString(
        _syncLockAcquiredAtKey, DateTime.now().toIso8601String());
  }

  void _releaseSyncLock() {
    sharedPreferences.setBool(_syncLockKey, false);
    sharedPreferences.remove(_syncLockAcquiredAtKey);
  }

  Future<bool> _isAuthenticated() async {
    try {
      final user = await authRepository.getCurrentUser();
      return user != null;
    } catch (e) {
      syncLogService.write('✗ Auth check exception: $e');
      return false;
    }
  }

  Future<bool> _validateNetworkConditions(SyncConfig config) async {
    try {
      final connectivity = Connectivity();
      final results = await connectivity.checkConnectivity();

      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        syncLogService.write('✗ Red: sin conexión');
        return false;
      }

      if (config.requiresWifiOnly) {
        final hasWifi = results.contains(ConnectivityResult.wifi);
        if (!hasWifi) {
          syncLogService.write('✗ Red: se requiere WiFi pero hay datos móviles');
          return false;
        }
        syncLogService.write('✓ Red: WiFi disponible');
      } else {
        syncLogService.write('✓ Red: conectado (${results.map((r) => r.name).join(", ")})');
      }
      return true;
    } catch (e) {
      syncLogService.write('✗ Red: error comprobando conexión ($e)');
      return false;
    }
  }

  Future<bool> _validateBatteryConditions(SyncConfig config) async {
    try {
      if (!config.requiresBatteryCondition) {
        syncLogService.write('✓ Batería: sin restricción');
        return true;
      }

      final battery = Battery();
      final batteryState = await battery.batteryState;
      final isCharging = batteryState == BatteryState.charging ||
          batteryState == BatteryState.full;

      if (isCharging) {
        syncLogService.write('✓ Batería: cargando');
        return true;
      }

      final batteryLevel = await battery.batteryLevel;
      if (batteryLevel > 15) {
        syncLogService.write('✓ Batería: $batteryLevel% (sin cargar)');
        return true;
      }

      syncLogService.write('✗ Batería: $batteryLevel%, no cargando — cancelando');
      return false;
    } catch (e) {
      syncLogService.write('⚠ Batería: error ($e) — continúa de todos modos');
      return true;
    }
  }

  Future<_SyncResult> _performSync(SyncConfig config) async {
    String? sessionId;

    try {
      final deviceUuid = await syncDeviceRepository.getDeviceUuid();
      syncLogService.write('✓ UUID dispositivo: $deviceUuid');

      final session = await startSyncSessionUseCase(deviceUuid: deviceUuid);
      sessionId = session.id;
      syncLogService.write('✓ Sesión iniciada: $sessionId');

      final mediaFiles = await mediaLocalDataSource.scanMediaFiles(
          lastCompletedSyncAt: session.lastCompletedAt,
          skipPermissionCheck: true,
      );
      syncLogService.write('✓ Archivos multimedia encontrados: ${mediaFiles.length}');

      if (mediaFiles.isEmpty) {
        await completeSyncSessionUseCase(sessionId: sessionId);
        syncLogService.write('✓ Sin archivos nuevos — sesión completada');
        return _SyncResult.success(0);
      }

      final hashes = mediaFiles.map((file) => file.hash).toList();
      final duplicateResult = await checkDuplicatesUseCase(
        sessionId: sessionId,
        fileHashes: hashes,
      );

      final hashesToUpload = duplicateResult.filesToUpload.toSet();
      final filesToUpload =
          mediaFiles.where((f) => hashesToUpload.contains(f.hash)).toList();

      syncLogService.write(
        '✓ A subir: ${filesToUpload.length} '
        '(${duplicateResult.duplicatesCount} duplicados omitidos)',
      );

      int uploadedCount = 0;
      for (final file in filesToUpload) {
        try {
          final uploadResult = await uploadFileUseCase(sessionId: sessionId, file: file);
          if (uploadResult.serverFileId != null) {
            await AppDatabase().saveFileMapping(
              serverId: uploadResult.serverFileId!,
              localId: file.localId,
              localPath: file.devicePath,
              hash: file.hash,
            );
          }
          uploadedCount++;
          if (uploadedCount % 5 == 0 || uploadedCount == filesToUpload.length) {
            syncLogService.write('⬆ Subidos $uploadedCount/${filesToUpload.length}');
          }
        } catch (e) {
          syncLogService.write('⚠ Error subiendo ${file.fileName}: $e');
        }
      }

      await completeSyncSessionUseCase(sessionId: sessionId);
      syncLogService.write('✓ Sesión completada: $uploadedCount archivos subidos');

      return _SyncResult.success(uploadedCount);
    } catch (e, stackTrace) {
      developer.log(
        '❌ _performSync failed',
        name: 'BackgroundSyncService',
        error: e,
        stackTrace: stackTrace,
      );

      final isAuth = _isAuthRelatedError(e);
      if (isAuth) {
        syncLogService.write(
          '✗ Error de autenticación en sincronización: las credenciales han '
          'expirado o fueron revocadas. Abre la app para volver a iniciar sesión.',
        );
      } else {
        syncLogService.write('✗ Error en _performSync: $e');
      }

      if (sessionId != null) {
        try {
          await syncSessionRepository.cancelSyncSession(sessionId: sessionId);
          syncLogService.write('✓ Sesión cancelada: $sessionId');
        } catch (cancelError) {
          syncLogService.write('⚠ No se pudo cancelar sesión: $cancelError');
        }
      }

      return isAuth
          ? _SyncResult.authFailure(e.toString())
          : _SyncResult.failure(e.toString());
    }
  }

  void _recordSuccessfulSync() {
    sharedPreferences.setString(_lastSyncAttemptKey, DateTime.now().toIso8601String());
    sharedPreferences.setBool(_lastSyncAuthFailureKey, false);
  }

  void _recordFailedSync({bool isAuthFailure = false}) {
    sharedPreferences.setString(_lastSyncAttemptKey, DateTime.now().toIso8601String());
    sharedPreferences.setBool(_lastSyncAuthFailureKey, isAuthFailure);
  }

  DateTime? getLastSyncAttempt() {
    final lastAttempt = sharedPreferences.getString(_lastSyncAttemptKey);
    return lastAttempt != null ? DateTime.tryParse(lastAttempt) : null;
  }

  /// Returns true when the most recent sync failed due to an authentication
  /// error (expired or revoked tokens). Used by [BackgroundTaskHandler] to
  /// decide whether to schedule a 1-hour retry (pointless for auth errors) or
  /// the next regular recurrence instead.
  bool wasLastFailureAuthRelated() {
    return sharedPreferences.getBool(_lastSyncAuthFailureKey) ?? false;
  }

  /// Heuristic detection of auth-related exceptions.
  ///
  /// Checks common patterns in the exception message. This covers 401
  /// responses, expired-token messages from the server, and refresh-token
  /// failures from [AuthenticatedHttpClient].
  bool _isAuthRelatedError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('401') ||
        message.contains('unauthorized') ||
        message.contains('unauthenticated') ||
        message.contains('token expired') ||
        message.contains('refresh token') ||
        message.contains('invalid token') ||
        message.contains('authentication failed');
  }
}
