import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_folder.dart';
import 'package:photo_manager_app/features/file_management/domain/repositories/file_management_repository.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/get_folders_use_case.dart';

class MockFileManagementRepository extends Mock implements FileManagementRepository {}

void main() {
  late GetFoldersUseCase useCase;
  late MockFileManagementRepository mockRepository;

  setUp(() {
    mockRepository = MockFileManagementRepository();
    useCase = GetFoldersUseCase(mockRepository);
  });

  group('GetFoldersUseCase', () {
    final testDate = DateTime(2024, 1, 15);
    final folders = [
      ManageFolder(
        id: 'folder-1',
        name: 'Vacation Photos',
        fileCount: 42,
        createdAt: testDate,
      ),
      ManageFolder(
        id: 'folder-2',
        name: 'Work Documents',
        fileCount: 15,
        createdAt: testDate.add(const Duration(days: 1)),
      ),
      ManageFolder(
        id: 'folder-3',
        name: 'Family Pictures',
        fileCount: 100,
        createdAt: testDate.add(const Duration(days: 2)),
      ),
    ];

    test('should call repository getFolders', () async {
      // Arrange
      when(() => mockRepository.getFolders()).thenAnswer((_) async => folders);

      // Act
      await useCase.call();

      // Assert
      verify(() => mockRepository.getFolders()).called(1);
    });

    test('should return folders from repository', () async {
      // Arrange
      when(() => mockRepository.getFolders()).thenAnswer((_) async => folders);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, folders);
      expect(result.length, 3);
      expect(result[0].name, 'Vacation Photos');
      expect(result[1].name, 'Work Documents');
      expect(result[2].name, 'Family Pictures');
    });

    test('should return empty list when no folders exist', () async {
      // Arrange
      when(() => mockRepository.getFolders()).thenAnswer((_) async => []);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isEmpty);
    });

    test('should return single folder', () async {
      // Arrange
      final singleFolder = [folders.first];

      when(() => mockRepository.getFolders()).thenAnswer((_) async => singleFolder);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.length, 1);
      expect(result.first.id, 'folder-1');
    });

    test('should propagate exception from repository', () async {
      // Arrange
      when(() => mockRepository.getFolders())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsA(isA<Exception>()),
      );
    });

    test('should return folders in the order provided by repository', () async {
      // Arrange
      final reversedFolders = folders.reversed.toList();

      when(() => mockRepository.getFolders()).thenAnswer((_) async => reversedFolders);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result[0].id, 'folder-3');
      expect(result[1].id, 'folder-2');
      expect(result[2].id, 'folder-1');
    });

    test('should handle folders with zero file count', () async {
      // Arrange
      final emptyFolder = ManageFolder(
        id: 'empty-folder',
        name: 'Empty Folder',
        fileCount: 0,
        createdAt: testDate,
      );

      when(() => mockRepository.getFolders()).thenAnswer((_) async => [emptyFolder]);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.length, 1);
      expect(result.first.fileCount, 0);
    });

    test('should handle folders with large file count', () async {
      // Arrange
      final largeFolder = ManageFolder(
        id: 'large-folder',
        name: 'Large Folder',
        fileCount: 10000,
        createdAt: testDate,
      );

      when(() => mockRepository.getFolders()).thenAnswer((_) async => [largeFolder]);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.length, 1);
      expect(result.first.fileCount, 10000);
    });
  });
}
