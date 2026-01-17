import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/domain/repositories/folder_repository.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/rename_folder_use_case.dart';

class MockFolderRepository extends Mock implements FolderRepository {}

void main() {
  late RenameFolderUseCase useCase;
  late MockFolderRepository mockRepository;

  setUp(() {
    mockRepository = MockFolderRepository();
    useCase = RenameFolderUseCase(mockRepository);
  });

  group('RenameFolderUseCase', () {
    final testDate = DateTime(2024, 1, 15);

    test('should rename folder with valid name', () async {
      // Arrange
      const folderId = 'folder-1';
      const newName = 'New Vacation';
      final renamedFolder = Folder(
        id: folderId,
        name: newName,
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      when(() => mockRepository.renameFolder(
            folderId: folderId,
            newName: newName,
          )).thenAnswer((_) async => renamedFolder);

      // Act
      final result = await useCase.call(folderId: folderId, newName: newName);

      // Assert
      expect(result, renamedFolder);
      expect(result.name, newName);
      verify(() => mockRepository.renameFolder(
            folderId: folderId,
            newName: newName,
          )).called(1);
    });

    test('should trim new name before renaming', () async {
      // Arrange
      const folderId = 'folder-1';
      const newName = '  New Vacation  ';
      const trimmedName = 'New Vacation';
      final renamedFolder = Folder(
        id: folderId,
        name: trimmedName,
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      when(() => mockRepository.renameFolder(
            folderId: folderId,
            newName: trimmedName,
          )).thenAnswer((_) async => renamedFolder);

      // Act
      final result = await useCase.call(folderId: folderId, newName: newName);

      // Assert
      expect(result, renamedFolder);
      verify(() => mockRepository.renameFolder(
            folderId: folderId,
            newName: trimmedName,
          )).called(1);
    });

    test('should throw exception when new name is empty', () async {
      // Arrange
      const folderId = 'folder-1';
      const newName = '';

      // Act & Assert
      expect(
        () => useCase.call(folderId: folderId, newName: newName),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid name'),
        )),
      );
      verifyNever(() => mockRepository.renameFolder(
            folderId: any(named: 'folderId'),
            newName: any(named: 'newName'),
          ));
    });

    test('should throw exception when trimmed name is empty', () async {
      // Arrange
      const folderId = 'folder-1';
      const newName = '   ';

      // Act & Assert
      expect(
        () => useCase.call(folderId: folderId, newName: newName),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid name'),
        )),
      );
      verifyNever(() => mockRepository.renameFolder(
            folderId: any(named: 'folderId'),
            newName: any(named: 'newName'),
          ));
    });

    test('should propagate repository exception for folder not found', () async {
      // Arrange
      const folderId = 'non-existent';
      const newName = 'New Name';

      when(() => mockRepository.renameFolder(
            folderId: folderId,
            newName: newName,
          )).thenThrow(Exception('Folder not found'));

      // Act & Assert
      expect(
        () => useCase.call(folderId: folderId, newName: newName),
        throwsA(isA<Exception>()),
      );
      verify(() => mockRepository.renameFolder(
            folderId: folderId,
            newName: newName,
          )).called(1);
    });

    test('should propagate repository exception for duplicate name', () async {
      // Arrange
      const folderId = 'folder-1';
      const newName = 'Work'; // Assume this name already exists

      when(() => mockRepository.renameFolder(
            folderId: folderId,
            newName: newName,
          )).thenThrow(Exception('Folder name already exists'));

      // Act & Assert
      expect(
        () => useCase.call(folderId: folderId, newName: newName),
        throwsException,
      );
    });

    test('should handle network error from repository', () async {
      // Arrange
      const folderId = 'folder-1';
      const newName = 'New Name';

      when(() => mockRepository.renameFolder(
            folderId: folderId,
            newName: newName,
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.call(folderId: folderId, newName: newName),
        throwsException,
      );
    });

    test('should handle special characters in new name', () async {
      // Arrange
      const folderId = 'folder-1';
      const newName = 'Folder @#\$%';
      final renamedFolder = Folder(
        id: folderId,
        name: newName,
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      when(() => mockRepository.renameFolder(
            folderId: folderId,
            newName: newName,
          )).thenAnswer((_) async => renamedFolder);

      // Act
      final result = await useCase.call(folderId: folderId, newName: newName);

      // Assert
      expect(result.name, newName);
    });

    test('should handle unicode characters in new name', () async {
      // Arrange
      const folderId = 'folder-1';
      const newName = 'Vacaciones 🏖️ 日本';
      final renamedFolder = Folder(
        id: folderId,
        name: newName,
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      when(() => mockRepository.renameFolder(
            folderId: folderId,
            newName: newName,
          )).thenAnswer((_) async => renamedFolder);

      // Act
      final result = await useCase.call(folderId: folderId, newName: newName);

      // Assert
      expect(result.name, newName);
    });

    test('should handle trimming with tabs and newlines', () async {
      // Arrange
      const folderId = 'folder-1';
      const newName = '\t\nNew Name\n\t';
      const trimmedName = 'New Name';
      final renamedFolder = Folder(
        id: folderId,
        name: trimmedName,
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      when(() => mockRepository.renameFolder(
            folderId: folderId,
            newName: trimmedName,
          )).thenAnswer((_) async => renamedFolder);

      // Act
      final result = await useCase.call(folderId: folderId, newName: newName);

      // Assert
      expect(result.name, trimmedName);
      verify(() => mockRepository.renameFolder(
            folderId: folderId,
            newName: trimmedName,
          )).called(1);
    });

    test('should rename subfolder', () async {
      // Arrange
      const folderId = 'subfolder-1';
      const parentId = 'folder-1';
      const newName = 'Renamed Subfolder';
      final renamedSubfolder = Folder(
        id: folderId,
        name: newName,
        parentFolderId: parentId,
        path: '/root/folder-1/subfolder-1',
        createdAt: testDate,
        fileCount: 5,
        subfolderCount: 0,
      );

      when(() => mockRepository.renameFolder(
            folderId: folderId,
            newName: newName,
          )).thenAnswer((_) async => renamedSubfolder);

      // Act
      final result = await useCase.call(folderId: folderId, newName: newName);

      // Assert
      expect(result.parentFolderId, parentId);
      expect(result.isRoot, false);
      expect(result.name, newName);
    });

    test('should handle long folder name', () async {
      // Arrange
      const folderId = 'folder-1';
      final longName = 'a' * 255;
      final renamedFolder = Folder(
        id: folderId,
        name: longName,
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      when(() => mockRepository.renameFolder(
            folderId: folderId,
            newName: longName,
          )).thenAnswer((_) async => renamedFolder);

      // Act
      final result = await useCase.call(folderId: folderId, newName: longName);

      // Assert
      expect(result.name.length, 255);
    });

    test('should rename multiple folders in sequence', () async {
      // Arrange
      const folderId1 = 'folder-1';
      const folderId2 = 'folder-2';
      const newName1 = 'Renamed 1';
      const newName2 = 'Renamed 2';

      final renamed1 = Folder(
        id: folderId1,
        name: newName1,
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      final renamed2 = Folder(
        id: folderId2,
        name: newName2,
        parentFolderId: null,
        path: '/root/folder-2',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      when(() => mockRepository.renameFolder(
            folderId: folderId1,
            newName: newName1,
          )).thenAnswer((_) async => renamed1);

      when(() => mockRepository.renameFolder(
            folderId: folderId2,
            newName: newName2,
          )).thenAnswer((_) async => renamed2);

      // Act
      final result1 = await useCase.call(folderId: folderId1, newName: newName1);
      final result2 = await useCase.call(folderId: folderId2, newName: newName2);

      // Assert
      expect(result1.name, newName1);
      expect(result2.name, newName2);
    });
  });
}
