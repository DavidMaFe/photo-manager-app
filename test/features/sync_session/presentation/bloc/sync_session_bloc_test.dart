import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/media_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';
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

    bloc = SyncSessionBloc(
      startSyncSessionUseCase: mockStartUseCase,
      checkDuplicatedFilesUseCase: mockCheckDuplicatesUseCase,
      uploadFileUseCase: mockUploadUseCase,
      completeSyncSessionUseCase: mockCompleteUseCase,
      syncDeviceRepository: mockDeviceRepository,
      syncSessionRepository: mockSessionRepository,
      mediaLocalDataSource: mockMediaDataSource,
      eventBus: mockEventBus,
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
      const sessionId = 'session-123';
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
        act: (bloc) => bloc.add(const SyncSessionStarted()),
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
      );

      blocTest<SyncSessionBloc, SyncSessionState>(
        'emits error when permission denied',
        setUp: () {
          when(() => mockDeviceRepository.getDeviceUuid()).thenAnswer((_) async => deviceUuid);
          when(() => mockStartUseCase(deviceUuid: deviceUuid)).thenAnswer((_) async => session);
          when(() => mockMediaDataSource.requestPermission()).thenAnswer((_) async => false);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const SyncSessionStarted()),
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
      );

      blocTest<SyncSessionBloc, SyncSessionState>(
        'emits error when start session fails',
        setUp: () {
          when(() => mockDeviceRepository.getDeviceUuid()).thenAnswer((_) async => deviceUuid);
          when(() => mockStartUseCase(deviceUuid: deviceUuid)).thenThrow(Exception('Network error'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const SyncSessionStarted()),
        expect: () => [
          const SyncSessionStarting(),
          isA<SyncSessionError>(),
        ],
        verify: (_) {
          verify(() => mockStartUseCase(deviceUuid: deviceUuid)).called(1);
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
  });
}
