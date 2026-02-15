import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';
import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';
import 'package:photo_manager_app/features/synchronization/domain/repositories/synchronization_repository.dart';
import 'package:photo_manager_app/features/synchronization/domain/use_cases/get_synchronizations_use_case.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_bloc.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_event.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_state.dart';

class MockGetSynchronizationsUseCase extends Mock
    implements GetSynchronizationsUseCase {}

class MockSyncDeviceRepository extends Mock implements SyncDeviceRepository {}

class MockAppEventBus extends Mock implements AppEventBus {}

void main() {
  late SynchronizationBloc bloc;
  late MockGetSynchronizationsUseCase mockGetSynchronizationsUseCase;
  late MockSyncDeviceRepository mockSyncDeviceRepository;
  late MockAppEventBus mockEventBus;

  const testDeviceUuid = 'test-device-uuid';

  setUp(() {
    mockGetSynchronizationsUseCase = MockGetSynchronizationsUseCase();
    mockSyncDeviceRepository = MockSyncDeviceRepository();
    mockEventBus = MockAppEventBus();

    when(() => mockSyncDeviceRepository.getDeviceUuid())
        .thenAnswer((_) async => testDeviceUuid);

    when(() => mockEventBus.on<SyncCompletedEvent>())
        .thenAnswer((_) => const Stream.empty());

    bloc = SynchronizationBloc(
      getSynchronizationsUseCase: mockGetSynchronizationsUseCase,
      syncDeviceRepository: mockSyncDeviceRepository,
      eventBus: mockEventBus,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final testDate = DateTime(2024, 1, 15);

  final testSynchronizations = [
    Synchronization(
      id: 'sync-1',
      startedAt: testDate,
      status: SynchronizationStatus.completed,
      totalFiles: 100,
      uploadedFiles: 100,
      failedFiles: 0,
    ),
    Synchronization(
      id: 'sync-2',
      startedAt: testDate.subtract(const Duration(days: 1)),
      status: SynchronizationStatus.failed,
      totalFiles: 50,
      uploadedFiles: 30,
      failedFiles: 20,
    ),
  ];

  final testResult = SynchronizationResult(
    sessions: testSynchronizations,
    hasNext: true,
  );

  group('SynchronizationBloc', () {
    test('initial state should be SynchronizationStarting', () {
      expect(bloc.state, const SynchronizationStarting());
    });

    group('LoadSynchronizations', () {
      blocTest<SynchronizationBloc, SynchronizationState>(
        'should emit [SynchronizationsLoading, SynchronizationsLoaded] when successful',
        build: () {
          when(() => mockGetSynchronizationsUseCase(
                deviceUuid: any(named: 'deviceUuid'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenAnswer((_) async => testResult);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadSynchronizations()),
        expect: () => [
          const SynchronizationsLoading(),
          SynchronizationsLoaded(
            sessions: testSynchronizations,
            hasMore: true,
            currentPage: 0,
          ),
        ],
      );

      blocTest<SynchronizationBloc, SynchronizationState>(
        'should call getDeviceUuid from repository',
        build: () {
          when(() => mockGetSynchronizationsUseCase(
                deviceUuid: any(named: 'deviceUuid'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenAnswer((_) async => testResult);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadSynchronizations()),
        verify: (_) {
          verify(() => mockSyncDeviceRepository.getDeviceUuid()).called(1);
        },
      );

      blocTest<SynchronizationBloc, SynchronizationState>(
        'should call use case with correct parameters',
        build: () {
          when(() => mockGetSynchronizationsUseCase(
                deviceUuid: any(named: 'deviceUuid'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenAnswer((_) async => testResult);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadSynchronizations()),
        verify: (_) {
          verify(() => mockGetSynchronizationsUseCase(
                deviceUuid: testDeviceUuid,
                page: 0,
              )).called(1);
        },
      );

      blocTest<SynchronizationBloc, SynchronizationState>(
        'should emit [SynchronizationsLoading, SynchronizationError] when fails',
        build: () {
          when(() => mockGetSynchronizationsUseCase(
                deviceUuid: any(named: 'deviceUuid'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenThrow(Exception('Network error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadSynchronizations()),
        expect: () => [
          const SynchronizationsLoading(),
          isA<SynchronizationError>(),
        ],
      );

      blocTest<SynchronizationBloc, SynchronizationState>(
        'should handle empty result',
        build: () {
          const emptyResult = SynchronizationResult(
            sessions: [],
            hasNext: false,
          );
          when(() => mockGetSynchronizationsUseCase(
                deviceUuid: any(named: 'deviceUuid'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenAnswer((_) async => emptyResult);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadSynchronizations()),
        expect: () => [
          const SynchronizationsLoading(),
          const SynchronizationsLoaded(
            sessions: [],
            hasMore: false,
            currentPage: 0,
          ),
        ],
      );
    });

    group('LoadMoreSynchronizations', () {
      blocTest<SynchronizationBloc, SynchronizationState>(
        'should load more synchronizations when in loaded state with hasMore',
        build: () {
          when(() => mockGetSynchronizationsUseCase(
                deviceUuid: any(named: 'deviceUuid'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenAnswer((_) async => testResult);
          return bloc;
        },
        seed: () => SynchronizationsLoaded(
          sessions: [testSynchronizations.first],
          hasMore: true,
          currentPage: 0,
        ),
        act: (bloc) => bloc.add(const LoadMoreSynchronizations()),
        expect: () => [
          SynchronizationsLoaded(
            sessions: [testSynchronizations.first],
            hasMore: true,
            currentPage: 0,
            isLoadingMore: true,
          ),
          SynchronizationsLoaded(
            sessions: [
              testSynchronizations.first,
              ...testSynchronizations,
            ],
            hasMore: true,
            currentPage: 1,
            isLoadingMore: false,
          ),
        ],
      );

      blocTest<SynchronizationBloc, SynchronizationState>(
        'should call use case with next page number',
        build: () {
          when(() => mockGetSynchronizationsUseCase(
                deviceUuid: any(named: 'deviceUuid'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenAnswer((_) async => testResult);
          return bloc;
        },
        seed: () => SynchronizationsLoaded(
          sessions: [testSynchronizations.first],
          hasMore: true,
          currentPage: 0,
        ),
        act: (bloc) => bloc.add(const LoadMoreSynchronizations()),
        verify: (_) {
          verify(() => mockGetSynchronizationsUseCase(
                deviceUuid: any(named: 'deviceUuid'),
                page: 1,
                pageSize: 20,
              )).called(1);
        },
      );

      blocTest<SynchronizationBloc, SynchronizationState>(
        'should not load more when hasMore is false',
        build: () => bloc,
        seed: () => SynchronizationsLoaded(
          sessions: testSynchronizations,
          hasMore: false,
          currentPage: 0,
        ),
        act: (bloc) => bloc.add(const LoadMoreSynchronizations()),
        expect: () => [],
      );

      blocTest<SynchronizationBloc, SynchronizationState>(
        'should not load more when state is not SynchronizationsLoaded',
        build: () => bloc,
        seed: () => const SynchronizationsLoading(),
        act: (bloc) => bloc.add(const LoadMoreSynchronizations()),
        expect: () => [],
      );

      blocTest<SynchronizationBloc, SynchronizationState>(
        'should not load more when already loading more',
        build: () => bloc,
        seed: () => SynchronizationsLoaded(
          sessions: testSynchronizations,
          hasMore: true,
          currentPage: 0,
          isLoadingMore: true,
        ),
        act: (bloc) => bloc.add(const LoadMoreSynchronizations()),
        expect: () => [],
      );

      blocTest<SynchronizationBloc, SynchronizationState>(
        'should maintain previous sessions on error',
        build: () {
          when(() => mockGetSynchronizationsUseCase(
                deviceUuid: any(named: 'deviceUuid'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenThrow(Exception('Network error'));
          return bloc;
        },
        seed: () => SynchronizationsLoaded(
          sessions: [testSynchronizations.first],
          hasMore: true,
          currentPage: 0,
        ),
        act: (bloc) => bloc.add(const LoadMoreSynchronizations()),
        expect: () => [
          SynchronizationsLoaded(
            sessions: [testSynchronizations.first],
            hasMore: true,
            currentPage: 0,
            isLoadingMore: true,
          ),
          SynchronizationsLoaded(
            sessions: [testSynchronizations.first],
            hasMore: true,
            currentPage: 0,
            isLoadingMore: false,
          ),
        ],
      );
    });

    group('RefreshSynchronizations', () {
      blocTest<SynchronizationBloc, SynchronizationState>(
        'should refresh synchronizations from page 0',
        build: () {
          when(() => mockGetSynchronizationsUseCase(
                deviceUuid: any(named: 'deviceUuid'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenAnswer((_) async => testResult);
          return bloc;
        },
        seed: () => SynchronizationsLoaded(
          sessions: [testSynchronizations.first],
          hasMore: true,
          currentPage: 2,
        ),
        act: (bloc) => bloc.add(const RefreshSynchronizations()),
        expect: () => [
          SynchronizationsLoaded(
            sessions: testSynchronizations,
            hasMore: true,
            currentPage: 0,
          ),
        ],
      );

      blocTest<SynchronizationBloc, SynchronizationState>(
        'should call use case with page 0',
        build: () {
          when(() => mockGetSynchronizationsUseCase(
                deviceUuid: any(named: 'deviceUuid'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenAnswer((_) async => testResult);
          return bloc;
        },
        seed: () => SynchronizationsLoaded(
          sessions: [testSynchronizations.first],
          hasMore: true,
          currentPage: 5,
        ),
        act: (bloc) => bloc.add(const RefreshSynchronizations()),
        verify: (_) {
          verify(() => mockGetSynchronizationsUseCase(
                deviceUuid: any(named: 'deviceUuid'),
                page: 0,
                pageSize: 20,
              )).called(1);
        },
      );

      blocTest<SynchronizationBloc, SynchronizationState>(
        'should emit error when refresh fails',
        build: () {
          when(() => mockGetSynchronizationsUseCase(
                deviceUuid: any(named: 'deviceUuid'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenThrow(Exception('Network error'));
          return bloc;
        },
        seed: () => SynchronizationsLoaded(
          sessions: [testSynchronizations.first],
          hasMore: true,
          currentPage: 0,
        ),
        act: (bloc) => bloc.add(const RefreshSynchronizations()),
        expect: () => [
          isA<SynchronizationError>(),
        ],
      );

      blocTest<SynchronizationBloc, SynchronizationState>(
        'should use stored deviceUuid from LoadSynchronizations',
        build: () {
          when(() => mockGetSynchronizationsUseCase(
                deviceUuid: any(named: 'deviceUuid'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              )).thenAnswer((_) async => testResult);
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const LoadSynchronizations());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const RefreshSynchronizations());
        },
        skip: 2,
        verify: (_) {
          verify(() => mockGetSynchronizationsUseCase(
                deviceUuid: testDeviceUuid,
                page: 0,
                pageSize: 20,
              )).called(2);
        },
      );
    });

    group('Event Bus Integration', () {
      test('should listen to SyncCompletedEvent on creation', () {
        verify(() => mockEventBus.on<SyncCompletedEvent>()).called(1);
      });
    });
  });
}
