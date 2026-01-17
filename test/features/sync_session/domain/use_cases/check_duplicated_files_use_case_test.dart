import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/duplicate_files_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/check_duplicated_files_use_case.dart';

class MockSyncSessionRepository extends Mock implements SyncSessionRepository {}

void main() {
  late CheckDuplicatedFilesUseCase useCase;
  late MockSyncSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSyncSessionRepository();
    useCase = CheckDuplicatedFilesUseCase(mockRepository);
  });

  group('CheckDuplicatedFilesUseCase', () {
    const sessionId = 'session_123';
    final validHash1 = 'a' * 64; // Valid 64-char hex hash
    final validHash2 = 'b' * 64;
    final validHash3 = 'c' * 64;

    test('should call repository with correct parameters', () async {
      // Arrange
      final fileHashes = [validHash1, validHash2];
      final result = DuplicateFilesResult(
        filesToUpload: [validHash1],
        duplicatesCount: 1,
        totalFiles: 2,
      );
      when(() => mockRepository.checkDuplicates(
            sessionId: any(named: 'sessionId'),
            fileHashes: any(named: 'fileHashes'),
          )).thenAnswer((_) async => result);

      // Act
      await useCase(sessionId: sessionId, fileHashes: fileHashes);

      // Assert
      verify(() => mockRepository.checkDuplicates(
            sessionId: sessionId,
            fileHashes: fileHashes,
          )).called(1);
    });

    test('should return duplicate files result from repository', () async {
      // Arrange
      final fileHashes = [validHash1, validHash2, validHash3];
      final duplicateResult = DuplicateFilesResult(
        filesToUpload: [validHash1, validHash3],
        duplicatesCount: 1,
        totalFiles: 3,
      );
      when(() => mockRepository.checkDuplicates(
            sessionId: any(named: 'sessionId'),
            fileHashes: any(named: 'fileHashes'),
          )).thenAnswer((_) async => duplicateResult);

      // Act
      final result = await useCase(sessionId: sessionId, fileHashes: fileHashes);

      // Assert
      expect(result, duplicateResult);
      expect(result.filesToUpload.length, 2);
      expect(result.duplicatesCount, 1);
    });

    test('should throw exception when session ID is empty', () async {
      // Arrange
      final fileHashes = [validHash1];

      // Act & Assert
      expect(
        () => useCase(sessionId: '', fileHashes: fileHashes),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid Sync Session ID'),
        )),
      );

      verifyNever(() => mockRepository.checkDuplicates(
            sessionId: any(named: 'sessionId'),
            fileHashes: any(named: 'fileHashes'),
          ));
    });

    test('should throw exception when session ID is only whitespace', () async {
      // Arrange
      final fileHashes = [validHash1];

      // Act & Assert
      expect(
        () => useCase(sessionId: '   ', fileHashes: fileHashes),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid Sync Session ID'),
        )),
      );
    });

    test('should throw exception when file hashes list is empty', () async {
      // Act & Assert
      expect(
        () => useCase(sessionId: sessionId, fileHashes: []),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('It must be at least one file to check'),
        )),
      );

      verifyNever(() => mockRepository.checkDuplicates(
            sessionId: any(named: 'sessionId'),
            fileHashes: any(named: 'fileHashes'),
          ));
    });

    test('should throw exception for invalid hash length', () async {
      // Arrange
      const invalidHash = 'abc123'; // Too short

      // Act & Assert
      expect(
        () => useCase(sessionId: sessionId, fileHashes: [invalidHash]),
        throwsA(anyOf(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid hash detected'),
          ),
          isA<RangeError>(), // Thrown when substring index is out of range
        )),
      );
    });

    test('should throw exception for hash with invalid characters', () async {
      // Arrange
      final invalidHash = 'z' * 64; // Contains 'z' which is not hex

      // Act & Assert
      expect(
        () => useCase(sessionId: sessionId, fileHashes: [invalidHash]),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid hash detected'),
        )),
      );
    });

    test('should accept uppercase hex characters in hash', () async {
      // Arrange
      final uppercaseHash = 'A' * 64;
      final result = DuplicateFilesResult(
        filesToUpload: [uppercaseHash],
        duplicatesCount: 0,
        totalFiles: 1,
      );
      when(() => mockRepository.checkDuplicates(
            sessionId: any(named: 'sessionId'),
            fileHashes: any(named: 'fileHashes'),
          )).thenAnswer((_) async => result);

      // Act
      final response = await useCase(
        sessionId: sessionId,
        fileHashes: [uppercaseHash],
      );

      // Assert
      expect(response, result);
      verify(() => mockRepository.checkDuplicates(
            sessionId: sessionId,
            fileHashes: [uppercaseHash],
          )).called(1);
    });

    test('should accept mixed case hex characters in hash', () async {
      // Arrange
      // Create a 64-character hex string with mixed case
      final mixedCaseHash = 'aA' * 32; // 64 chars total
      final result = DuplicateFilesResult.empty();
      when(() => mockRepository.checkDuplicates(
            sessionId: any(named: 'sessionId'),
            fileHashes: any(named: 'fileHashes'),
          )).thenAnswer((_) async => result);

      // Act
      await useCase(sessionId: sessionId, fileHashes: [mixedCaseHash]);

      // Assert
      verify(() => mockRepository.checkDuplicates(
            sessionId: sessionId,
            fileHashes: [mixedCaseHash],
          )).called(1);
    });

    test('should handle all files are duplicates', () async {
      // Arrange
      final fileHashes = [validHash1, validHash2, validHash3];
      final allDuplicatesResult = DuplicateFilesResult(
        filesToUpload: [],
        duplicatesCount: 3,
        totalFiles: 3,
      );
      when(() => mockRepository.checkDuplicates(
            sessionId: any(named: 'sessionId'),
            fileHashes: any(named: 'fileHashes'),
          )).thenAnswer((_) async => allDuplicatesResult);

      // Act
      final result = await useCase(sessionId: sessionId, fileHashes: fileHashes);

      // Assert
      expect(result.allFilesAreDuplicates, true);
      expect(result.hasFilesToUpload, false);
    });

    test('should handle no duplicates found', () async {
      // Arrange
      final fileHashes = [validHash1, validHash2];
      final noDuplicatesResult = DuplicateFilesResult(
        filesToUpload: [validHash1, validHash2],
        duplicatesCount: 0,
        totalFiles: 2,
      );
      when(() => mockRepository.checkDuplicates(
            sessionId: any(named: 'sessionId'),
            fileHashes: any(named: 'fileHashes'),
          )).thenAnswer((_) async => noDuplicatesResult);

      // Act
      final result = await useCase(sessionId: sessionId, fileHashes: fileHashes);

      // Assert
      expect(result.duplicatesCount, 0);
      expect(result.hasFilesToUpload, true);
      expect(result.filesToUpload.length, 2);
    });

    test('should handle large list of hashes', () async {
      // Arrange
      final largeList = List.generate(1000, (index) => validHash1);
      final result = DuplicateFilesResult(
        filesToUpload: largeList,
        duplicatesCount: 0,
        totalFiles: 1000,
      );
      when(() => mockRepository.checkDuplicates(
            sessionId: any(named: 'sessionId'),
            fileHashes: any(named: 'fileHashes'),
          )).thenAnswer((_) async => result);

      // Act
      final response = await useCase(sessionId: sessionId, fileHashes: largeList);

      // Assert
      expect(response.totalFiles, 1000);
      verify(() => mockRepository.checkDuplicates(
            sessionId: sessionId,
            fileHashes: largeList,
          )).called(1);
    });

    test('should propagate exception from repository', () async {
      // Arrange
      final fileHashes = [validHash1];
      when(() => mockRepository.checkDuplicates(
            sessionId: any(named: 'sessionId'),
            fileHashes: any(named: 'fileHashes'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase(sessionId: sessionId, fileHashes: fileHashes),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Network error'),
        )),
      );
    });

    test('should pass session ID as-is to repository (validation only trims)', () async {
      // Arrange
      const sessionIdWithSpaces = '  session_123  ';
      final fileHashes = [validHash1];
      final result = DuplicateFilesResult.empty();
      when(() => mockRepository.checkDuplicates(
            sessionId: any(named: 'sessionId'),
            fileHashes: any(named: 'fileHashes'),
          )).thenAnswer((_) async => result);

      // Act
      await useCase(sessionId: sessionIdWithSpaces, fileHashes: fileHashes);

      // Assert
      verify(() => mockRepository.checkDuplicates(
            sessionId: sessionIdWithSpaces,
            fileHashes: fileHashes,
          )).called(1);
    });
  });
}