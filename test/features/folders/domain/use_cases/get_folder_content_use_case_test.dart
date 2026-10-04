import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder_content.dart';
import 'package:photo_manager_app/features/folders/domain/repositories/folder_repository.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_folder_content_use_case.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';

class MockFolderRepository extends Mock implements FolderRepository {}

void main() {
  late GetFolderContentUseCase useCase;
  late MockFolderRepository mockRepository;

  setUp(() {
    mockRepository = MockFolderRepository();
    useCase = GetFolderContentUseCase(mockRepository);
  });

  group('GetFolderContentUseCase', () {
    final testDate = DateTime(2024, 1, 15);

    final testFolder = Folder(
      id: 'folder-1',
      name: 'Vacation',
      parentFolderId: null,
      path: '/root/folder-1',
      createdAt: testDate,
      fileCount: 2,
      subfolderCount: 1,
    );

    final testSubfolders = [
      Folder(
        id: 'subfolder-1',
        name: 'Summer',
        parentFolderId: 'folder-1',
        path: '/root/folder-1/subfolder-1',
        createdAt: testDate,
        fileCount: 5,
        subfolderCount: 0,
      ),
    ];

    final testFiles = [
      GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      ),
      GalleryFile(
        id: 'file-2',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      ),
    ];

    final folderContent = FolderContent(
      folder: testFolder,
      subfolders: testSubfolders,
      files: testFiles,
      hasMoreFiles: false,
      totalFilesCount: 0,
    );

    test('should get folder content from repository', () async {
      // Arrange
      const folderId = 'folder-1';
      when(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: 50,
            filter: FileFilter.all,
          )).thenAnswer((_) async => folderContent);

      // Act
      final result = await useCase.call(folderId: folderId);

      // Assert
      expect(result, folderContent);
      expect(result.folder, testFolder);
      expect(result.subfolders, testSubfolders);
      expect(result.files, testFiles);
      verify(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: 50,
            filter: FileFilter.all,
          )).called(1);
    });

    test('should use default parameters when not provided', () async {
      // Arrange
      const folderId = 'folder-1';
      when(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: 50,
            filter: FileFilter.all,
          )).thenAnswer((_) async => folderContent);

      // Act
      final result = await useCase.call(folderId: folderId);

      // Assert
      expect(result, folderContent);
      verify(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: 50,
            filter: FileFilter.all,
          )).called(1);
    });

    test('should support custom page parameter', () async {
      // Arrange
      const folderId = 'folder-1';
      const page = 2;
      when(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: page,
            pageSize: 50,
            filter: FileFilter.all,
          )).thenAnswer((_) async => folderContent);

      // Act
      final result = await useCase.call(folderId: folderId, page: page);

      // Assert
      expect(result, folderContent);
      verify(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: page,
            pageSize: 50,
            filter: FileFilter.all,
          )).called(1);
    });

    test('should support custom pageSize parameter', () async {
      // Arrange
      const folderId = 'folder-1';
      const pageSize = 100;
      when(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: pageSize,
            filter: FileFilter.all,
          )).thenAnswer((_) async => folderContent);

      // Act
      final result = await useCase.call(folderId: folderId, pageSize: pageSize);

      // Assert
      expect(result, folderContent);
      verify(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: pageSize,
            filter: FileFilter.all,
          )).called(1);
    });

    test('should filter by images only', () async {
      // Arrange
      const folderId = 'folder-1';
      final imageFiles = [testFiles[0]]; // Only image files
      final imageContent = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: imageFiles,
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      when(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: 50,
            filter: FileFilter.images,
          )).thenAnswer((_) async => imageContent);

      // Act
      final result = await useCase.call(
        folderId: folderId,
        filter: FileFilter.images,
      );

      // Assert
      expect(result.files.length, 1);
      verify(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: 50,
            filter: FileFilter.images,
          )).called(1);
    });

    test('should filter by videos only', () async {
      // Arrange
      const folderId = 'folder-1';
      final videoContent = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: const [],
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      when(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: 50,
            filter: FileFilter.videos,
          )).thenAnswer((_) async => videoContent);

      // Act
      final result = await useCase.call(
        folderId: folderId,
        filter: FileFilter.videos,
      );

      // Assert
      expect(result.files, isEmpty);
      verify(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: 50,
            filter: FileFilter.videos,
          )).called(1);
    });

    test('should get empty folder content', () async {
      // Arrange
      const folderId = 'empty-folder';
      final emptyFolder = Folder(
        id: folderId,
        name: 'Empty',
        parentFolderId: null,
        path: '/root/empty-folder',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      final emptyContent = FolderContent(
        folder: emptyFolder,
        subfolders: const [],
        files: const [],
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      when(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: 50,
            filter: FileFilter.all,
          )).thenAnswer((_) async => emptyContent);

      // Act
      final result = await useCase.call(folderId: folderId);

      // Assert
      expect(result.isEmpty, true);
      expect(result.files, isEmpty);
      expect(result.subfolders, isEmpty);
    });

    test('should indicate when there are more files', () async {
      // Arrange
      const folderId = 'folder-1';
      final contentWithMore = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: true,
        totalFilesCount: 0,
      );

      when(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: 50,
            filter: FileFilter.all,
          )).thenAnswer((_) async => contentWithMore);

      // Act
      final result = await useCase.call(folderId: folderId);

      // Assert
      expect(result.hasMoreFiles, true);
    });

    test('should handle pagination for second page', () async {
      // Arrange
      const folderId = 'folder-1';
      const page = 1;
      final secondPageFiles = [
        GalleryFile(
          id: 'file-3',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
        ),
      ];

      final secondPageContent = FolderContent(
        folder: testFolder,
        subfolders: const [],
        files: secondPageFiles,
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      when(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: page,
            pageSize: 50,
            filter: FileFilter.all,
          )).thenAnswer((_) async => secondPageContent);

      // Act
      final result = await useCase.call(folderId: folderId, page: page);

      // Assert
      expect(result.files.length, 1);
      expect(result.hasMoreFiles, false);
    });

    test('should propagate repository exception for folder not found', () async {
      // Arrange
      const folderId = 'non-existent';
      when(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: 50,
            filter: FileFilter.all,
          )).thenThrow(Exception('Folder not found'));

      // Act & Assert
      expect(
        () => useCase.call(folderId: folderId),
        throwsException,
      );
    });

    test('should handle network error from repository', () async {
      // Arrange
      const folderId = 'folder-1';
      when(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: 50,
            filter: FileFilter.all,
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.call(folderId: folderId),
        throwsException,
      );
    });

    test('should support all parameters together', () async {
      // Arrange
      const folderId = 'folder-1';
      const page = 2;
      const pageSize = 25;
      const filter = FileFilter.images;

      when(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: page,
            pageSize: pageSize,
            filter: filter,
          )).thenAnswer((_) async => folderContent);

      // Act
      final result = await useCase.call(
        folderId: folderId,
        page: page,
        pageSize: pageSize,
        filter: filter,
      );

      // Assert
      expect(result, folderContent);
      verify(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: page,
            pageSize: pageSize,
            filter: filter,
          )).called(1);
    });

    test('should handle large page size', () async {
      // Arrange
      const folderId = 'folder-1';
      const pageSize = 1000;

      when(() => mockRepository.getFolderContent(
            folderId: folderId,
            page: 0,
            pageSize: pageSize,
            filter: FileFilter.all,
          )).thenAnswer((_) async => folderContent);

      // Act
      final result = await useCase.call(folderId: folderId, pageSize: pageSize);

      // Assert
      expect(result, folderContent);
    });

    test('should handle subfolder content retrieval', () async {
      // Arrange
      const subfolderId = 'subfolder-1';
      final subfolder = testSubfolders[0];
      final subfolderContent = FolderContent(
        folder: subfolder,
        subfolders: const [],
        files: testFiles,
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      when(() => mockRepository.getFolderContent(
            folderId: subfolderId,
            page: 0,
            pageSize: 50,
            filter: FileFilter.all,
          )).thenAnswer((_) async => subfolderContent);

      // Act
      final result = await useCase.call(folderId: subfolderId);

      // Assert
      expect(result.folder.parentFolderId, 'folder-1');
      expect(result.folder.isRoot, false);
    });
  });
}
