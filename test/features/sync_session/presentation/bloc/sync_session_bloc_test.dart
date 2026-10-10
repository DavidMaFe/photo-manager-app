import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/core/services/sync_lock.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/media_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_session.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/check_duplicated_files_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/complete_sync_session_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/start_sync_session_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/upload_file_use_case.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_bloc.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_event.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_state.dart';

class MockStartSyncSessionUseCase extends Mock implements StartSyncSessionUseCase {}
class MockCheckDuplicatedFilesUseCase extends Mock implements CheckDuplicatedFilesUseCase {}
class MockUploadFileUseCase extends Mock implements UploadFileUseCase {}
class MockCompleteSyncSessionUseCase extends Mock implements CompleteSyncSessionUseCase {}
class MockSyncDeviceRepository extends Mock implements SyncDeviceRepository {}
class MockSyncSessionRepository extends Mock implements SyncSessionRepository {}
class MockMediaLocalDataSource extends Mock implements MediaLocalDataSource {}
class MockAppEventBus extends Mock implements AppEventBus {}
class MockBuildContext extends Mock implements BuildContext {}
class MockSyncLock extends Mock implements SyncLock {}

class FakeAppEvent extends Fake implements AppEvent {}

void main() {
  late SyncSessionBloc bloc;
  late MockStartSyncSessionUseCase mockStartUseCase;
  late MockCheckDuplicatedFilesUseCase mockCheckDuplicatesUseCase;
  late MockUploadFileUseCase mockUploadUseCase;
  late MockCompleteSyncSessionUseCase mockCompleteUseCase;
  late MockSyncDeviceRepository mockDeviceRepository;
  late MockSyncSessionRepository mockSessionRepository;
  late MockMediaLocalDataSource mockMediaDataSource;
  late MockAppEventBus mockEventBus;
  late MockBuildContext mockContext;
  late MockSyncLock mockSyncLock;

  setUpAll(() {
    registerFallbackValue(FakeAppEvent());
  });

  setUp(() {
    mockStartUseCase = MockStartSyncSessionUseCase();
    mockCheckDuplicatesUseCase = MockCheckDuplicatedFilesUseCase();
    mockUploadUseCase = MockUploadFileUseCase();
    mockCompleteUseCase = MockCompleteSyncSessionUseCase();
    mockDeviceRepository = MockSyncDeviceRepository();
    mockSessionRepository = MockSyncSessionRepository();
    mockMediaDataSource = MockMediaLocalDataSource();
    mockEventBus = MockAppEventBus();
    mockContext = MockBuildContext();
    mockSyncLock = MockSyncLock();

    // Mock context.mounted to return true
    when(() => mockContext.mounted).thenReturn(true);

    // Mock cancelSyncSession to prevent errors
    when(() => mockSessionRepository.cancelSyncSession(sessionId: any(named: 'sessionId')))
        .thenAnswer((_) async => {});

    // No sync in progress by default
    when(() => mockSyncLock.check()).thenAnswer((_) async => const SyncLockCheck(SyncLockStatus.free));
    when(() => mockSyncLock.acquire()).thenAnswer((_) async {});
    when(() => mockSyncLock.release()).thenAnswer((_) async {});

    bloc = SyncSessionBloc(
      startSyncSessionUseCase: mockStartUseCase,
      checkDuplicatedFilesUseCase: mockCheckDuplicatesUseCase,
      uploadFileUseCase: mockUploadUseCase,
      completeSyncSessionUseCase: mockCompleteUseCase,
      syncDeviceRepository: mockDeviceRepository,
      syncSessionRepository: mockSessionRepository,
      mediaLocalDataSource: mockMediaDataSource,
      eventBus: mockEventBus,
      syncLock: mockSyncLock,
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

    group('SyncSessionReset', () {
      blocTest<SyncSessionBloc, SyncSessionState>(
        'emits starting state',
        build: () => bloc,
        act: (bloc) => bloc.add(const SyncSessionReset()),
        expect: () => [const SyncSessionStarting()],
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
    });
  });
}
