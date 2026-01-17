import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_result_model.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';

void main() {
  group('SyncResultModel', () {
    const totalFiles = 100;
    const uploadedFiles = 95;
    const failedFiles = 5;

    test('should be a subclass of SyncResult entity', () {
      // Arrange
      final resultModel = SyncResultModel(
        totalFiles: totalFiles,
        uploadedFiles: uploadedFiles,
        failedFiles: failedFiles,
      );

      // Assert
      expect(resultModel, isA<SyncResult>());
    });

    group('fromJson', () {
      test('should create model from JSON with all fields', () {
        // Arrange
        final json = {
          'totalFiles': totalFiles,
          'filesUploaded': uploadedFiles,
          'filesFailed': failedFiles,
        };

        // Act
        final resultModel = SyncResultModel.fromJson(json);

        // Assert
        expect(resultModel.totalFiles, totalFiles);
        expect(resultModel.uploadedFiles, uploadedFiles);
        expect(resultModel.failedFiles, failedFiles);
      });

      test('should handle zero values', () {
        // Arrange
        final json = {
          'totalFiles': 0,
          'filesUploaded': 0,
          'filesFailed': 0,
        };

        // Act
        final resultModel = SyncResultModel.fromJson(json);

        // Assert
        expect(resultModel.totalFiles, 0);
        expect(resultModel.uploadedFiles, 0);
        expect(resultModel.failedFiles, 0);
      });

      test('should handle all files uploaded successfully', () {
        // Arrange
        final json = {
          'totalFiles': 100,
          'filesUploaded': 100,
          'filesFailed': 0,
        };

        // Act
        final resultModel = SyncResultModel.fromJson(json);

        // Assert
        expect(resultModel.isSuccess, true);
        expect(resultModel.hasFailures, false);
      });

      test('should handle all files failed', () {
        // Arrange
        final json = {
          'totalFiles': 50,
          'filesUploaded': 0,
          'filesFailed': 50,
        };

        // Act
        final resultModel = SyncResultModel.fromJson(json);

        // Assert
        expect(resultModel.isSuccess, false);
        expect(resultModel.hasFailures, true);
      });
    });

    group('toJson', () {
      test('should convert model to JSON with all fields', () {
        // Arrange
        final resultModel = SyncResultModel(
          totalFiles: totalFiles,
          uploadedFiles: uploadedFiles,
          failedFiles: failedFiles,
        );

        // Act
        final json = resultModel.toJson();

        // Assert
        expect(json['totalFiles'], totalFiles);
        expect(json['filesUploaded'], uploadedFiles);
        expect(json['filesFailed'], failedFiles);
      });

      test('should handle zero values in JSON conversion', () {
        // Arrange
        final resultModel = SyncResultModel(
          totalFiles: 0,
          uploadedFiles: 0,
          failedFiles: 0,
        );

        // Act
        final json = resultModel.toJson();

        // Assert
        expect(json['totalFiles'], 0);
        expect(json['filesUploaded'], 0);
        expect(json['filesFailed'], 0);
      });
    });

    group('fromEntity', () {
      test('should create model from SyncResult entity', () {
        // Arrange
        final entity = SyncResult(
          totalFiles: totalFiles,
          uploadedFiles: uploadedFiles,
          failedFiles: failedFiles,
        );

        // Act
        final resultModel = SyncResultModel.fromEntity(entity);

        // Assert
        expect(resultModel.totalFiles, entity.totalFiles);
        expect(resultModel.uploadedFiles, entity.uploadedFiles);
        expect(resultModel.failedFiles, entity.failedFiles);
        expect(resultModel, isA<SyncResultModel>());
      });

      test('should create model from empty entity', () {
        // Arrange
        final entity = SyncResult.empty('session_123');

        // Act
        final resultModel = SyncResultModel.fromEntity(entity);

        // Assert
        expect(resultModel.isEmpty, true);
        expect(resultModel.totalFiles, 0);
        expect(resultModel.uploadedFiles, 0);
        expect(resultModel.failedFiles, 0);
      });
    });

    group('JSON round-trip', () {
      test('should maintain data integrity through serialization cycle', () {
        // Arrange
        final originalModel = SyncResultModel(
          totalFiles: totalFiles,
          uploadedFiles: uploadedFiles,
          failedFiles: failedFiles,
        );

        // Act
        final json = originalModel.toJson();
        final deserializedModel = SyncResultModel.fromJson(json);

        // Assert
        expect(deserializedModel.totalFiles, originalModel.totalFiles);
        expect(deserializedModel.uploadedFiles, originalModel.uploadedFiles);
        expect(deserializedModel.failedFiles, originalModel.failedFiles);
      });
    });

    group('entity methods', () {
      test('should calculate success rate correctly from parent entity', () {
        // Arrange
        final resultModel = SyncResultModel(
          totalFiles: 100,
          uploadedFiles: 75,
          failedFiles: 25,
        );

        // Assert
        expect(resultModel.successRate, 75.0); // Success rate is percentage
      });

      test('should identify success state from parent entity', () {
        // Arrange
        final resultModel = SyncResultModel(
          totalFiles: 50,
          uploadedFiles: 50,
          failedFiles: 0,
        );

        // Assert
        expect(resultModel.isSuccess, true);
        expect(resultModel.hasFailures, false);
      });

      test('should identify failure state from parent entity', () {
        // Arrange
        final resultModel = SyncResultModel(
          totalFiles: 100,
          uploadedFiles: 80,
          failedFiles: 20,
        );

        // Assert
        expect(resultModel.hasFailures, true);
        expect(resultModel.isSuccess, false);
      });

      test('should identify empty state from parent entity', () {
        // Arrange
        final resultModel = SyncResultModel(
          totalFiles: 0,
          uploadedFiles: 0,
          failedFiles: 0,
        );

        // Assert
        expect(resultModel.isEmpty, true);
      });
    });
  });
}