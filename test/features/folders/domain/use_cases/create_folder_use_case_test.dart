import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/domain/repositories/folder_repository.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/create_folder_use_case.dart';

class MockFolderRepository extends Mock implements FolderRepository {}

void main() {
  late CreateFolderUseCase useCase;
  late MockFolderRepository mockRepository;

  setUp(() {
    mockRepository = MockFolderRepository();
    useCase = CreateFolderUseCase(mockRepository);
  });

  group('CreateFolderUseCase', () {
    final testDate = DateTime(2024, 1, 15);
    final createdFolder = Folder(
      id: 'folder-1',
      name: 'Vacation',
      parentFolderId: null,
      path: '/root/folder-1',
      createdAt: testDate,
      fileCount: 0,
      subfolderCount: 0,
    );

    test('should create folder with valid name', () async {
      // Arrange
      const folderName = 'Vacation';
      when(() => mockRepository.createFolder(
            name: folderName,
            parentFolderId: null,
          )).thenAnswer((_) async => createdFolder);

      // Act
      final result = await useCase.call(name: folderName);

      // Assert
      expect(result, createdFolder);
      verify(() => mockRepository.createFolder(
            name: folderName,
            parentFolderId: null,
          )).called(1);
    });

    test('should trim folder name before creating', () async {
      // Arrange
      const folderName = '  Vacation  ';
      const trimmedName = 'Vacation';
      when(() => mockRepository.createFolder(
            name: trimmedName,
            parentFolderId: null,
          )).thenAnswer((_) async => createdFolder);

      // Act
      final result = await useCase.call(name: folderName);

      // Assert
      expect(result, createdFolder);
      verify(() => mockRepository.createFolder(
            name: trimmedName,
            parentFolderId: null,
          )).called(1);
    });

    test('should throw exception when name is empty', () async {
      // Arrange
      const folderName = '';

      // Act & Assert
      expect(
        () => useCase.call(name: folderName),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid name'),
        )),
      );
      verifyNever(() => mockRepository.createFolder(
            name: any(named: 'name'),
            parentFolderId: any(named: 'parentFolderId'),
          ));
    });

    test('should throw exception when trimmed name is empty', () async {
      // Arrange
      const folderName = '   ';

      // Act & Assert
      expect(
        () => useCase.call(name: folderName),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid name'),
        )),
      );
      verifyNever(() => mockRepository.createFolder(
            name: any(named: 'name'),
            parentFolderId: any(named: 'parentFolderId'),
          ));
    });

    test('should create folder with parent folder ID', () async {
      // Arrange
      const folderName = 'Summer';
      const parentId = 'folder-1';
      final createdSubfolder = Folder(
        id: 'subfolder-1',
        name: folderName,
        parentFolderId: parentId,
        path: '/root/folder-1/subfolder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      when(() => mockRepository.createFolder(
            name: folderName,
            parentFolderId: parentId,
          )).thenAnswer((_) async => createdSubfolder);

      // Act
      final result = await useCase.call(
        name: folderName,
        parentFolderId: parentId,
      );

      // Assert
      expect(result, createdSubfolder);
      expect(result.parentFolderId, parentId);
      verify(() => mockRepository.createFolder(
            name: folderName,
            parentFolderId: parentId,
          )).called(1);
    });

    test('should create root folder when parentFolderId is null', () async {
      // Arrange
      const folderName = 'Vacation';
      when(() => mockRepository.createFolder(
            name: folderName,
            parentFolderId: null,
          )).thenAnswer((_) async => createdFolder);

      // Act
      final result = await useCase.call(name: folderName, parentFolderId: null);

      // Assert
      expect(result.isRoot, true);
      expect(result.parentFolderId, isNull);
      verify(() => mockRepository.createFolder(
            name: folderName,
            parentFolderId: null,
          )).called(1);
    });

    test('should propagate repository exception for duplicate name', () async {
      // Arrange
      const folderName = 'Vacation';
      when(() => mockRepository.createFolder(
            name: folderName,
            parentFolderId: null,
          )).thenThrow(Exception('Folder already exists'));

      // Act & Assert
      expect(
        () => useCase.call(name: folderName),
        throwsA(isA<Exception>()),
      );
      verify(() => mockRepository.createFolder(
            name: folderName,
            parentFolderId: null,
          )).called(1);
    });

    test('should handle network error from repository', () async {
      // Arrange
      const folderName = 'Vacation';
      when(() => mockRepository.createFolder(
            name: folderName,
            parentFolderId: null,
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.call(name: folderName),
        throwsException,
      );
    });

    test('should handle folder name with special characters', () async {
      // Arrange
      const folderName = 'Folder @#\$%';
      final specialFolder = Folder(
        id: 'folder-1',
        name: folderName,
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      when(() => mockRepository.createFolder(
            name: folderName,
            parentFolderId: null,
          )).thenAnswer((_) async => specialFolder);

      // Act
      final result = await useCase.call(name: folderName);

      // Assert
      expect(result.name, folderName);
    });

    test('should handle folder name with unicode characters', () async {
      // Arrange
      const folderName = 'Vacaciones 🏖️ 日本';
      final unicodeFolder = Folder(
        id: 'folder-1',
        name: folderName,
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      when(() => mockRepository.createFolder(
            name: folderName,
            parentFolderId: null,
          )).thenAnswer((_) async => unicodeFolder);

      // Act
      final result = await useCase.call(name: folderName);

      // Assert
      expect(result.name, folderName);
    });

    test('should handle long folder name', () async {
      // Arrange
      final longName = 'a' * 255;
      final longNameFolder = Folder(
        id: 'folder-1',
        name: longName,
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      when(() => mockRepository.createFolder(
            name: longName,
            parentFolderId: null,
          )).thenAnswer((_) async => longNameFolder);

      // Act
      final result = await useCase.call(name: longName);

      // Assert
      expect(result.name.length, 255);
    });

    test('should handle trimming with tabs and newlines', () async {
      // Arrange
      const folderName = '\t\nVacation\n\t';
      const trimmedName = 'Vacation';

      when(() => mockRepository.createFolder(
            name: trimmedName,
            parentFolderId: null,
          )).thenAnswer((_) async => createdFolder);

      // Act
      final result = await useCase.call(name: folderName);

      // Assert
      expect(result, createdFolder);
      verify(() => mockRepository.createFolder(
            name: trimmedName,
            parentFolderId: null,
          )).called(1);
    });

    test('should create multiple folders in sequence', () async {
      // Arrange
      final folder1 = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      final folder2 = Folder(
        id: 'folder-2',
        name: 'Work',
        parentFolderId: null,
        path: '/root/folder-2',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      when(() => mockRepository.createFolder(
            name: 'Vacation',
            parentFolderId: null,
          )).thenAnswer((_) async => folder1);

      when(() => mockRepository.createFolder(
            name: 'Work',
            parentFolderId: null,
          )).thenAnswer((_) async => folder2);

      // Act
      final result1 = await useCase.call(name: 'Vacation');
      final result2 = await useCase.call(name: 'Work');

      // Assert
      expect(result1.name, 'Vacation');
      expect(result2.name, 'Work');
      verify(() => mockRepository.createFolder(
            name: 'Vacation',
            parentFolderId: null,
          )).called(1);
      verify(() => mockRepository.createFolder(
            name: 'Work',
            parentFolderId: null,
          )).called(1);
    });
  });
}
