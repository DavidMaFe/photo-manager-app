import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/database/app_database.dart';
import 'package:photo_manager_app/core/errors/base/failure_codes.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/core/services/sync_lock.dart';
import 'package:photo_manager_app/core/widgets/permission/permission_helper.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/media_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/check_duplicated_files_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/complete_sync_session_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/start_sync_session_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/upload_file_use_case.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_event.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_state.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../../../core/errors/base/failures.dart';
import '../../../../core/errors/handler/error_handler.dart';


class SyncSessionBloc extends Bloc<SyncSessionEvent, SyncSessionState> {

  final StartSyncSessionUseCase startSyncSessionUseCase;
  final CheckDuplicatedFilesUseCase checkDuplicatedFilesUseCase;
  final UploadFileUseCase uploadFileUseCase;
  final CompleteSyncSessionUseCase completeSyncSessionUseCase;
  final SyncDeviceRepository syncDeviceRepository;
  final SyncSessionRepository syncSessionRepository;
  final MediaLocalDataSource mediaLocalDataSource;
  final AppEventBus eventBus;
  final SyncLock syncLock;

  String? _currentSessionId;
  bool _isCancelled = false;

  SyncSessionBloc({
    required this.startSyncSessionUseCase,
    required this.checkDuplicatedFilesUseCase,
    required this.uploadFileUseCase,
    required this.completeSyncSessionUseCase,
    required this.syncDeviceRepository,
    required this.syncSessionRepository,
    required this.mediaLocalDataSource,
    required this.eventBus,
    required this.syncLock,
  }) : super(const SyncSessionInitial()) {
    on<SyncSessionStarted>(_onSyncSessionStarted);
    on<SyncSessionCancelled>(_onSyncSessionCancelled);
    on<SyncSessionRetried>(_onSyncSessionRetried);
    on<SyncSessionReset>(_onSyncSessionReset);
  }

  Future<void> _onSyncSessionStarted(SyncSessionStarted event, Emitter<SyncSessionState> emit) async {

    _isCancelled = false;
    _currentSessionId = null;

    try {
      // Check if background sync is in progress (the lock may have been taken
      // or released by the WorkManager isolate, so it is read from disk)
      final lockCheck = await syncLock.check();
      if (lockCheck.isHeld) {
        emit(const SyncSessionError(
          ConcurrencyFailure(
            messageKey: 'syncInProgressError',
            code: FailureCodes.syncSessionAlreadyInProgress,
          ),
        ));
        return;
      }

      emit(const SyncSessionStarting());
      final startStopwatch = Stopwatch()..start();

      final deviceUuid = await syncDeviceRepository.getDeviceUuid();
      final session = await startSyncSessionUseCase(deviceUuid: deviceUuid);
      _currentSessionId = session.id;

      if (_isCancelled) {
        await _handleCancellation(emit, null);
        return;
      }

      await _waitForLoading(startStopwatch, 2000);

      emit(const SyncSessionFetchingFiles());
      final fetchingFilesStopwatch = Stopwatch()..start();

      // Request permission with education and denial dialogs
      if (!event.context.mounted) {
        emit(SyncSessionError(ErrorHandler.handleError(Exception('Context not mounted'))));
        return;
      }

      final l10n = AppLocalizations.of(event.context)!;
      final hasPermission = await PermissionHelper.requestPhotoAccess(
        context: event.context,
        educationTitle: l10n.permissionPhotoAccessTitle,
        educationMessage: l10n.permissionPhotoAccessMessage,
        deniedTitle: l10n.permissionPhotoAccessDeniedTitle,
        deniedMessage: l10n.permissionPhotoAccessDeniedMessage,
        continueText: l10n.permissionPhotoAccessContinue,
        settingsText: l10n.permissionOpenSettings,
        cancelText: l10n.cancel,
      );

      if (!hasPermission) {
        // Cancel the session on the server since permission was denied
        if (_currentSessionId != null) {
          try {
            await syncSessionRepository.cancelSyncSession(sessionId: _currentSessionId!);
          } catch (e) {
            // Log error but continue with permission failure
            // The permission error is more important to show to the user
          }
        }

        Failure failure = ErrorHandler.handleError(Exception(FailureCodes.galleryPermissionError));
        emit(SyncSessionError(failure));
        return;
      }

      final scannedFiles = await mediaLocalDataSource.scanMediaFiles(
        lastCompletedSyncAt: session.lastCompletedAt
      );

      await _waitForLoading(fetchingFilesStopwatch, 3000);
      if (scannedFiles.isEmpty) {
        await _completeSession(emit, session.id);
        return;
      }

      if (_isCancelled) {
        await _handleCancellation(emit, null);
        return;
      }

      final fileHashes = scannedFiles.map((file) => file.hash).toList();
      final duplicateCheckResult = await checkDuplicatedFilesUseCase(
        sessionId: session.id, fileHashes: fileHashes
      );

      if (duplicateCheckResult.allFilesAreDuplicates) {
        await _completeSession(emit, session.id);
        return;
      }

      final filesToUpload = scannedFiles.where((file) {
        return duplicateCheckResult.filesToUpload.contains(file.hash);
      }).toList();

      if (_isCancelled) {
        await _handleCancellation(emit, null);
        return;
      }

      int uploadedCount = 0;
      int totalCount = duplicateCheckResult.totalFiles;
      int remainingBytes = filesToUpload.fold(0, (total, file) => total + file.sizeBytes);

      emit(SyncSessionUploading(uploadCount: uploadedCount, totalCount: totalCount, remainingBytes: remainingBytes));
      for (final file in filesToUpload) {

        final uploadingFileStopWatch = Stopwatch()..start();

        if (_isCancelled) {
          await _handleCancellation(emit, uploadedCount);
          return;
        }

        final uploadResult = await uploadFileUseCase(sessionId: session.id, file: file);
        if(uploadResult.serverFileId != null) {
          await AppDatabase().saveFileMapping(
            serverId: uploadResult.serverFileId!,
            localId: file.localId,
            localPath: file.devicePath,
            hash: file.hash,
          );

          uploadedCount++;
        }
        // Sent or failed, the file is no longer pending in this session.
        remainingBytes -= file.sizeBytes;

        emit(SyncSessionUploading(uploadCount: uploadedCount,
            totalCount: totalCount, currentFileName: file.fileName, remainingBytes: remainingBytes));

        await _waitForLoading(uploadingFileStopWatch, 300);
      }

      if (_isCancelled) {
        await _handleCancellation(emit, uploadedCount);
        return;
      }

      await _completeSession(emit, session.id);

    } catch (e) {
      if (_currentSessionId != null) {

        try {

          await syncSessionRepository.cancelSyncSession(sessionId: _currentSessionId!);
        } catch (cancelError) {

          final failure = ErrorHandler.handleError(cancelError);
          emit(SyncSessionError(failure));
        }
      }

      final failure = ErrorHandler.handleError(e);
      emit(SyncSessionError(failure));
    }

  }

  Future<void> _onSyncSessionCancelled(SyncSessionCancelled event, Emitter<SyncSessionState> emit) async {

    _isCancelled = true;

    if (state is SyncSessionSuccess || state is SyncSessionCancelling || state is SyncSessionError) {
      return;
    }
  }

  Future<void> _onSyncSessionRetried(SyncSessionRetried event, Emitter<SyncSessionState> emit) async {
    await _onSyncSessionStarted(SyncSessionStarted(event.context), emit);
  }

  Future<void> _onSyncSessionReset(SyncSessionReset event, Emitter<SyncSessionState> emit) async {
    emit(const SyncSessionStarting());
  }

  Future<void> _handleCancellation(Emitter<SyncSessionState> emit, int? uploadedCount) async {

    if (_currentSessionId != null) {
      try {
        await syncSessionRepository.cancelSyncSession(sessionId: _currentSessionId!);
      } catch (e) {
        final failure = ErrorHandler.handleError(e);
        emit(SyncSessionError(failure));
      }
    }

    emit(SyncSessionCancelling(uploadedCount));
  }

  @override
  Future<void> close() {
    _currentSessionId = null;
    _isCancelled = false;
    return super.close();
  }

  Future<void> _completeSession(Emitter<SyncSessionState> emit, String sessionId) async {

    emit(const SyncSessionCompleting());
    final completeSessionStopWatch = Stopwatch()..start();
    await _waitForLoading(completeSessionStopWatch, 2000);

    final result = await completeSyncSessionUseCase(sessionId: sessionId);

    emit(SyncSessionSuccess(result));

    // Broadcast sync completed event
    eventBus.fire(SyncCompletedEvent(
      syncSessionId: sessionId,
      newFilesCount: result.uploadedFiles,
      completedAt: DateTime.now(),
    ));

    // Invalidate related caches
    eventBus.fire(const CacheInvalidationEvent(type: CacheInvalidationType.syncHistory));
    eventBus.fire(const CacheInvalidationEvent(type: CacheInvalidationType.files));
    eventBus.fire(const CacheInvalidationEvent(type: CacheInvalidationType.gallery));
  }

  Future<void> _waitForLoading(Stopwatch stopwatch, int duration) async {
    stopwatch.stop();
    final elapsed = stopwatch.elapsedMilliseconds;
    final remaining = duration - elapsed;

    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }
  }
}