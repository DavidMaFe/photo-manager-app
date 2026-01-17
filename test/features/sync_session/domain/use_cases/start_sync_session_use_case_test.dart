import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_session.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/start_sync_session_use_case.dart';

class MockSyncSessionRepository extends Mock implements SyncSessionRepository {}

void main() {
  late StartSyncSessionUseCase useCase;
  late MockSyncSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSyncSessionRepository();
    useCase = StartSyncSessionUseCase(mockRepository);
  });

  group('StartSyncSessionUseCase', () {
    const deviceUuid = 'device_uuid_123';
    final syncSession = SyncSession(
      id: 'session_123',
      lastCompletedAt: DateTime(2024, 1, 15),
    );

    test('should call repository with correct device UUID', () async {
      // Arrange
      when(() => mockRepository.startSyncSession(deviceUuid: any(named: 'deviceUuid')))
          .thenAnswer((_) async => syncSession);

      // Act
      await useCase(deviceUuid: deviceUuid);

      // Assert
      verify(() => mockRepository.startSyncSession(deviceUuid: deviceUuid)).called(1);
    });

    test('should return sync session from repository', () async {
      // Arrange
      when(() => mockRepository.startSyncSession(deviceUuid: any(named: 'deviceUuid')))
          .thenAnswer((_) async => syncSession);

      // Act
      final result = await useCase(deviceUuid: deviceUuid);

      // Assert
      expect(result, syncSession);
      expect(result.id, 'session_123');
    });

    test('should trim device UUID before calling repository', () async {
      // Arrange
      when(() => mockRepository.startSyncSession(deviceUuid: any(named: 'deviceUuid')))
          .thenAnswer((_) async => syncSession);

      // Act
      await useCase(deviceUuid: '  $deviceUuid  ');

      // Assert
      verify(() => mockRepository.startSyncSession(deviceUuid: deviceUuid)).called(1);
    });

    test('should throw exception when device UUID is empty', () async {
      // Act & Assert
      expect(
        () => useCase(deviceUuid: ''),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid Device UUID'),
        )),
      );

      verifyNever(() => mockRepository.startSyncSession(deviceUuid: any(named: 'deviceUuid')));
    });

    test('should throw exception when device UUID is only whitespace', () async {
      // Act & Assert
      expect(
        () => useCase(deviceUuid: '   '),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid Device UUID'),
        )),
      );

      verifyNever(() => mockRepository.startSyncSession(deviceUuid: any(named: 'deviceUuid')));
    });

    test('should propagate exception from repository', () async {
      // Arrange
      when(() => mockRepository.startSyncSession(deviceUuid: any(named: 'deviceUuid')))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase(deviceUuid: deviceUuid),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Network error'),
        )),
      );
    });

    test('should handle repository returning session with null lastCompletedAt', () async {
      // Arrange
      final firstTimeSession = SyncSession(id: 'session_123', lastCompletedAt: null);
      when(() => mockRepository.startSyncSession(deviceUuid: any(named: 'deviceUuid')))
          .thenAnswer((_) async => firstTimeSession);

      // Act
      final result = await useCase(deviceUuid: deviceUuid);

      // Assert
      expect(result.id, 'session_123');
      expect(result.lastCompletedAt, null);
      expect(result.isFirstSync, true);
    });
  });
}