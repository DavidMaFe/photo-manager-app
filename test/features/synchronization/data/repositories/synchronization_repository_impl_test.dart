import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/synchronization/data/data_sources/synchronization_remote_data_source.dart';
import 'package:photo_manager_app/features/synchronization/data/models/synchronization_model.dart';
import 'package:photo_manager_app/features/synchronization/data/repositories/synchronization_repository_impl.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';
import 'package:photo_manager_app/features/synchronization/domain/repositories/synchronization_repository.dart';

class MockSynchronizationRemoteDataSource extends Mock
    implements SynchronizationRemoteDataSource {}

void main() {
  late SynchronizationRepositoryImpl repository;
  late MockSynchronizationRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockSynchronizationRemoteDataSource();
    repository = SynchronizationRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  final testDate = DateTime(2024, 1, 15);

  final testSyncSessions = [
    SynchronizationModel(
      id: 'sync-1',
      startedAt: testDate,
      status: SynchronizationStatus.completed,
      totalFiles: 100,
      uploadedFiles: 100,
      failedFiles: 0,
    ),
    SynchronizationModel(
      id: 'sync-2',
      startedAt: testDate.subtract(const Duration(days: 1)),
      status: SynchronizationStatus.failed,
      totalFiles: 50,
      uploadedFiles: 30,
      failedFiles: 20,
    ),
  ];

  final testResponse = SynchronizationsListResponse(
    syncSessions: testSyncSessions,
    hasNext: true,
  );

  group('SynchronizationRepositoryImpl - getSynchronizations', () {
    const testDeviceUuid = 'device-uuid-123';

    test('should call remote data source with correct parameters', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResponse);

      // Act
      await repository.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 20,
      );

      // Assert
      verify(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: testDeviceUuid,
            page: 0,
            pageSize: 20,
          )).called(1);
    });

    test('should return SynchronizationResult from data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResponse);

      // Act
      final result = await repository.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 20,
      );

      // Assert
      expect(result, isA<SynchronizationResult>());
      expect(result.sessions.length, 2);
      expect(result.hasNext, true);
    });

    test('should convert data source response to domain result', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResponse);

      // Act
      final result = await repository.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 20,
      );

      // Assert
      expect(result.sessions[0].id, 'sync-1');
      expect(result.sessions[0].status, SynchronizationStatus.completed);
      expect(result.sessions[1].id, 'sync-2');
      expect(result.sessions[1].status, SynchronizationStatus.failed);
    });

    test('should handle different page numbers', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResponse);

      // Act
      await repository.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 3,
        pageSize: 20,
      );

      // Assert
      verify(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: testDeviceUuid,
            page: 3,
            pageSize: 20,
          )).called(1);
    });

    test('should handle different page sizes', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResponse);

      // Act
      await repository.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 50,
      );

      // Assert
      verify(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: testDeviceUuid,
            page: 0,
            pageSize: 50,
          )).called(1);
    });

    test('should handle empty result', () async {
      // Arrange
      const emptyResponse = SynchronizationsListResponse(
        syncSessions: [],
        hasNext: false,
      );

      when(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => emptyResponse);

      // Act
      final result = await repository.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 20,
      );

      // Assert
      expect(result.sessions, isEmpty);
      expect(result.hasNext, false);
    });

    test('should propagate errors from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.getSynchronizations(
          deviceUuid: testDeviceUuid,
          page: 0,
          pageSize: 20,
        ),
        throwsException,
      );
    });

    test('should handle single sync session', () async {
      // Arrange
      final singleResponse = SynchronizationsListResponse(
        syncSessions: [testSyncSessions.first],
        hasNext: false,
      );

      when(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => singleResponse);

      // Act
      final result = await repository.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 20,
      );

      // Assert
      expect(result.sessions.length, 1);
    });

    test('should handle large page number', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResponse);

      // Act
      await repository.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 999,
        pageSize: 20,
      );

      // Assert
      verify(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: testDeviceUuid,
            page: 999,
            pageSize: 20,
          )).called(1);
    });

    test('should handle large page size', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResponse);

      // Act
      await repository.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 100,
      );

      // Assert
      verify(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: testDeviceUuid,
            page: 0,
            pageSize: 100,
          )).called(1);
    });

    test('should call data source only once per request', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResponse);

      // Act
      await repository.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 20,
      );

      // Assert
      verify(() => mockRemoteDataSource.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).called(1);
    });
  });
}
