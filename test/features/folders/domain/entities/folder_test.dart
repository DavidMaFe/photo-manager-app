import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';

void main() {
  group('Folder', () {
    final testDate = DateTime(2024, 1, 15);

    test('should create folder with all properties', () {
      // Arrange & Act
      final folder = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: 'parent-1',
        path: '/root/parent-1/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      // Assert
      expect(folder.id, 'folder-1');
      expect(folder.name, 'Vacation');
      expect(folder.parentFolderId, 'parent-1');
      expect(folder.path, '/root/parent-1/folder-1');
      expect(folder.createdAt, testDate);
      expect(folder.fileCount, 42);
      expect(folder.subfolderCount, 3);
    });

    test('should create folder with null parent (root folder)', () {
      // Arrange & Act
      final folder = Folder(
        id: 'root-1',
        name: 'Root',
        parentFolderId: null,
        path: '/root',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Assert
      expect(folder.parentFolderId, isNull);
    });

    test('should return true for isRoot when parentFolderId is null', () {
      // Arrange
      final folder = Folder(
        id: 'root-1',
        name: 'Root',
        parentFolderId: null,
        path: '/root',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Act & Assert
      expect(folder.isRoot, true);
    });

    test('should return false for isRoot when parentFolderId is not null', () {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: 'parent-1',
        path: '/root/parent-1/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Act & Assert
      expect(folder.isRoot, false);
    });

    test('should return true for hasSubfolders when subfolderCount > 0', () {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 5,
      );

      // Act & Assert
      expect(folder.hasSubfolders, true);
    });

    test('should return false for hasSubfolders when subfolderCount is 0', () {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Act & Assert
      expect(folder.hasSubfolders, false);
    });

    test('should return true for hasFiles when fileCount > 0', () {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 10,
        subfolderCount: 0,
      );

      // Act & Assert
      expect(folder.hasFiles, true);
    });

    test('should return false for hasFiles when fileCount is 0', () {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Act & Assert
      expect(folder.hasFiles, false);
    });

    test('should return true for isEmpty when both counts are 0', () {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Empty',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Act & Assert
      expect(folder.isEmpty, true);
    });

    test('should return false for isEmpty when fileCount > 0', () {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 5,
        subfolderCount: 0,
      );

      // Act & Assert
      expect(folder.isEmpty, false);
    });

    test('should return false for isEmpty when subfolderCount > 0', () {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 3,
      );

      // Act & Assert
      expect(folder.isEmpty, false);
    });

    test('should support Equatable - equal folders', () {
      // Arrange
      final folder1 = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: 'parent-1',
        path: '/root/parent-1/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      final folder2 = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: 'parent-1',
        path: '/root/parent-1/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      // Act & Assert
      expect(folder1, folder2);
      expect(folder1.hashCode, folder2.hashCode);
    });

    test('should support Equatable - different IDs', () {
      // Arrange
      final folder1 = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      final folder2 = Folder(
        id: 'folder-2',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      // Act & Assert
      expect(folder1, isNot(folder2));
    });

    test('should support Equatable - different names', () {
      // Arrange
      final folder1 = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      final folder2 = Folder(
        id: 'folder-1',
        name: 'Work',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      // Act & Assert
      expect(folder1, isNot(folder2));
    });

    test('should handle edge case - negative file count', () {
      // Arrange & Act
      final folder = Folder(
        id: 'folder-1',
        name: 'Test',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: -1,
        subfolderCount: 0,
      );

      // Assert
      expect(folder.fileCount, -1);
      expect(folder.hasFiles, false); // -1 is not > 0
    });

    test('should handle edge case - very long folder name', () {
      // Arrange
      final longName = 'a' * 500;

      // Act
      final folder = Folder(
        id: 'folder-1',
        name: longName,
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Assert
      expect(folder.name, longName);
      expect(folder.name.length, 500);
    });

    test('should handle edge case - special characters in name', () {
      // Arrange
      const specialName = 'Folder @#\$%^&*()';

      // Act
      final folder = Folder(
        id: 'folder-1',
        name: specialName,
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Assert
      expect(folder.name, specialName);
    });

    test('should handle edge case - unicode characters in name', () {
      // Arrange
      const unicodeName = 'Vacaciones 🏖️ 日本';

      // Act
      final folder = Folder(
        id: 'folder-1',
        name: unicodeName,
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Assert
      expect(folder.name, unicodeName);
    });

    test('should handle edge case - very deep folder path', () {
      // Arrange
      const deepPath = '/root/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/folder-1';

      // Act
      final folder = Folder(
        id: 'folder-1',
        name: 'Deep',
        parentFolderId: 'parent-p',
        path: deepPath,
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Assert
      expect(folder.path, deepPath);
    });

    test('should have consistent props for Equatable', () {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Test',
        parentFolderId: 'parent-1',
        path: '/root/parent-1/folder-1',
        createdAt: testDate,
        fileCount: 10,
        subfolderCount: 5,
      );

      // Act
      final props = folder.props;

      // Assert
      expect(props, [
        'folder-1',
        'Test',
        'parent-1',
        '/root/parent-1/folder-1',
        testDate,
        10,
        5,
      ]);
    });
  });
}
