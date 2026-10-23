import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'dart:async';
import 'dart:developer' as developer;

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:photo_manager_app/core/database/app_database.dart';
import 'package:photo_manager_app/core/services/sync_log_service.dart';
import 'package:photo_manager_app/core/services/sync_lock.dart';
import 'package:photo_manager_app/core/services/sync_notification_service.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/media_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/sync_keep_alive.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/check_duplicated_files_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/complete_sync_session_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/start_sync_session_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/upload_file_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/files_within_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/get_user_plan_use_case.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/base/failure_codes.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_event_log.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_events.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/storage_budget.dart';

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

  /// True when a limit of the plan stops the backup (read only account, device over the limit or paused). Retrying
  /// in an hour does not help either: like [isAuthFailure], the next regular recurrence is scheduled.
  final bool isPlanLimit;

  /// Files left out because they did not fit in the free space of the plan, and the bytes they would take.
  final int skippedForSpace;
  final int skippedForSpaceBytes;

  _SyncResult({
    required this.success,
    this.filesUploaded = 0,
    this.errorMessage,
    this.isAuthFailure = false,
    this.isPlanLimit = false,
    this.skippedForSpace = 0,
    this.skippedForSpaceBytes = 0,
  });

  factory _SyncResult.success(int filesUploaded, {int skippedForSpace = 0, int skippedForSpaceBytes = 0}) =>
      _SyncResult(success: true, filesUploaded: filesUploaded,
          skippedForSpace: skippedForSpace, skippedForSpaceBytes: skippedForSpaceBytes);

  factory _SyncResult.failure(String errorMessage) =>
      _SyncResult(success: false, errorMessage: errorMessage);

  /// Use this factory when the failure is definitively auth-related.
  factory _SyncResult.authFailure(String errorMessage) =>
      _SyncResult(success: false, errorMessage: errorMessage, isAuthFailure: true);

  factory _SyncResult.planLimit(String errorMessage) =>
      _SyncResult(success: false, errorMessage: errorMessage, isPlanLimit: true);
}

/// Codes of the server for a limit of the plan that stops the whole backup (CLAUDE.md of the backend). A file that
/// does not fit in the free space (`USER_NOT_HAVE_STORAGE_SPACE`) is skipped instead: smaller ones may still fit.
const _planLimitCodes = {
  FailureCodes.accountReadOnly,
  FailureCodes.deviceLimitReached,
  FailureCodes.devicePaused,
};

bool _isPlanLimit(Object error) => error is ApiException && _planLimitCodes.contains(error.code);

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
  final SyncLock syncLock;
  final SyncKeepAlive syncKeepAlive;
  final GetUserPlanUseCase getUserPlanUseCase;
  final AppEventLog appEventLog;
  final Connectivity _connectivity;
  final Battery _battery;

  static const String _lastSyncAttemptKey = 'LAST_SYNC_ATTEMPT';
  static const String _lastSyncAuthFailureKey = 'SYNC_LAST_FAILURE_IS_AUTH';

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
    required this.syncLock,
    required this.syncKeepAlive,
    required this.getUserPlanUseCase,
    required this.appEventLog,
    Connectivity? connectivity,
    Battery? battery,
  })  : _connectivity = connectivity ?? Connectivity(),
        _battery = battery ?? Battery();

  /// Execute background sync.
  ///
  /// Returns true if sync completed successfully, false otherwise.
  Future<bool> execute() async {
    syncLogService.write('— execute() iniciado');

    try {
      // 1. Check if sync is already in progress (also auto-releases stale locks)
      if (await _isSyncInProgress()) {
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
      await syncLock.acquire();

      try {
        // 7. Start foreground service (Android 12+)
        try {
          await syncKeepAlive.start();
          syncLogService.write('✓ Servicio en primer plano iniciado');
        } catch (e) {
          syncLogService.write('⚠ Servicio en primer plano falló ($e) — continúa');
        }

        // 8. Execute sync
        final result = await _performSync(syncConfig);

        // 9. Stop foreground service
        await syncKeepAlive.stop();

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
          // Files left out need the user (a bigger plan or less stored): told like a failure
          if (result.skippedForSpace > 0) {
            appEventLog.record(SyncStorageFull(
                background: true, files: result.skippedForSpace, bytes: result.skippedForSpaceBytes));
            if (syncConfig.notifyOnFailure) {
              await notificationService.showStorageFullNotification(
                  files: result.skippedForSpace, bytes: result.skippedForSpaceBytes);
            }
          }
        } else {
          // A limit of the plan is not retried in an hour either (wasLastFailureAuthRelated)
          _recordFailedSync(isAuthFailure: result.isAuthFailure || result.isPlanLimit);
          syncLogService.writeResult(
            success: false,
            detail: result.errorMessage ?? 'Error desconocido',
          );

          if (syncConfig.notifyOnFailure) {
            await notificationService.showSyncFailureNotification(
              sessionExpired: result.isAuthFailure,
              planLimit: result.isPlanLimit,
            );
          }
        }

        return result.success;
      } finally {
        await syncLock.release();
        await syncKeepAlive.stop();
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ BackgroundSyncService.execute failed',
        name: 'BackgroundSyncService',
        error: e,
        stackTrace: stackTrace,
      );
      await syncLock.release();
      final isAuth = _isAuthRelatedError(e);
      _recordFailedSync(isAuthFailure: isAuth);
      syncLogService.writeResult(success: false, detail: e.toString());
      return false;
    }
  }

  /// Returns true if a sync is currently in progress.
  ///
  /// [SyncLock.check] also auto-releases **stale locks** left behind when the
  /// OS killed the WorkManager process before the lock could be released
  /// (e.g. Doze mode interruption at 2 AM), so the next scheduled run is not
  /// blocked forever.
  Future<bool> _isSyncInProgress() async {
    final lockCheck = await syncLock.check();
    final ageMinutes = lockCheck.age?.inMinutes;

    switch (lockCheck.status) {
      case SyncLockStatus.free:
        return false;
      case SyncLockStatus.releasedStale:
        syncLogService.write(ageMinutes == null
            ? '⚠ Lock sin timestamp válido detectado — liberando lock obsoleto'
            : '⚠ Lock obsoleto ($ageMinutes min sin señal > ${SyncLock.maxDuration.inMinutes} min) — '
                'liberando y continuando con la ejecución');
        return false;
      case SyncLockStatus.held:
        syncLogService.write('⚠ Sync ya en progreso (última señal hace $ageMinutes min)');
        return true;
    }
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
      final results = await _connectivity.checkConnectivity();

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

      final batteryState = await _battery.batteryState;
      final isCharging = batteryState == BatteryState.charging ||
          batteryState == BatteryState.full;

      if (isCharging) {
        syncLogService.write('✓ Batería: cargando');
        return true;
      }

      final batteryLevel = await _battery.batteryLevel;
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
      // A read only account (a paid plan ended with more stored than the free plan) uploads nothing
      final plan = await _readPlan();
      if (plan != null && plan.readOnly) {
        syncLogService.write('✗ Cuenta en solo lectura: el plan no permite subir más');
        return _SyncResult.planLimit(FailureCodes.accountReadOnly);
      }

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
      final pending = mediaFiles.where((f) => hashesToUpload.contains(f.hash)).toList();
      // Videos over the limit of the plan are left out: the server would reject them after sending them whole
      final filesToUpload = filesWithinPlan(pending, plan);
      if (filesToUpload.length < pending.length) {
        syncLogService.write('⚠ ${pending.length - filesToUpload.length} vídeos superan el límite del plan');
      }

      syncLogService.write(
        '✓ A subir: ${filesToUpload.length} '
        '(${duplicateResult.duplicatesCount} duplicados omitidos)',
      );

      // Files that do not fit in the free space are skipped without sending them; the backup goes on with the rest
      final budget = StorageBudget(plan);
      final pendingBytes = filesToUpload.fold(0, (total, file) => total + file.sizeBytes);
      if (!budget.fits(pendingBytes)) {
        syncLogService.write('⚠ Lo pendiente no cabe en el espacio libre: se sube lo que quepa');
      }
      int skippedForSpace = 0;
      int skippedForSpaceBytes = 0;

      int uploadedCount = 0;
      for (final file in filesToUpload) {
        try {
          final uploadResult = await uploadFileUseCase(sessionId: sessionId, file: file, budget: budget);
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
        } on FileDoesNotFitFailure catch (e) {
          skippedForSpace++;
          skippedForSpaceBytes += e.storedBytes;
        } catch (e) {
          // No space left on the server (another device uploaded meanwhile): the free space is read again and the
          // backup goes on with what fits
          if (e is ApiException && e.code == FailureCodes.userDoesNotHaveStorageSpace) {
            budget.refresh(await _readPlan());
            skippedForSpace++;
            skippedForSpaceBytes += file.sizeBytes;
          } else {
            // A limit of the plan stops every upload the same way
            if (_isPlanLimit(e)) rethrow;
            // Every file would fail the same way: the keys are refreshed the next time the app is opened
            if (e is OutdatedKeysFailure || e is MissingCurrentKeyFailure) {
              syncLogService.write('✗ Las claves cambiaron en otro dispositivo: abre la app para actualizarlas');
              rethrow;
            }
            // Never the name of the file: it is metadata that the server only receives encrypted
            syncLogService.write(
                '⚠ Error subiendo el archivo ${filesToUpload.indexOf(file) + 1}/${filesToUpload.length}: $e');
          }
        }
        await syncKeepAlive.update(current: filesToUpload.indexOf(file) + 1, total: filesToUpload.length);
      }

      await completeSyncSessionUseCase(sessionId: sessionId);
      syncLogService.write('✓ Sesión completada: $uploadedCount archivos subidos');
      if (skippedForSpace > 0) {
        syncLogService.write('⚠ $skippedForSpace archivos no cabían en el espacio libre ($skippedForSpaceBytes bytes)');
      }

      return _SyncResult.success(uploadedCount,
          skippedForSpace: skippedForSpace, skippedForSpaceBytes: skippedForSpaceBytes);
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

      if (_isPlanLimit(e)) return _SyncResult.planLimit(e.toString());
      return isAuth
          ? _SyncResult.authFailure(e.toString())
          : _SyncResult.failure(e.toString());
    }
  }

  /// The plan of the user, or null when it cannot be read (the server applies the limits anyway).
  Future<UserPlan?> _readPlan() async {
    try {
      return await getUserPlanUseCase();
    } catch (_) {
      return null;
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
