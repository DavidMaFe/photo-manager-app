import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/trash/domain/repositories/trash_repository.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/permanently_delete_files_use_case.dart';

class MockTrashRepository extends Mock implements TrashRepository {}

void main() {
  late PermanentlyDeleteFilesUseCase useCase;
  late MockTrashRepository mockRepository;

  setUp(() {
    mockRepository = MockTrashRepository();
    useCase = PermanentlyDeleteFilesUseCase(mockRepository);
  });

  group('PermanentlyDeleteFilesUseCase', () {
    group('successful calls', () {
      test('should call repository with single file ID', () async {
        // Arrange
        final fileIds = ['file-1'];
        when(() => mockRepository.permanentlyDeleteFiles(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase.call(fileIds);

        // Assert
        verify(() => mockRepository.permanentlyDeleteFiles(fileIds)).called(1);
      });

      test('should call repository with multiple file IDs', () async {
        // Arrange
        final fileIds = ['file-1', 'file-2', 'file-3'];
        when(() => mockRepository.permanentlyDeleteFiles(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase.call(fileIds);

        // Assert
        verify(() => mockRepository.permanentlyDeleteFiles(fileIds)).called(1);
      });

      test('should complete successfully when repository completes', () async {
        // Arrange
        final fileIds = ['file-1'];
        when(() => mockRepository.permanentlyDeleteFiles(any()))
            .thenAnswer((_) async => {});

        // Act & Assert
        await expectLater(
          useCase.call(fileIds),
          completes,
        );
      });
    });

    group('validation errors', () {
      test('should throw ArgumentError when file IDs list is empty', () async {
        // Arrange
        final fileIds = <String>[];

        // Act & Assert
        expect(
          () => useCase.call(fileIds),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'File IDs list cannot be empty',
          )),
        );
      });

      test('should throw ArgumentError when file ID is empty string', () async {
        // Arrange
        final fileIds = ['file-1', '', 'file-3'];

        // Act & Assert
        expect(
          () => useCase.call(fileIds),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'File IDs cannot be empty strings',
          )),
        );
      });

      test('should throw ArgumentError when file ID is whitespace only', () async {
        // Arrange
        final fileIds = ['file-1', '   ', 'file-3'];

        // Act & Assert
        expect(
          () => useCase.call(fileIds),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'File IDs cannot be empty strings',
          )),
        );
      });
    });

    group('edge cases', () {
      test('should handle large list of file IDs', () async {
        // Arrange
        final fileIds = List.generate(100, (index) => 'file-$index');
        when(() => mockRepository.permanentlyDeleteFiles(any()))
            .thenAnswer((_) async => {});

        // Act
        await useCase.call(fileIds);

        // Assert
        verify(() => mockRepository.permanentlyDeleteFiles(fileIds)).called(1);
      });

      test('should propagate repository errors', () async {
        // Arrange
        final fileIds = ['file-1'];
        when(() => mockRepository.permanentlyDeleteFiles(any()))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => useCase.call(fileIds),
          throwsException,
        );
      });
    });
  });
}
