import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/data/models/duplicate_files_result_model.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/duplicate_files_result.dart';

void main() {
  group('DuplicateFilesResultModel', () {
    final filesToUpload = ['hash1', 'hash2', 'hash3'];
    const duplicatesCount = 2;
    const totalFiles = 5;

    test('should be a subclass of DuplicateFilesResult entity', () {
      // Arrange
      final model = DuplicateFilesResultModel(
        filesToUpload: filesToUpload,
        duplicatesCount: duplicatesCount,
        totalFiles: totalFiles,
      );

      // Assert
      expect(model, isA<DuplicateFilesResult>());
    });

    group('fromJson', () {
      test('should create model from JSON with all fields', () {
        // Arrange
        final json = {
          'filesToUpload': ['hash1', 'hash2', 'hash3'],
          'duplicatedFiles': duplicatesCount,
          'totalFilesToUpload': totalFiles,
        };

        // Act
        final model = DuplicateFilesResultModel.fromJson(json);

        // Assert
        expect(model.filesToUpload, ['hash1', 'hash2', 'hash3']);
        expect(model.duplicatesCount, duplicatesCount);
        expect(model.totalFiles, totalFiles);
      });

      test('should create model from JSON with empty files to upload list', () {
        // Arrange
        final json = {
          'filesToUpload': <String>[],
          'duplicatedFiles': 5,
          'totalFilesToUpload': 5,
        };

        // Act
        final model = DuplicateFilesResultModel.fromJson(json);

        // Assert
        expect(model.filesToUpload, isEmpty);
        expect(model.duplicatesCount, 5);
        expect(model.totalFiles, 5);
        expect(model.allFilesAreDuplicates, true);
      });

      test('should handle JSON with no duplicates', () {
        // Arrange
        final json = {
          'filesToUpload': ['hash1', 'hash2', 'hash3'],
          'duplicatedFiles': 0,
          'totalFilesToUpload': 3,
        };

        // Act
        final model = DuplicateFilesResultModel.fromJson(json);

        // Assert
        expect(model.filesToUpload, ['hash1', 'hash2', 'hash3']);
        expect(model.duplicatesCount, 0);
        expect(model.totalFiles, 3);
      });

      test('should convert list elements to string', () {
        // Arrange
        final json = {
          'filesToUpload': ['hash1', 'hash2', 'hash3'],
          'duplicatedFiles': 0,
          'totalFilesToUpload': 3,
        };

        // Act
        final model = DuplicateFilesResultModel.fromJson(json);

        // Assert
        expect(model.filesToUpload.every((hash) => hash is String), true);
      });
    });

    group('toJson', () {
      test('should convert model to JSON with all fields', () {
        // Arrange
        final model = DuplicateFilesResultModel(
          filesToUpload: filesToUpload,
          duplicatesCount: duplicatesCount,
          totalFiles: totalFiles,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['filesToUpload'], filesToUpload);
        expect(json['duplicatedFiles'], duplicatesCount);
        expect(json['totalFilesToUpload'], totalFiles);
      });

      test('should handle empty files to upload list', () {
        // Arrange
        final model = DuplicateFilesResultModel(
          filesToUpload: [],
          duplicatesCount: 5,
          totalFiles: 5,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['filesToUpload'], isEmpty);
        expect(json['duplicatedFiles'], 5);
        expect(json['totalFilesToUpload'], 5);
      });

      test('should handle zero duplicates', () {
        // Arrange
        final model = DuplicateFilesResultModel(
          filesToUpload: ['hash1', 'hash2'],
          duplicatesCount: 0,
          totalFiles: 2,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['duplicatedFiles'], 0);
      });
    });

    group('fromEntity', () {
      test('should create model from DuplicateFilesResult entity', () {
        // Arrange
        final entity = DuplicateFilesResult(
          filesToUpload: filesToUpload,
          duplicatesCount: duplicatesCount,
          totalFiles: totalFiles,
        );

        // Act
        final model = DuplicateFilesResultModel.fromEntity(entity);

        // Assert
        expect(model.filesToUpload, entity.filesToUpload);
        expect(model.duplicatesCount, entity.duplicatesCount);
        expect(model.totalFiles, entity.totalFiles);
        expect(model, isA<DuplicateFilesResultModel>());
      });

      test('should create model from entity with empty files list', () {
        // Arrange
        final entity = DuplicateFilesResult(
          filesToUpload: [],
          duplicatesCount: 10,
          totalFiles: 10,
        );

        // Act
        final model = DuplicateFilesResultModel.fromEntity(entity);

        // Assert
        expect(model.filesToUpload, isEmpty);
        expect(model.allFilesAreDuplicates, true);
      });
    });

    group('JSON round-trip', () {
      test('should maintain data integrity through serialization cycle', () {
        // Arrange
        final originalModel = DuplicateFilesResultModel(
          filesToUpload: filesToUpload,
          duplicatesCount: duplicatesCount,
          totalFiles: totalFiles,
        );

        // Act
        final json = originalModel.toJson();
        final deserializedModel = DuplicateFilesResultModel.fromJson(json);

        // Assert
        expect(deserializedModel.filesToUpload, originalModel.filesToUpload);
        expect(deserializedModel.duplicatesCount, originalModel.duplicatesCount);
        expect(deserializedModel.totalFiles, originalModel.totalFiles);
      });

      test('should handle empty list through serialization cycle', () {
        // Arrange
        final originalModel = DuplicateFilesResultModel(
          filesToUpload: [],
          duplicatesCount: 5,
          totalFiles: 5,
        );

        // Act
        final json = originalModel.toJson();
        final deserializedModel = DuplicateFilesResultModel.fromJson(json);

        // Assert
        expect(deserializedModel.filesToUpload, isEmpty);
        expect(deserializedModel.duplicatesCount, originalModel.duplicatesCount);
      });
    });

    group('entity methods', () {
      test('should have access to hasFilesToUpload from parent entity', () {
        // Arrange
        final model = DuplicateFilesResultModel(
          filesToUpload: ['hash1', 'hash2'],
          duplicatesCount: 3,
          totalFiles: 5,
        );

        // Assert
        expect(model.hasFilesToUpload, true);
      });

      test('should detect when no files to upload from parent entity', () {
        // Arrange
        final model = DuplicateFilesResultModel(
          filesToUpload: [],
          duplicatesCount: 5,
          totalFiles: 5,
        );

        // Assert
        expect(model.hasFilesToUpload, false);
      });

      test('should detect all duplicates from parent entity', () {
        // Arrange
        final model = DuplicateFilesResultModel(
          filesToUpload: [],
          duplicatesCount: 10,
          totalFiles: 10,
        );

        // Assert
        expect(model.allFilesAreDuplicates, true);
      });

      test('should detect partial duplicates from parent entity', () {
        // Arrange
        final model = DuplicateFilesResultModel(
          filesToUpload: ['hash1'],
          duplicatesCount: 4,
          totalFiles: 5,
        );

        // Assert
        expect(model.allFilesAreDuplicates, false);
        expect(model.hasFilesToUpload, true);
      });
    });
  });
}