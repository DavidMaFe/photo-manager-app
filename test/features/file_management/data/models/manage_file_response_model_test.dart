import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_file_response_model.dart';

void main() {
  group('ManageFileResponseModel', () {
    group('fromJson', () {
      test('should create model from JSON with both successful and failed files', () {
        // Arrange
        final json = {
          'successfulFiles': ['file-1', 'file-2', 'file-3'],
          'failedFiles': ['file-4', 'file-5'],
        };

        // Act
        final model = ManageFileResponseModel.fromJson(json);

        // Assert
        expect(model.successfulIds, ['file-1', 'file-2', 'file-3']);
        expect(model.failedIds, ['file-4', 'file-5']);
      });

      test('should handle all successful files', () {
        // Arrange
        final json = {
          'successfulFiles': ['file-1', 'file-2'],
          'failedFiles': [],
        };

        // Act
        final model = ManageFileResponseModel.fromJson(json);

        // Assert
        expect(model.successfulIds, ['file-1', 'file-2']);
        expect(model.failedIds, isEmpty);
      });

      test('should handle all failed files', () {
        // Arrange
        final json = {
          'successfulFiles': [],
          'failedFiles': ['file-1', 'file-2', 'file-3'],
        };

        // Act
        final model = ManageFileResponseModel.fromJson(json);

        // Assert
        expect(model.successfulIds, isEmpty);
        expect(model.failedIds, ['file-1', 'file-2', 'file-3']);
      });

      test('should handle empty arrays', () {
        // Arrange
        final json = {
          'successfulFiles': [],
          'failedFiles': [],
        };

        // Act
        final model = ManageFileResponseModel.fromJson(json);

        // Assert
        expect(model.successfulIds, isEmpty);
        expect(model.failedIds, isEmpty);
      });

      test('should handle missing successfulFiles field', () {
        // Arrange
        final json = {
          'failedFiles': ['file-1'],
        };

        // Act
        final model = ManageFileResponseModel.fromJson(json);

        // Assert
        expect(model.successfulIds, isEmpty);
        expect(model.failedIds, ['file-1']);
      });

      test('should handle missing failedFiles field', () {
        // Arrange
        final json = {
          'successfulFiles': ['file-1', 'file-2'],
        };

        // Act
        final model = ManageFileResponseModel.fromJson(json);

        // Assert
        expect(model.successfulIds, ['file-1', 'file-2']);
        expect(model.failedIds, isEmpty);
      });

      test('should handle both fields missing', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final model = ManageFileResponseModel.fromJson(json);

        // Assert
        expect(model.successfulIds, isEmpty);
        expect(model.failedIds, isEmpty);
      });

      test('should convert numeric file IDs to strings', () {
        // Arrange
        final json = {
          'successfulFiles': [1, 2, 3],
          'failedFiles': [4, 5],
        };

        // Act
        final model = ManageFileResponseModel.fromJson(json);

        // Assert
        expect(model.successfulIds, ['1', '2', '3']);
        expect(model.failedIds, ['4', '5']);
      });

      test('should handle mixed type file IDs', () {
        // Arrange
        final json = {
          'successfulFiles': ['file-1', 2, 'file-3'],
          'failedFiles': [4, 'file-5'],
        };

        // Act
        final model = ManageFileResponseModel.fromJson(json);

        // Assert
        expect(model.successfulIds, ['file-1', '2', 'file-3']);
        expect(model.failedIds, ['4', 'file-5']);
      });

      test('should handle null values in arrays by converting to string', () {
        // Arrange
        final json = {
          'successfulFiles': ['file-1', null, 'file-3'],
          'failedFiles': [null],
        };

        // Act
        final model = ManageFileResponseModel.fromJson(json);

        // Assert
        expect(model.successfulIds, ['file-1', 'null', 'file-3']);
        expect(model.failedIds, ['null']);
      });
    });

    group('constructor', () {
      test('should create instance with provided lists', () {
        // Arrange & Act
        final model = ManageFileResponseModel(
          successfulIds: ['file-1', 'file-2'],
          failedIds: ['file-3'],
        );

        // Assert
        expect(model.successfulIds, ['file-1', 'file-2']);
        expect(model.failedIds, ['file-3']);
      });

      test('should create instance with empty lists', () {
        // Arrange & Act
        final model = ManageFileResponseModel(
          successfulIds: [],
          failedIds: [],
        );

        // Assert
        expect(model.successfulIds, isEmpty);
        expect(model.failedIds, isEmpty);
      });
    });

    group('round-trip conversion', () {
      test('should maintain data integrity through fromJson', () {
        // Arrange
        final json = {
          'successfulFiles': ['file-1', 'file-2', 'file-3'],
          'failedFiles': ['file-4', 'file-5', 'file-6'],
        };

        // Act
        final model = ManageFileResponseModel.fromJson(json);

        // Assert
        expect(model.successfulIds.length, 3);
        expect(model.failedIds.length, 3);
        expect(model.successfulIds.contains('file-1'), true);
        expect(model.failedIds.contains('file-5'), true);
      });
    });
  });
}
