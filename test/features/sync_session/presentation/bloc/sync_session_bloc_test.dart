import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failure_codes.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_limits.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/get_user_plan_use_case.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_event_log.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_events.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_log_event.dart';
import 'package:photo_manager_app/core/services/sync_lock.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/register_local_albums_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/backup_scan.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/complete_backup_scan_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/scan_backup_files_use_case.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_file_model.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/duplicate_files_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/upload_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/storage_budget.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_session.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/sync_keep_alive.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/check_duplicated_files_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/complete_sync_session_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/start_sync_session_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/upload_file_use_case.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_bloc.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_event.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_state.dart';

import '../../../../helpers/plan_test_providers.dart';

class MockStartSyncSessionUseCase extends Mock implements StartSyncSessionUseCase {}
class MockCheckDuplicatedFilesUseCase extends Mock implements CheckDuplicatedFilesUseCase {}
class MockUploadFileUseCase extends Mock implements UploadFileUseCase {}
class MockCompleteSyncSessionUseCase extends Mock implements CompleteSyncSessionUseCase {}
class MockSyncDeviceRepository extends Mock implements SyncDeviceRepository {}
class MockSyncSessionRepository extends Mock implements SyncSessionRepository {}
class MockScanBackupFilesUseCase extends Mock implements ScanBackupFilesUseCase {}
class MockRegisterLocalAlbumsUseCase extends Mock implements RegisterLocalAlbumsUseCase {}
class MockCompleteBackupScanUseCase extends Mock implements CompleteBackupScanUseCase {}
class MockAppEventBus extends Mock implements AppEventBus {}
class MockBuildContext extends Mock implements BuildContext {}
class MockSyncLock extends Mock implements SyncLock {}
class MockSyncKeepAlive extends Mock implements SyncKeepAlive {}
class MockGetUserPlanUseCase extends Mock implements GetUserPlanUseCase {}

class FakeAppEvent extends Fake implements AppEvent {}
class MockAppEventLog extends Mock implements AppEventLog {}
class FakeAppLogEvent extends Fake implements AppLogEvent {}
class FakeSyncFile extends Fake implements SyncFile {}
class FakeStorageBudget extends Fake implements StorageBudget {}

void main() {
  final scanStartedAt = DateTime(2026, 10, 23, 12);
  late SyncSessionBloc bloc;
  late MockStartSyncSessionUseCase mockStartUseCase;
  late MockCheckDuplicatedFilesUseCase mockCheckDuplicatesUseCase;
  late MockUploadFileUseCase mockUploadUseCase;
  late MockCompleteSyncSessionUseCase mockCompleteUseCase;
  late MockSyncDeviceRepository mockDeviceRepository;
  late MockSyncSessionRepository mockSessionRepository;
  late MockScanBackupFilesUseCase scanBackupFiles;
  late MockCompleteBackupScanUseCase completeBackupScan;
  late MockRegisterLocalAlbumsUseCase registerLocalAlbums;
  late MockAppEventBus mockEventBus;
  late MockBuildContext mockContext;
  late MockSyncLock mockSyncLock;
  late MockSyncKeepAlive mockKeepAlive;

  setUpAll(() {
    registerFallbackValue(FakeAppEvent());
    registerFallbackValue(FakeSyncFile());
    registerFallbackValue(BackupScan(files: const [], startedAt: DateTime(2026)));
    registerFallbackValue(<String>{});
    registerFallbackValue(FakeStorageBudget());
    registerFallbackValue(FakeAppLogEvent());
  });

  late MockGetUserPlanUseCase mockGetUserPlan;
  late MockAppEventLog mockAppEventLog;

  setUp(() {
    mockAppEventLog = MockAppEventLog();
    mockStartUseCase = MockStartSyncSessionUseCase();
    mockCheckDuplicatesUseCase = MockCheckDuplicatedFilesUseCase();
    mockUploadUseCase = MockUploadFileUseCase();
    mockCompleteUseCase = MockCompleteSyncSessionUseCase();
    mockDeviceRepository = MockSyncDeviceRepository();
    mockSessionRepository = MockSyncSessionRepository();
    scanBackupFiles = MockScanBackupFilesUseCase();
    completeBackupScan = MockCompleteBackupScanUseCase();
    when(() => completeBackupScan(any(), any())).thenAnswer((_) async {});
    registerLocalAlbums = MockRegisterLocalAlbumsUseCase();
    when(() => registerLocalAlbums()).thenAnswer((_) async => []);
    mockEventBus = MockAppEventBus();
    mockContext = MockBuildContext();
    mockSyncLock = MockSyncLock();
    mockKeepAlive = MockSyncKeepAlive();
    mockGetUserPlan = MockGetUserPlanUseCase();
    // The free plan, writable
    when(() => mockGetUserPlan()).thenAnswer((_) async => TestPlans.free);

    // Mock context.mounted to return true
    when(() => mockContext.mounted).thenReturn(true);

    // Mock cancelSyncSession to prevent errors
    when(() => mockSessionRepository.cancelSyncSession(sessionId: any(named: 'sessionId')))
        .thenAnswer((_) async => {});

    // No sync in progress by default
    when(() => mockSyncLock.check()).thenAnswer((_) async => const SyncLockCheck(SyncLockStatus.free));
    when(() => mockSyncLock.acquire()).thenAnswer((_) async {});
    when(() => mockSyncLock.release()).thenAnswer((_) async {});
    when(() => mockKeepAlive.start()).thenAnswer((_) async {});
    when(() => mockKeepAlive.stop()).thenAnswer((_) async {});

    bloc = SyncSessionBloc(
      startSyncSessionUseCase: mockStartUseCase,
      checkDuplicatedFilesUseCase: mockCheckDuplicatesUseCase,
      uploadFileUseCase: mockUploadUseCase,
      completeSyncSessionUseCase: mockCompleteUseCase,
      syncDeviceRepository: mockDeviceRepository,
      syncSessionRepository: mockSessionRepository,
      scanBackupFilesUseCase: scanBackupFiles,
      completeBackupScanUseCase: completeBackupScan,
      registerLocalAlbumsUseCase: registerLocalAlbums,
      eventBus: mockEventBus,
      syncLock: mockSyncLock,
      syncKeepAlive: mockKeepAlive,
      getUserPlanUseCase: mockGetUserPlan,
      appEventLog: mockAppEventLog,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('SyncSessionBloc', () {
    test('initial state is SyncSessionInitial', () {
      expect(bloc.state, const SyncSessionInitial());
    });

    group('SyncSessionStarted', () {
      const deviceUuid = 'device-uuid-123';

      // TODO: These tests are commented out because they require PermissionHelper.requestPhotoAccess()
      // which needs a real BuildContext with AppLocalizations. Permission flow should be tested
      // with widget/integration tests in test/features/sync_session/presentation/pages/

      /* const sessionId = 'session-123';
      final session = SyncSession(id: sessionId, lastCompletedAt: DateTime(2024, 1, 1));
      final syncResult = SyncResult(totalFiles: 0, uploadedFiles: 0, failedFiles: 0);

      blocTest<SyncSessionBloc, SyncSessionState>(
        'emits success when no files to upload',
        setUp: () {
          when(() => mockDeviceRepository.getDeviceUuid()).thenAnswer((_) async => deviceUuid);
          when(() => mockStartUseCase(deviceUuid: deviceUuid)).thenAnswer((_) async => session);
          when(() => mockMediaDataSource.requestPermission()).thenAnswer((_) async => true);
          when(() => mockMediaDataSource.scanMediaFiles(lastCompletedSyncAt: any(named: 'lastCompletedSyncAt')))
              .thenAnswer((_) async => []);
          when(() => mockCompleteUseCase(sessionId: sessionId)).thenAnswer((_) async => syncResult);
          when(() => mockEventBus.fire(any())).thenReturn(null);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        wait: const Duration(milliseconds: 8000),
        expect: () => [
          const SyncSessionStarting(),
          const SyncSessionFetchingFiles(),
          const SyncSessionCompleting(),
          SyncSessionSuccess(syncResult),
        ],
        verify: (_) {
          verify(() => mockDeviceRepository.getDeviceUuid()).called(1);
          verify(() => mockStartUseCase(deviceUuid: deviceUuid)).called(1);
          verify(() => mockMediaDataSource.requestPermission()).called(1);
          verify(() => mockCompleteUseCase(sessionId: sessionId)).called(1);
        },
      ); */

      /* blocTest<SyncSessionBloc, SyncSessionState>(
        'emits error when permission denied',
        setUp: () {
          when(() => mockDeviceRepository.getDeviceUuid()).thenAnswer((_) async => deviceUuid);
          when(() => mockStartUseCase(deviceUuid: deviceUuid)).thenAnswer((_) async => session);
          when(() => mockMediaDataSource.requestPermission()).thenAnswer((_) async => false);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        wait: const Duration(milliseconds: 3500),
        expect: () => [
          const SyncSessionStarting(),
          const SyncSessionFetchingFiles(),
          isA<SyncSessionError>(),
        ],
        verify: (_) {
          verify(() => mockMediaDataSource.requestPermission()).called(1);
          verifyNever(() => mockMediaDataSource.scanMediaFiles(lastCompletedSyncAt: any(named: 'lastCompletedSyncAt')));
        },
      ); */

      blocTest<SyncSessionBloc, SyncSessionState>(
        'emits error when start session fails',
        setUp: () {
          when(() => mockDeviceRepository.getDeviceUuid()).thenAnswer((_) async => deviceUuid);
          when(() => mockStartUseCase(deviceUuid: deviceUuid)).thenThrow(Exception('Network error'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        expect: () => [
          const SyncSessionStarting(),
          isA<SyncSessionError>(),
        ],
        verify: (_) {
          verify(() => mockStartUseCase(deviceUuid: deviceUuid)).called(1);
        },
      );
    });

    group('plan limits', () {
      blocTest<SyncSessionBloc, SyncSessionState>(
        'should not start a backup while the account is read only',
        setUp: () {
          when(() => mockGetUserPlan()).thenAnswer((_) async => const UserPlan(
                tier: PlanTier.free,
                limits: PlanLimits(storageBytes: 5 * testGib, maxDevices: 2, maxVideoBytes: 100 * testMib,
                    dailyBackup: false),
                storedBytes: 6 * testGib,
                devices: 1,
                pausedDevices: [],
                readOnly: true,
                subscription: null,
              ));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        expect: () => [
          const SyncSessionStarting(),
          isA<SyncSessionError>()
              .having((state) => state.failure, 'failure', isA<PlanLimitFailure>())
              .having((state) => state.failure.code, 'code', FailureCodes.accountReadOnly),
        ],
        verify: (_) => verifyNever(() => mockStartUseCase(deviceUuid: any(named: 'deviceUuid'))),
      );

      blocTest<SyncSessionBloc, SyncSessionState>(
        'should start the backup when the plan cannot be read (the server applies the limits)',
        setUp: () {
          when(() => mockGetUserPlan()).thenThrow(Exception('offline'));
          when(() => mockDeviceRepository.getDeviceUuid()).thenAnswer((_) async => 'device-uuid-123');
          when(() => mockStartUseCase(deviceUuid: 'device-uuid-123')).thenThrow(Exception('Network error'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        expect: () => [const SyncSessionStarting(), isA<SyncSessionError>()],
        verify: (_) => verify(() => mockStartUseCase(deviceUuid: 'device-uuid-123')).called(1),
      );

      blocTest<SyncSessionBloc, SyncSessionState>(
        'should offer the plans when the device is over the limit of the plan',
        setUp: () {
          when(() => mockDeviceRepository.getDeviceUuid()).thenAnswer((_) async => 'device-uuid-123');
          when(() => mockStartUseCase(deviceUuid: 'device-uuid-123')).thenThrow(ApiException(
              ErrorResponseModel(code: FailureCodes.deviceLimitReached, message: 'Not linked', timestamp: '2026-10-18T10:00:00')));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        expect: () => [
          const SyncSessionStarting(),
          isA<SyncSessionError>().having((state) => state.failure, 'failure', isA<PlanLimitFailure>()),
        ],
      );
    });

    group('SyncLock', () {
      blocTest<SyncSessionBloc, SyncSessionState>(
        'should emit ConcurrencyFailure without starting a session when a sync is in progress',
        setUp: () {
          when(() => mockSyncLock.check()).thenAnswer(
              (_) async => const SyncLockCheck(SyncLockStatus.held, age: Duration(minutes: 2)));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        expect: () => [
          isA<SyncSessionError>().having((state) => state.failure, 'failure', isA<ConcurrencyFailure>()),
        ],
        verify: (_) {
          verifyNever(() => mockStartUseCase(deviceUuid: any(named: 'deviceUuid')));
          verifyNever(() => mockSyncLock.acquire());
          verifyNever(() => mockSyncLock.release());
          verifyNever(() => mockKeepAlive.start());
        },
      );

      blocTest<SyncSessionBloc, SyncSessionState>(
        'should take the lock before starting the session and release it when the sync fails',
        setUp: () {
          when(() => mockDeviceRepository.getDeviceUuid()).thenAnswer((_) async => 'device-uuid-123');
          when(() => mockStartUseCase(deviceUuid: 'device-uuid-123')).thenThrow(Exception('Network error'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        expect: () => [
          const SyncSessionStarting(),
          isA<SyncSessionError>(),
        ],
        verify: (_) {
          verifyInOrder([
            () => mockSyncLock.check(),
            () => mockSyncLock.acquire(),
            () => mockStartUseCase(deviceUuid: 'device-uuid-123'),
            () => mockSyncLock.release(),
          ]);
        },
      );

      blocTest<SyncSessionBloc, SyncSessionState>(
        'should release the lock when the context is no longer mounted',
        setUp: () {
          when(() => mockContext.mounted).thenReturn(false);
          when(() => mockDeviceRepository.getDeviceUuid()).thenAnswer((_) async => 'device-uuid-123');
          when(() => mockStartUseCase(deviceUuid: 'device-uuid-123'))
              .thenAnswer((_) async => SyncSession(id: 'session-123', lastCompletedAt: null));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        wait: const Duration(milliseconds: 2500),
        expect: () => [
          const SyncSessionStarting(),
          const SyncSessionFetchingFiles(),
          isA<SyncSessionError>(),
        ],
        verify: (_) {
          verify(() => mockSyncLock.acquire()).called(1);
          verify(() => mockSyncLock.release()).called(1);
        },
      );

      blocTest<SyncSessionBloc, SyncSessionState>(
        'should start the session when a stale lock was released',
        setUp: () {
          when(() => mockSyncLock.check()).thenAnswer(
              (_) async => const SyncLockCheck(SyncLockStatus.releasedStale, age: Duration(minutes: 31)));
          when(() => mockDeviceRepository.getDeviceUuid()).thenAnswer((_) async => 'device-uuid-123');
          when(() => mockStartUseCase(deviceUuid: 'device-uuid-123')).thenThrow(Exception('Network error'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        expect: () => [
          const SyncSessionStarting(),
          isA<SyncSessionError>(),
        ],
        verify: (_) {
          verify(() => mockStartUseCase(deviceUuid: 'device-uuid-123')).called(1);
          verify(() => mockSyncLock.acquire()).called(1);
          verify(() => mockSyncLock.release()).called(1);
        },
      );

      blocTest<SyncSessionBloc, SyncSessionState>(
        'should check the lock again on every start',
        setUp: () {
          when(() => mockSyncLock.check()).thenAnswer(
              (_) async => const SyncLockCheck(SyncLockStatus.held, age: Duration(minutes: 2)));
        },
        build: () => bloc,
        act: (bloc) async {
          bloc.add(SyncSessionStarted(mockContext));
          await Future<void>.delayed(Duration.zero);
          bloc.add(SyncSessionStarted(mockContext));
        },
        verify: (_) {
          verify(() => mockSyncLock.check()).called(2);
        },
      );
    });

    group('SyncKeepAlive', () {
      blocTest<SyncSessionBloc, SyncSessionState>(
        'should keep the app alive from the start and stop it after the lock is no longer needed when the sync fails',
        setUp: () {
          when(() => mockDeviceRepository.getDeviceUuid()).thenAnswer((_) async => 'device-uuid-123');
          when(() => mockStartUseCase(deviceUuid: 'device-uuid-123')).thenThrow(Exception('Network error'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        expect: () => [
          const SyncSessionStarting(),
          isA<SyncSessionError>(),
        ],
        verify: (_) {
          verifyInOrder([
            () => mockSyncLock.acquire(),
            () => mockKeepAlive.start(),
            () => mockStartUseCase(deviceUuid: 'device-uuid-123'),
            () => mockKeepAlive.stop(),
            () => mockSyncLock.release(),
          ]);
        },
      );

      blocTest<SyncSessionBloc, SyncSessionState>(
        'should stop keeping the app alive when the context is no longer mounted',
        setUp: () {
          when(() => mockContext.mounted).thenReturn(false);
          when(() => mockDeviceRepository.getDeviceUuid()).thenAnswer((_) async => 'device-uuid-123');
          when(() => mockStartUseCase(deviceUuid: 'device-uuid-123'))
              .thenAnswer((_) async => SyncSession(id: 'session-123', lastCompletedAt: null));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        wait: const Duration(milliseconds: 2500),
        verify: (_) {
          verify(() => mockKeepAlive.start()).called(1);
          verify(() => mockKeepAlive.stop()).called(1);
        },
      );
    });

    group('SyncSessionReset', () {
      blocTest<SyncSessionBloc, SyncSessionState>(
        'emits starting state',
        build: () => bloc,
        act: (bloc) => bloc.add(const SyncSessionReset()),
        expect: () => [const SyncSessionStarting()],
      );
    });

    group('free space of the plan', () {
      const sessionId = 'session-123';
      const deviceUuid = 'device-uuid-123';
      // 150 MiB free
      final plan = TestPlans.freeWithStored(5 * testGib - 150 * testMib);

      SyncFileModel image(String hash, int sizeBytes) => SyncFileModel(
            localId: 'local-$hash',
            devicePath: '/photos/$hash.jpg',
            hash: hash,
            fileName: '$hash.jpg',
            sizeBytes: sizeBytes,
            capturedAt: DateTime(2026, 10, 1),
            mimeType: 'image/jpeg',
          );

      final big = image('big', 100 * testMib);
      final tooBig = image('too-big', 80 * testMib);
      final small = image('small', 10 * testMib);

      SyncSessionBloc buildBloc() => SyncSessionBloc(
            startSyncSessionUseCase: mockStartUseCase,
            checkDuplicatedFilesUseCase: mockCheckDuplicatesUseCase,
            uploadFileUseCase: mockUploadUseCase,
            completeSyncSessionUseCase: mockCompleteUseCase,
            syncDeviceRepository: mockDeviceRepository,
            syncSessionRepository: mockSessionRepository,
            scanBackupFilesUseCase: scanBackupFiles,
      completeBackupScanUseCase: completeBackupScan,
      registerLocalAlbumsUseCase: registerLocalAlbums,
            eventBus: mockEventBus,
            syncLock: mockSyncLock,
            syncKeepAlive: mockKeepAlive,
            getUserPlanUseCase: mockGetUserPlan,
            appEventLog: mockAppEventLog,
            requestPhotoAccess: (_) async => true,
          );

      void givenPendingFiles(List<SyncFile> files) {
        when(() => mockGetUserPlan()).thenAnswer((_) async => plan);
        when(() => mockDeviceRepository.getDeviceUuid()).thenAnswer((_) async => deviceUuid);
        when(() => mockStartUseCase(deviceUuid: deviceUuid)).thenAnswer((_) async => SyncSession(id: sessionId));
        when(() => scanBackupFiles(lastCompletedAt: any(named: 'lastCompletedAt')))
            .thenAnswer((_) async => BackupScan(files: files, startedAt: scanStartedAt, userId: 'user-1'));
        when(() => mockCheckDuplicatesUseCase(sessionId: sessionId, fileHashes: any(named: 'fileHashes')))
            .thenAnswer((_) async => DuplicateFilesResult(
                filesToUpload: files.map((file) => file.hash).toList(),
                duplicatesCount: 0,
                totalFiles: files.length));
        // No server id: the file mapping (database) is not written
        when(() => mockUploadUseCase(
                sessionId: sessionId, file: any(named: 'file'), budget: any(named: 'budget')))
            .thenAnswer((_) async => const UploadResult());
        when(() => mockKeepAlive.update(current: any(named: 'current'), total: any(named: 'total')))
            .thenAnswer((_) async {});
        when(() => mockCompleteUseCase(sessionId: sessionId))
            .thenAnswer((_) async => SyncResult(totalFiles: files.length, uploadedFiles: 0, failedFiles: 0));
        when(() => mockEventBus.fire(any())).thenReturn(null);
      }

      void givenUploadFails(SyncFile file, Object error) {
        when(() => mockUploadUseCase(sessionId: sessionId, file: file, budget: any(named: 'budget')))
            .thenThrow(error);
      }

      blocTest<SyncSessionBloc, SyncSessionState>(
        'should skip a file that does not fit and back up the rest',
        setUp: () {
          givenPendingFiles([big, tooBig, small]);
          givenUploadFails(tooBig, const FileDoesNotFitFailure(81 * testMib));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        wait: const Duration(seconds: 9),
        expect: () => [
          const SyncSessionStarting(),
          const SyncSessionFetchingFiles(),
          isA<SyncSessionUploading>()
              .having((state) => state.freeBytes, 'freeBytes', 150 * testMib)
              .having((state) => state.exceedsFreeSpace, 'exceedsFreeSpace', isTrue),
          isA<SyncSessionUploading>().having((state) => state.currentFileName, 'file', 'big.jpg'),
          isA<SyncSessionUploading>().having((state) => state.currentFileName, 'file', 'small.jpg'),
          const SyncSessionCompleting(),
          isA<SyncSessionSuccess>()
              .having((state) => state.skippedForSpace, 'skippedForSpace', 1)
              .having((state) => state.skippedForSpaceBytes, 'skippedForSpaceBytes', 81 * testMib)
              .having((state) => state.skippedLargeVideos, 'skippedLargeVideos', 0),
        ],
        verify: (_) {
          verify(() => mockUploadUseCase(sessionId: sessionId, file: small, budget: any(named: 'budget'))).called(1);
          verifyNever(() => mockSessionRepository.cancelSyncSession(sessionId: any(named: 'sessionId')));
          final event = verify(() => mockAppEventLog.record(captureAny())).captured.single as SyncStorageFull;
          expect(event.name, 'SYNC_STORAGE_FULL');
          expect(event.message, 'background=false files=1 bytes=${81 * testMib}');
          // The file that did not fit is tried again by the next backup
          final remembered = verify(() => completeBackupScan(captureAny(), captureAny())).captured;
          expect((remembered[0] as BackupScan).startedAt, scanStartedAt);
          expect(remembered[1], {'local-too-big'});
        },
      );

      group('albums of the gallery', () {
        const vacaciones = LocalAlbum(localAlbumId: 'bucket-vacaciones', name: 'Vacaciones 2025',
            mode: LocalAlbumMode.album);
        const memes = LocalAlbum(localAlbumId: 'bucket-memes', name: 'Memes', mode: LocalAlbumMode.excluded);
        const camera = LocalAlbum(localAlbumId: 'bucket-camera', name: 'Camera', mode: LocalAlbumMode.backupOnly);
        const linked = LocalAlbum(localAlbumId: 'bucket-verano', name: 'Verano', mode: LocalAlbumMode.album,
            folderId: '7');

        blocTest<SyncSessionBloc, SyncSessionState>(
          'should leave out the files of the albums the user chose not to back up',
          setUp: () {
            givenPendingFiles([big.inAlbum('bucket-memes'), small.inAlbum('bucket-camera')]);
            when(() => registerLocalAlbums()).thenAnswer((_) async => [memes, camera]);
          },
          build: buildBloc,
          act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
          wait: const Duration(seconds: 10),
          verify: (_) {
            final hashes = verify(() => mockCheckDuplicatesUseCase(
                sessionId: sessionId, fileHashes: captureAny(named: 'fileHashes'))).captured.single;
            expect(hashes, ['small']);
            verifyNever(() => mockUploadUseCase(
                sessionId: sessionId, file: big.inAlbum('bucket-memes'), budget: any(named: 'budget')));
            // A file of an album not backed up is not pending either
            expect(verify(() => completeBackupScan(any(), captureAny())).captured.single, isEmpty);
          },
        );

        blocTest<SyncSessionBloc, SyncSessionState>(
          'should say which albums got their album of Photo Manager in this backup',
          setUp: () {
            givenPendingFiles([big.inAlbum('bucket-vacaciones'), small.inAlbum('bucket-verano')]);
            when(() => registerLocalAlbums()).thenAnswer((_) async => [vacaciones, linked]);
          },
          build: buildBloc,
          act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
          wait: const Duration(seconds: 10),
          skip: 6,
          expect: () => [
            isA<SyncSessionSuccess>().having((state) => state.createdAlbums, 'createdAlbums', ['Vacaciones 2025']),
          ],
        );

        blocTest<SyncSessionBloc, SyncSessionState>(
          'should not back up anything when the albums cannot be registered',
          setUp: () {
            givenPendingFiles([small]);
            when(() => registerLocalAlbums()).thenThrow(Exception('Network error'));
          },
          build: buildBloc,
          act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
          wait: const Duration(seconds: 5),
          verify: (_) {
            verifyNever(() => mockUploadUseCase(
                sessionId: any(named: 'sessionId'), file: any(named: 'file'), budget: any(named: 'budget')));
            verify(() => mockSessionRepository.cancelSyncSession(sessionId: sessionId)).called(1);
          },
        );
      });

      blocTest<SyncSessionBloc, SyncSessionState>(
        'should remember nothing when the backup fails, so the next one looks at the same files again',
        setUp: () {
          givenPendingFiles([big, small]);
          givenUploadFails(big, Exception('Network error'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        wait: const Duration(seconds: 6),
        verify: (_) {
          verify(() => mockSessionRepository.cancelSyncSession(sessionId: sessionId)).called(1);
          verifyNever(() => completeBackupScan(any(), any()));
        },
      );

      blocTest<SyncSessionBloc, SyncSessionState>(
        'should read the plan again and go on when the server has no space left',
        setUp: () {
          givenPendingFiles([big, small]);
          givenUploadFails(big, ApiException(ErrorResponseModel(
              code: FailureCodes.userDoesNotHaveStorageSpace, message: 'No space', timestamp: '2026-10-21T10:00:00')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        wait: const Duration(seconds: 9),
        expect: () => [
          const SyncSessionStarting(),
          const SyncSessionFetchingFiles(),
          isA<SyncSessionUploading>().having((state) => state.exceedsFreeSpace, 'exceedsFreeSpace', isFalse),
          isA<SyncSessionUploading>().having((state) => state.currentFileName, 'file', 'small.jpg'),
          const SyncSessionCompleting(),
          isA<SyncSessionSuccess>()
              .having((state) => state.skippedForSpace, 'skippedForSpace', 1)
              .having((state) => state.skippedForSpaceBytes, 'skippedForSpaceBytes', 100 * testMib),
        ],
        verify: (_) {
          // Once when the backup starts and once after the rejection
          verify(() => mockGetUserPlan()).called(2);
          verifyNever(() => mockSessionRepository.cancelSyncSession(sessionId: any(named: 'sessionId')));
        },
      );

      blocTest<SyncSessionBloc, SyncSessionState>(
        'should not warn when every pending file fits',
        setUp: () => givenPendingFiles([small]),
        build: buildBloc,
        verify: (_) => verifyNever(() => mockAppEventLog.record(any())),
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        wait: const Duration(seconds: 9),
        expect: () => [
          const SyncSessionStarting(),
          const SyncSessionFetchingFiles(),
          isA<SyncSessionUploading>().having((state) => state.exceedsFreeSpace, 'exceedsFreeSpace', isFalse),
          isA<SyncSessionUploading>(),
          const SyncSessionCompleting(),
          isA<SyncSessionSuccess>().having((state) => state.skippedForSpace, 'skippedForSpace', 0),
        ],
      );

      blocTest<SyncSessionBloc, SyncSessionState>(
        'should not limit the backup when the plan cannot be read',
        setUp: () {
          givenPendingFiles([big, tooBig, small]);
          when(() => mockGetUserPlan()).thenThrow(Exception('offline'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(SyncSessionStarted(mockContext)),
        wait: const Duration(seconds: 9),
        expect: () => [
          const SyncSessionStarting(),
          const SyncSessionFetchingFiles(),
          isA<SyncSessionUploading>()
              .having((state) => state.freeBytes, 'freeBytes', isNull)
              .having((state) => state.exceedsFreeSpace, 'exceedsFreeSpace', isFalse),
          isA<SyncSessionUploading>(),
          isA<SyncSessionUploading>(),
          isA<SyncSessionUploading>(),
          const SyncSessionCompleting(),
          isA<SyncSessionSuccess>(),
        ],
      );
    });

    group('SyncSessionUploading', () {
      test('should not know the bytes left by default', () {
        expect(const SyncSessionUploading(uploadCount: 0, totalCount: 2).remainingBytes, 0);
      });

      test('should tell states apart by the bytes left', () {
        expect(
          const SyncSessionUploading(uploadCount: 1, totalCount: 2, remainingBytes: 10),
          isNot(const SyncSessionUploading(uploadCount: 1, totalCount: 2, remainingBytes: 5)),
        );
      });

      test('should tell states apart by the free space warning', () {
        expect(
          const SyncSessionUploading(uploadCount: 0, totalCount: 2, freeBytes: 10, exceedsFreeSpace: true),
          isNot(const SyncSessionUploading(uploadCount: 0, totalCount: 2, freeBytes: 10)),
        );
      });
    });
  });
}
