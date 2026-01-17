import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_folder.dart';

void main() {
  group('ManageFolder', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    group('constructor', () {
      test('should create instance with all required fields', () {
        // Arrange & Act
        final folder = ManageFolder(
          id: 'folder-123',
          name: 'Vacation Photos',
          fileCount: 42,
          createdAt: testDate,
        );

        // Assert
        expect(folder.id, 'folder-123');
        expect(folder.name, 'Vacation Photos');
        expect(folder.fileCount, 42);
        expect(folder.createdAt, testDate);
      });

      test('should create instance with zero file count', () {
        // Arrange & Act
        final folder = ManageFolder(
          id: 'folder-empty',
          name: 'Empty Folder',
          fileCount: 0,
          createdAt: testDate,
        );

        // Assert
        expect(folder.fileCount, 0);
      });

      test('should create instance with large file count', () {
        // Arrange & Act
        final folder = ManageFolder(
          id: 'folder-large',
          name: 'Large Folder',
          fileCount: 10000,
          createdAt: testDate,
        );

        // Assert
        expect(folder.fileCount, 10000);
      });

      test('should preserve exact createdAt timestamp', () {
        // Arrange
        final exactTime = DateTime(2024, 3, 20, 14, 25, 30, 500);

        // Act
        final folder = ManageFolder(
          id: 'folder-timestamp',
          name: 'Test Folder',
          fileCount: 5,
          createdAt: exactTime,
        );

        // Assert
        expect(folder.createdAt, exactTime);
        expect(folder.createdAt.millisecond, 500);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final folder1 = ManageFolder(
          id: 'folder-123',
          name: 'My Folder',
          fileCount: 10,
          createdAt: testDate,
        );
        final folder2 = ManageFolder(
          id: 'folder-123',
          name: 'My Folder',
          fileCount: 10,
          createdAt: testDate,
        );

        // Act & Assert
        expect(folder1, folder2);
        expect(folder1.hashCode, folder2.hashCode);
      });

      test('should not be equal when id is different', () {
        // Arrange
        final folder1 = ManageFolder(
          id: 'folder-123',
          name: 'My Folder',
          fileCount: 10,
          createdAt: testDate,
        );
        final folder2 = ManageFolder(
          id: 'folder-456',
          name: 'My Folder',
          fileCount: 10,
          createdAt: testDate,
        );

        // Act & Assert
        expect(folder1, isNot(folder2));
      });

      test('should not be equal when name is different', () {
        // Arrange
        final folder1 = ManageFolder(
          id: 'folder-123',
          name: 'Folder A',
          fileCount: 10,
          createdAt: testDate,
        );
        final folder2 = ManageFolder(
          id: 'folder-123',
          name: 'Folder B',
          fileCount: 10,
          createdAt: testDate,
        );

        // Act & Assert
        expect(folder1, isNot(folder2));
      });

      test('should not be equal when fileCount is different', () {
        // Arrange
        final folder1 = ManageFolder(
          id: 'folder-123',
          name: 'My Folder',
          fileCount: 10,
          createdAt: testDate,
        );
        final folder2 = ManageFolder(
          id: 'folder-123',
          name: 'My Folder',
          fileCount: 20,
          createdAt: testDate,
        );

        // Act & Assert
        expect(folder1, isNot(folder2));
      });

      test('should not be equal when createdAt is different', () {
        // Arrange
        final folder1 = ManageFolder(
          id: 'folder-123',
          name: 'My Folder',
          fileCount: 10,
          createdAt: DateTime(2024, 1, 15),
        );
        final folder2 = ManageFolder(
          id: 'folder-123',
          name: 'My Folder',
          fileCount: 10,
          createdAt: DateTime(2024, 1, 16),
        );

        // Act & Assert
        expect(folder1, isNot(folder2));
      });
    });

    group('edge cases', () {
      test('should handle empty folder name', () {
        // Arrange & Act
        final folder = ManageFolder(
          id: 'folder-empty-name',
          name: '',
          fileCount: 0,
          createdAt: testDate,
        );

        // Assert
        expect(folder.name, '');
      });

      test('should handle folder name with special characters', () {
        // Arrange & Act
        final folder = ManageFolder(
          id: 'folder-special',
          name: 'Photos (2024) - Vacation #1',
          fileCount: 15,
          createdAt: testDate,
        );

        // Assert
        expect(folder.name, 'Photos (2024) - Vacation #1');
      });

      test('should handle very long folder name', () {
        // Arrange
        final longName = 'A' * 500;

        // Act
        final folder = ManageFolder(
          id: 'folder-long',
          name: longName,
          fileCount: 5,
          createdAt: testDate,
        );

        // Assert
        expect(folder.name.length, 500);
      });

      test('should handle negative file count', () {
        // Arrange & Act
        final folder = ManageFolder(
          id: 'folder-negative',
          name: 'Test',
          fileCount: -5,
          createdAt: testDate,
        );

        // Assert
        expect(folder.fileCount, -5);
      });
    });
  });
}
