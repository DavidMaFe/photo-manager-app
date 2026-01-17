import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_file_result.dart';

void main() {
  group('ManageFileResult', () {
    group('constructor', () {
      test('should create instance with empty lists', () {
        // Arrange & Act
        const result = ManageFileResult(
          successfulIds: [],
          failedIds: [],
        );

        // Assert
        expect(result.successfulIds, isEmpty);
        expect(result.failedIds, isEmpty);
      });

      test('should create instance with successful IDs', () {
        // Arrange & Act
        const result = ManageFileResult(
          successfulIds: ['file-1', 'file-2', 'file-3'],
          failedIds: [],
        );

        // Assert
        expect(result.successfulIds, ['file-1', 'file-2', 'file-3']);
        expect(result.failedIds, isEmpty);
      });

      test('should create instance with failed IDs', () {
        // Arrange & Act
        const result = ManageFileResult(
          successfulIds: [],
          failedIds: ['file-4', 'file-5'],
        );

        // Assert
        expect(result.successfulIds, isEmpty);
        expect(result.failedIds, ['file-4', 'file-5']);
      });

      test('should create instance with both successful and failed IDs', () {
        // Arrange & Act
        const result = ManageFileResult(
          successfulIds: ['file-1', 'file-2'],
          failedIds: ['file-3', 'file-4'],
        );

        // Assert
        expect(result.successfulIds, ['file-1', 'file-2']);
        expect(result.failedIds, ['file-3', 'file-4']);
      });
    });

    group('hasFailures', () {
      test('should return false when no failures', () {
        // Arrange
        const result = ManageFileResult(
          successfulIds: ['file-1', 'file-2'],
          failedIds: [],
        );

        // Act & Assert
        expect(result.hasFailures, false);
      });

      test('should return true when there are failures', () {
        // Arrange
        const result = ManageFileResult(
          successfulIds: ['file-1'],
          failedIds: ['file-2'],
        );

        // Act & Assert
        expect(result.hasFailures, true);
      });

      test('should return true when all failed', () {
        // Arrange
        const result = ManageFileResult(
          successfulIds: [],
          failedIds: ['file-1', 'file-2'],
        );

        // Act & Assert
        expect(result.hasFailures, true);
      });
    });

    group('allSuccessful', () {
      test('should return true when all operations succeeded', () {
        // Arrange
        const result = ManageFileResult(
          successfulIds: ['file-1', 'file-2', 'file-3'],
          failedIds: [],
        );

        // Act & Assert
        expect(result.allSuccessful, true);
      });

      test('should return false when there are failures', () {
        // Arrange
        const result = ManageFileResult(
          successfulIds: ['file-1'],
          failedIds: ['file-2'],
        );

        // Act & Assert
        expect(result.allSuccessful, false);
      });

      test('should return false when both lists are empty', () {
        // Arrange
        const result = ManageFileResult(
          successfulIds: [],
          failedIds: [],
        );

        // Act & Assert
        expect(result.allSuccessful, false);
      });
    });

    group('allFailures', () {
      test('should return true when all operations failed', () {
        // Arrange
        const result = ManageFileResult(
          successfulIds: [],
          failedIds: ['file-1', 'file-2'],
        );

        // Act & Assert
        expect(result.allFailures, true);
      });

      test('should return false when there are successes', () {
        // Arrange
        const result = ManageFileResult(
          successfulIds: ['file-1'],
          failedIds: ['file-2'],
        );

        // Act & Assert
        expect(result.allFailures, false);
      });

      test('should return false when both lists are empty', () {
        // Arrange
        const result = ManageFileResult(
          successfulIds: [],
          failedIds: [],
        );

        // Act & Assert
        expect(result.allFailures, false);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        const result1 = ManageFileResult(
          successfulIds: ['file-1', 'file-2'],
          failedIds: ['file-3'],
        );
        const result2 = ManageFileResult(
          successfulIds: ['file-1', 'file-2'],
          failedIds: ['file-3'],
        );

        // Act & Assert
        expect(result1, result2);
        expect(result1.hashCode, result2.hashCode);
      });

      test('should not be equal when successfulIds are different', () {
        // Arrange
        const result1 = ManageFileResult(
          successfulIds: ['file-1'],
          failedIds: [],
        );
        const result2 = ManageFileResult(
          successfulIds: ['file-2'],
          failedIds: [],
        );

        // Act & Assert
        expect(result1, isNot(result2));
      });

      test('should not be equal when failedIds are different', () {
        // Arrange
        const result1 = ManageFileResult(
          successfulIds: [],
          failedIds: ['file-1'],
        );
        const result2 = ManageFileResult(
          successfulIds: [],
          failedIds: ['file-2'],
        );

        // Act & Assert
        expect(result1, isNot(result2));
      });

      test('should not be equal when list order is different', () {
        // Arrange
        const result1 = ManageFileResult(
          successfulIds: ['file-1', 'file-2'],
          failedIds: [],
        );
        const result2 = ManageFileResult(
          successfulIds: ['file-2', 'file-1'],
          failedIds: [],
        );

        // Act & Assert
        expect(result1, isNot(result2));
      });
    });
  });
}
