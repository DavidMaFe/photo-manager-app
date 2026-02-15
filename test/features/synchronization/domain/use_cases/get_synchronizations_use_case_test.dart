import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';
import 'package:photo_manager_app/features/synchronization/domain/repositories/synchronization_repository.dart';
import 'package:photo_manager_app/features/synchronization/domain/use_cases/get_synchronizations_use_case.dart';

class MockSynchronizationRepository extends Mock
    implements SynchronizationRepository {}

void main() {
  late GetSynchronizationsUseCase useCase;
  late MockSynchronizationRepository mockRepository;

  setUp(() {
    mockRepository = MockSynchronizationRepository();
    useCase = GetSynchronizationsUseCase(mockRepository);
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

  group('GetSynchronizationsUseCase', () {
    const testDeviceUuid = 'device-uuid-123';

    test('should call repository with correct parameters', () async {
      // Arrange
      when(() => mockRepository.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResult);

      // Act
      await useCase.call(deviceUuid: testDeviceUuid);

      // Assert
      verify(() => mockRepository.getSynchronizations(
            deviceUuid: testDeviceUuid,
            page: 0,
            pageSize: 20,
          )).called(1);
    });

    test('should return SynchronizationResult from repository', () async {
      // Arrange
      when(() => mockRepository.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResult);

      // Act
      final result = await useCase.call(deviceUuid: testDeviceUuid);

      // Assert
      expect(result, testResult);
      expect(result.sessions.length, 2);
      expect(result.hasNext, true);
    });

    test('should call repository with custom page', () async {
      // Arrange
      when(() => mockRepository.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResult);

      // Act
      await useCase.call(deviceUuid: testDeviceUuid, page: 2);

      // Assert
      verify(() => mockRepository.getSynchronizations(
            deviceUuid: testDeviceUuid,
            page: 2,
            pageSize: 20,
          )).called(1);
    });

    test('should call repository with custom pageSize', () async {
      // Arrange
      when(() => mockRepository.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResult);

      // Act
      await useCase.call(deviceUuid: testDeviceUuid, pageSize: 50);

      // Assert
      verify(() => mockRepository.getSynchronizations(
            deviceUuid: testDeviceUuid,
            page: 0,
            pageSize: 50,
          )).called(1);
    });

    test('should handle empty result', () async {
      // Arrange
      const emptyResult = SynchronizationResult(
        sessions: [],
        hasNext: false,
      );

      when(() => mockRepository.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => emptyResult);

      // Act
      final result = await useCase.call(deviceUuid: testDeviceUuid);

      // Assert
      expect(result.sessions, isEmpty);
      expect(result.hasNext, false);
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.call(deviceUuid: testDeviceUuid),
        throwsException,
      );
    });

    test('should handle large page number', () async {
      // Arrange
      when(() => mockRepository.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResult);

      // Act
      await useCase.call(deviceUuid: testDeviceUuid, page: 999);

      // Assert
      verify(() => mockRepository.getSynchronizations(
            deviceUuid: testDeviceUuid,
            page: 999,
            pageSize: 20,
          )).called(1);
    });

    test('should handle large page size', () async {
      // Arrange
      when(() => mockRepository.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResult);

      // Act
      await useCase.call(deviceUuid: testDeviceUuid, pageSize: 100);

      // Assert
      verify(() => mockRepository.getSynchronizations(
            deviceUuid: testDeviceUuid,
            page: 0,
            pageSize: 100,
          )).called(1);
    });

    test('should call repository with all custom parameters', () async {
      // Arrange
      when(() => mockRepository.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResult);

      // Act
      await useCase.call(
        deviceUuid: testDeviceUuid,
        page: 5,
        pageSize: 50,
      );

      // Assert
      verify(() => mockRepository.getSynchronizations(
            deviceUuid: testDeviceUuid,
            page: 5,
            pageSize: 50,
          )).called(1);
    });

    test('should handle special characters in deviceUuid', () async {
      // Arrange
      const specialUuid = 'device-@#\$%-uuid';

      when(() => mockRepository.getSynchronizations(
            deviceUuid: any(named: 'deviceUuid'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testResult);

      // Act
      await useCase.call(deviceUuid: specialUuid);

      // Assert
      verify(() => mockRepository.getSynchronizations(
            deviceUuid: specialUuid,
            page: 0,
            pageSize: 20,
          )).called(1);
    });
  });
}
