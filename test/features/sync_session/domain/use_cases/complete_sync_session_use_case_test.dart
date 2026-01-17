import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/complete_sync_session_use_case.dart';

class MockSyncSessionRepository extends Mock implements SyncSessionRepository {}

void main() {
  late CompleteSyncSessionUseCase useCase;
  late MockSyncSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSyncSessionRepository();
    useCase = CompleteSyncSessionUseCase(mockRepository);
  });

  group('CompleteSyncSessionUseCase', () {
    const sessionId = 'session_123';
    final syncResult = SyncResult(
      totalFiles: 100,
      uploadedFiles: 95,
      failedFiles: 5,
    );

    test('should call repository with correct session ID', () async {
      // Arrange
      when(() => mockRepository.completeSyncSession(sessionId: any(named: 'sessionId')))
          .thenAnswer((_) async => syncResult);

      // Act
      await useCase(sessionId: sessionId);

      // Assert
      verify(() => mockRepository.completeSyncSession(sessionId: sessionId)).called(1);
    });

    test('should return sync result from repository', () async {
      // Arrange
      when(() => mockRepository.completeSyncSession(sessionId: any(named: 'sessionId')))
          .thenAnswer((_) async => syncResult);

      // Act
      final result = await useCase(sessionId: sessionId);

      // Assert
      expect(result, syncResult);
      expect(result.totalFiles, 100);
      expect(result.uploadedFiles, 95);
      expect(result.failedFiles, 5);
    });

    test('should trim session ID before calling repository', () async {
      // Arrange
      when(() => mockRepository.completeSyncSession(sessionId: any(named: 'sessionId')))
          .thenAnswer((_) async => syncResult);

      // Act
      await useCase(sessionId: '  $sessionId  ');

      // Assert
      verify(() => mockRepository.completeSyncSession(sessionId: sessionId)).called(1);
    });

    test('should throw exception when session ID is empty', () async {
      // Act & Assert
      expect(
        () => useCase(sessionId: ''),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid Sync Session ID'),
        )),
      );

      verifyNever(() => mockRepository.completeSyncSession(sessionId: any(named: 'sessionId')));
    });

    test('should throw exception when session ID is only whitespace', () async {
      // Act & Assert
      expect(
        () => useCase(sessionId: '   '),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid Sync Session ID'),
        )),
      );

      verifyNever(() => mockRepository.completeSyncSession(sessionId: any(named: 'sessionId')));
    });

    test('should propagate exception from repository', () async {
      // Arrange
      when(() => mockRepository.completeSyncSession(sessionId: any(named: 'sessionId')))
          .thenThrow(Exception('Session not found'));

      // Act & Assert
      expect(
        () => useCase(sessionId: sessionId),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Session not found'),
        )),
      );
    });

    test('should handle completion with partial uploads', () async {
      // Arrange
      final partialResult = SyncResult(
        totalFiles: 50,
        uploadedFiles: 30,
        failedFiles: 20,
      );
      when(() => mockRepository.completeSyncSession(sessionId: any(named: 'sessionId')))
          .thenAnswer((_) async => partialResult);

      // Act
      final result = await useCase(sessionId: sessionId);

      // Assert
      expect(result.uploadedFiles, 30);
      expect(result.failedFiles, 20);
      expect(result.hasFailures, true);
    });

    test('should handle completion with all uploads successful', () async {
      // Arrange
      final successResult = SyncResult(
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );
      when(() => mockRepository.completeSyncSession(sessionId: any(named: 'sessionId')))
          .thenAnswer((_) async => successResult);

      // Act
      final result = await useCase(sessionId: sessionId);

      // Assert
      expect(result.isSuccess, true);
      expect(result.hasFailures, false);
    });

    test('should handle completion with no uploads', () async {
      // Arrange
      final emptyResult = SyncResult.empty('session_123');
      when(() => mockRepository.completeSyncSession(sessionId: any(named: 'sessionId')))
          .thenAnswer((_) async => emptyResult);

      // Act
      final result = await useCase(sessionId: sessionId);

      // Assert
      expect(result.isEmpty, true);
      expect(result.uploadedFiles, 0);
    });
  });
}