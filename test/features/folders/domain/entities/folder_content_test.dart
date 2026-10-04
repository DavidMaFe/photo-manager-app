import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder_content.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';

void main() {
  group('FolderContent', () {
    final testDate = DateTime(2024, 1, 15);

    final testFolder = Folder(
      id: 'folder-1',
      name: 'Vacation',
      parentFolderId: null,
      path: '/root/folder-1',
      createdAt: testDate,
      fileCount: 2,
      subfolderCount: 2,
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
      Folder(
        id: 'subfolder-2',
        name: 'Winter',
        parentFolderId: 'folder-1',
        path: '/root/folder-1/subfolder-2',
        createdAt: testDate,
        fileCount: 3,
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

    test('should create folder content with all properties', () {
      // Arrange & Act
      final content = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: true,
        totalFilesCount: 0,
      );

      // Assert
      expect(content.folder, testFolder);
      expect(content.subfolders, testSubfolders);
      expect(content.files, testFiles);
      expect(content.hasMoreFiles, true);
    });

    test('should return true for hasSubfolders when subfolders list is not empty', () {
      // Arrange
      final content = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: const [],
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      // Act & Assert
      expect(content.hasSubfolders, true);
    });

    test('should return false for hasSubfolders when subfolders list is empty', () {
      // Arrange
      final content = FolderContent(
        folder: testFolder,
        subfolders: const [],
        files: testFiles,
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      // Act & Assert
      expect(content.hasSubfolders, false);
    });

    test('should return true for hasFiles when files list is not empty', () {
      // Arrange
      final content = FolderContent(
        folder: testFolder,
        subfolders: const [],
        files: testFiles,
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      // Act & Assert
      expect(content.hasFiles, true);
    });

    test('should return false for hasFiles when files list is empty', () {
      // Arrange
      final content = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: const [],
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      // Act & Assert
      expect(content.hasFiles, false);
    });

    test('should return true for isEmpty when both lists are empty', () {
      // Arrange
      final content = FolderContent(
        folder: testFolder,
        subfolders: const [],
        files: const [],
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      // Act & Assert
      expect(content.isEmpty, true);
    });

    test('should return false for isEmpty when subfolders exist', () {
      // Arrange
      final content = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: const [],
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      // Act & Assert
      expect(content.isEmpty, false);
    });

    test('should return false for isEmpty when files exist', () {
      // Arrange
      final content = FolderContent(
        folder: testFolder,
        subfolders: const [],
        files: testFiles,
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      // Act & Assert
      expect(content.isEmpty, false);
    });

    test('should support copyWith - update folder', () {
      // Arrange
      final original = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: true,
        totalFilesCount: 0,
      );

      final newFolder = Folder(
        id: 'folder-2',
        name: 'Work',
        parentFolderId: null,
        path: '/root/folder-2',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Act
      final updated = original.copyWith(folder: newFolder);

      // Assert
      expect(updated.folder, newFolder);
      expect(updated.subfolders, testSubfolders);
      expect(updated.files, testFiles);
      expect(updated.hasMoreFiles, true);
    });

    test('should support copyWith - update subfolders', () {
      // Arrange
      final original = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: true,
        totalFilesCount: 0,
      );

      final newSubfolders = <Folder>[];

      // Act
      final updated = original.copyWith(subfolders: newSubfolders);

      // Assert
      expect(updated.folder, testFolder);
      expect(updated.subfolders, newSubfolders);
      expect(updated.subfolders.isEmpty, true);
      expect(updated.files, testFiles);
    });

    test('should support copyWith - update files', () {
      // Arrange
      final original = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: true,
        totalFilesCount: 0,
      );

      final newFiles = <GalleryFile>[];

      // Act
      final updated = original.copyWith(files: newFiles);

      // Assert
      expect(updated.folder, testFolder);
      expect(updated.subfolders, testSubfolders);
      expect(updated.files, newFiles);
      expect(updated.files.isEmpty, true);
    });

    test('should support copyWith - update hasMoreFiles', () {
      // Arrange
      final original = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: true,
        totalFilesCount: 0,
      );

      // Act
      final updated = original.copyWith(hasMoreFiles: false);

      // Assert
      expect(updated.folder, testFolder);
      expect(updated.subfolders, testSubfolders);
      expect(updated.files, testFiles);
      expect(updated.hasMoreFiles, false);
    });

    test('should support copyWith - update multiple properties', () {
      // Arrange
      final original = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: true,
        totalFilesCount: 0,
      );

      final newFolder = Folder(
        id: 'folder-2',
        name: 'Work',
        parentFolderId: null,
        path: '/root/folder-2',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Act
      final updated = original.copyWith(
        folder: newFolder,
        hasMoreFiles: false,
      );

      // Assert
      expect(updated.folder, newFolder);
      expect(updated.subfolders, testSubfolders);
      expect(updated.files, testFiles);
      expect(updated.hasMoreFiles, false);
    });

    test('should support copyWith - no changes when no parameters', () {
      // Arrange
      final original = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: true,
        totalFilesCount: 0,
      );

      // Act
      final updated = original.copyWith();

      // Assert
      expect(updated.folder, testFolder);
      expect(updated.subfolders, testSubfolders);
      expect(updated.files, testFiles);
      expect(updated.hasMoreFiles, true);
    });

    test('should support Equatable - equal folder contents', () {
      // Arrange
      final content1 = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: true,
        totalFilesCount: 0,
      );

      final content2 = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: true,
        totalFilesCount: 0,
      );

      // Act & Assert
      expect(content1, content2);
      expect(content1.hashCode, content2.hashCode);
    });

    test('should support Equatable - different folders', () {
      // Arrange
      final content1 = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: true,
        totalFilesCount: 0,
      );

      final differentFolder = Folder(
        id: 'folder-2',
        name: 'Work',
        parentFolderId: null,
        path: '/root/folder-2',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      final content2 = FolderContent(
        folder: differentFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: true,
        totalFilesCount: 0,
      );

      // Act & Assert
      expect(content1, isNot(content2));
    });

    test('should support Equatable - different hasMoreFiles', () {
      // Arrange
      final content1 = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: true,
        totalFilesCount: 0,
      );

      final content2 = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      // Act & Assert
      expect(content1, isNot(content2));
    });

    test('should handle edge case - empty content', () {
      // Arrange & Act
      final content = FolderContent(
        folder: testFolder,
        subfolders: const [],
        files: const [],
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      // Assert
      expect(content.isEmpty, true);
      expect(content.hasSubfolders, false);
      expect(content.hasFiles, false);
    });

    test('should handle edge case - many subfolders', () {
      // Arrange
      final manySubfolders = List.generate(
        100,
        (i) => Folder(
          id: 'subfolder-$i',
          name: 'Subfolder $i',
          parentFolderId: 'folder-1',
          path: '/root/folder-1/subfolder-$i',
          createdAt: testDate,
          fileCount: i,
          subfolderCount: 0,
        ),
      );

      // Act
      final content = FolderContent(
        folder: testFolder,
        subfolders: manySubfolders,
        files: const [],
        hasMoreFiles: false,
        totalFilesCount: 0,
      );

      // Assert
      expect(content.subfolders.length, 100);
      expect(content.hasSubfolders, true);
    });

    test('should handle edge case - many files', () {
      // Arrange
      final manyFiles = List.generate(
        100,
        (i) => GalleryFile(
          id: 'file-$i',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
        ),
      );

      // Act
      final content = FolderContent(
        folder: testFolder,
        subfolders: const [],
        files: manyFiles,
        hasMoreFiles: true,
        totalFilesCount: 0,
      );

      // Assert
      expect(content.files.length, 100);
      expect(content.hasFiles, true);
      expect(content.hasMoreFiles, true);
    });

    test('should have consistent props for Equatable', () {
      // Arrange
      final content = FolderContent(
        folder: testFolder,
        subfolders: testSubfolders,
        files: testFiles,
        hasMoreFiles: true,
        totalFilesCount: 42,
      );

      // Act
      final props = content.props;

      // Assert
      expect(props, [testFolder, testSubfolders, testFiles, true, 42]);
      expect(props.length, 5);
    });
  });
}
