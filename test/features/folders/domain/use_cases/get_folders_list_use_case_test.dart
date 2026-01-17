import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/domain/repositories/folder_repository.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_folders_list_use_case.dart';

class MockFolderRepository extends Mock implements FolderRepository {}

void main() {
  late GetFoldersListUseCase useCase;
  late MockFolderRepository mockRepository;

  setUp(() {
    mockRepository = MockFolderRepository();
    useCase = GetFoldersListUseCase(mockRepository);
  });

  group('GetFoldersListUseCase', () {
    final testDate = DateTime(2024, 1, 15);
    final folders = [
      Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      ),
      Folder(
        id: 'folder-2',
        name: 'Work',
        parentFolderId: null,
        path: '/root/folder-2',
        createdAt: testDate.add(const Duration(days: 1)),
        fileCount: 15,
        subfolderCount: 0,
      ),
    ];

    test('should get folders list from repository', () async {
      // Arrange
      when(() => mockRepository.getFolders(parentFolderId: null))
          .thenAnswer((_) async => folders);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, folders);
      verify(() => mockRepository.getFolders(parentFolderId: null)).called(1);
    });

    test('should get root folders when parentFolderId is null', () async {
      // Arrange
      when(() => mockRepository.getFolders(parentFolderId: null))
          .thenAnswer((_) async => folders);

      // Act
      final result = await useCase.call(parentFolderId: null);

      // Assert
      expect(result, folders);
      verify(() => mockRepository.getFolders(parentFolderId: null)).called(1);
    });

    test('should get subfolders when parentFolderId is provided', () async {
      // Arrange
      const parentId = 'folder-1';
      final subfolders = [
        Folder(
          id: 'subfolder-1',
          name: 'Summer',
          parentFolderId: parentId,
          path: '/root/folder-1/subfolder-1',
          createdAt: testDate,
          fileCount: 10,
          subfolderCount: 0,
        ),
        Folder(
          id: 'subfolder-2',
          name: 'Winter',
          parentFolderId: parentId,
          path: '/root/folder-1/subfolder-2',
          createdAt: testDate,
          fileCount: 5,
          subfolderCount: 0,
        ),
      ];

      when(() => mockRepository.getFolders(parentFolderId: parentId))
          .thenAnswer((_) async => subfolders);

      // Act
      final result = await useCase.call(parentFolderId: parentId);

      // Assert
      expect(result, subfolders);
      expect(result.length, 2);
      verify(() => mockRepository.getFolders(parentFolderId: parentId))
          .called(1);
    });

    test('should return empty list when no folders exist', () async {
      // Arrange
      when(() => mockRepository.getFolders(parentFolderId: null))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isEmpty);
      verify(() => mockRepository.getFolders(parentFolderId: null)).called(1);
    });

    test('should propagate repository exception', () async {
      // Arrange
      when(() => mockRepository.getFolders(parentFolderId: null))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsA(isA<Exception>()),
      );
      verify(() => mockRepository.getFolders(parentFolderId: null)).called(1);
    });

    test('should handle repository error', () async {
      // Arrange
      when(() => mockRepository.getFolders(parentFolderId: null))
          .thenThrow(Exception('Folder not found'));

      // Act & Assert
      expect(
        () => useCase.call(parentFolderId: null),
        throwsException,
      );
    });

    test('should handle many folders', () async {
      // Arrange
      final manyFolders = List.generate(
        100,
        (i) => Folder(
          id: 'folder-$i',
          name: 'Folder $i',
          parentFolderId: null,
          path: '/root/folder-$i',
          createdAt: testDate.add(Duration(days: i)),
          fileCount: i * 10,
          subfolderCount: i,
        ),
      );

      when(() => mockRepository.getFolders(parentFolderId: null))
          .thenAnswer((_) async => manyFolders);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.length, 100);
      expect(result, manyFolders);
    });

    test('should work with different parent folder IDs', () async {
      // Arrange
      const parentId1 = 'parent-1';
      const parentId2 = 'parent-2';

      final folders1 = [
        Folder(
          id: 'subfolder-1',
          name: 'Subfolder 1',
          parentFolderId: parentId1,
          path: '/root/parent-1/subfolder-1',
          createdAt: testDate,
          fileCount: 5,
          subfolderCount: 0,
        ),
      ];

      final folders2 = [
        Folder(
          id: 'subfolder-2',
          name: 'Subfolder 2',
          parentFolderId: parentId2,
          path: '/root/parent-2/subfolder-2',
          createdAt: testDate,
          fileCount: 3,
          subfolderCount: 0,
        ),
      ];

      when(() => mockRepository.getFolders(parentFolderId: parentId1))
          .thenAnswer((_) async => folders1);
      when(() => mockRepository.getFolders(parentFolderId: parentId2))
          .thenAnswer((_) async => folders2);

      // Act
      final result1 = await useCase.call(parentFolderId: parentId1);
      final result2 = await useCase.call(parentFolderId: parentId2);

      // Assert
      expect(result1, folders1);
      expect(result2, folders2);
      expect(result1, isNot(result2));
    });
  });
}
