import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/folders/domain/repositories/folder_repository.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/delete_folder_use_case.dart';

class MockFolderRepository extends Mock implements FolderRepository {}

void main() {
  late DeleteFolderUseCase useCase;
  late MockFolderRepository mockRepository;

  setUp(() {
    mockRepository = MockFolderRepository();
    useCase = DeleteFolderUseCase(mockRepository);
  });

  group('DeleteFolderUseCase', () {
    test('should delete folder successfully', () async {
      // Arrange
      const folderId = 'folder-1';
      when(() => mockRepository.deleteFolder(folderId: folderId))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase.call(folderId: folderId);

      // Assert
      verify(() => mockRepository.deleteFolder(folderId: folderId)).called(1);
    });

    test('should delete empty folder', () async {
      // Arrange
      const folderId = 'empty-folder';
      when(() => mockRepository.deleteFolder(folderId: folderId))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase.call(folderId: folderId);

      // Assert
      verify(() => mockRepository.deleteFolder(folderId: folderId)).called(1);
    });

    test('should propagate repository exception for folder not found', () async {
      // Arrange
      const folderId = 'non-existent';
      when(() => mockRepository.deleteFolder(folderId: folderId))
          .thenThrow(Exception('Folder not found'));

      // Act & Assert
      expect(
        () => useCase.call(folderId: folderId),
        throwsA(isA<Exception>()),
      );
      verify(() => mockRepository.deleteFolder(folderId: folderId)).called(1);
    });

    test('should propagate repository exception for folder not empty', () async {
      // Arrange
      const folderId = 'folder-with-files';
      when(() => mockRepository.deleteFolder(folderId: folderId))
          .thenThrow(Exception('Folder is not empty'));

      // Act & Assert
      expect(
        () => useCase.call(folderId: folderId),
        throwsException,
      );
    });

    test('should handle network error from repository', () async {
      // Arrange
      const folderId = 'folder-1';
      when(() => mockRepository.deleteFolder(folderId: folderId))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.call(folderId: folderId),
        throwsException,
      );
    });

    test('should delete subfolder', () async {
      // Arrange
      const subfolderId = 'subfolder-1';
      when(() => mockRepository.deleteFolder(folderId: subfolderId))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase.call(folderId: subfolderId);

      // Assert
      verify(() => mockRepository.deleteFolder(folderId: subfolderId)).called(1);
    });

    test('should delete root folder', () async {
      // Arrange
      const rootFolderId = 'root-folder';
      when(() => mockRepository.deleteFolder(folderId: rootFolderId))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase.call(folderId: rootFolderId);

      // Assert
      verify(() => mockRepository.deleteFolder(folderId: rootFolderId)).called(1);
    });

    test('should delete multiple folders in sequence', () async {
      // Arrange
      const folderId1 = 'folder-1';
      const folderId2 = 'folder-2';
      when(() => mockRepository.deleteFolder(folderId: folderId1))
          .thenAnswer((_) async => Future.value());
      when(() => mockRepository.deleteFolder(folderId: folderId2))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase.call(folderId: folderId1);
      await useCase.call(folderId: folderId2);

      // Assert
      verify(() => mockRepository.deleteFolder(folderId: folderId1)).called(1);
      verify(() => mockRepository.deleteFolder(folderId: folderId2)).called(1);
    });

    test('should handle folder ID with special characters', () async {
      // Arrange
      const folderId = 'folder-@#\$%';
      when(() => mockRepository.deleteFolder(folderId: folderId))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase.call(folderId: folderId);

      // Assert
      verify(() => mockRepository.deleteFolder(folderId: folderId)).called(1);
    });

    test('should handle long folder ID', () async {
      // Arrange
      final longId = 'folder-${'a' * 500}';
      when(() => mockRepository.deleteFolder(folderId: longId))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase.call(folderId: longId);

      // Assert
      verify(() => mockRepository.deleteFolder(folderId: longId)).called(1);
    });

    test('should propagate permission error', () async {
      // Arrange
      const folderId = 'protected-folder';
      when(() => mockRepository.deleteFolder(folderId: folderId))
          .thenThrow(Exception('Permission denied'));

      // Act & Assert
      expect(
        () => useCase.call(folderId: folderId),
        throwsException,
      );
    });

    test('should complete without returning a value', () async {
      // Arrange
      const folderId = 'folder-1';
      when(() => mockRepository.deleteFolder(folderId: folderId))
          .thenAnswer((_) async => Future.value());

      // Act
      await useCase.call(folderId: folderId);

      // Assert
      verify(() => mockRepository.deleteFolder(folderId: folderId)).called(1);
    });
  });
}
