import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/trash/data/models/trash_file_model.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';

void main() {
  group('TrashFileModel', () {
    final testCapturedDate = DateTime(2024, 1, 15, 10, 30);
    final testDeletedDate = DateTime(2024, 1, 25, 14, 20);

    test('should be a subclass of TrashFile entity', () {
      // Arrange
      final model = TrashFileModel(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testCapturedDate,
        deletedAt: testDeletedDate,
        sizeBytes: 1024,
      );

      // Assert
      expect(model, isA<TrashFile>());
    });

    group('fromJson', () {
      test('should create model from JSON with all properties', () {
        // Arrange
        final json = {
          'id': 'trash-1',
          'type': 'IMAGE',
          'status': 'MANAGED',
          'capturedAt': '2024-01-15T10:30:00.000Z',
          'deletedAt': '2024-01-25T14:20:00.000Z',
          'sizeBytes': 2048576,
          'originalFolderId': 'folder-1',
          'originalFolderName': 'Vacations',
        };

        // Act
        final model = TrashFileModel.fromJson(json);

        // Assert
        expect(model.id, 'trash-1');
        expect(model.type, FileType.image);
        expect(model.status, FileStatus.managed);
        expect(model.capturedAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
        expect(model.deletedAt, DateTime.parse('2024-01-25T14:20:00.000Z'));
        expect(model.sizeBytes, 2048576);
        expect(model.originalFolderId, 'folder-1');
        expect(model.originalFolderName, 'Vacations');
      });

      test('should parse JSON with video file and duration', () {
        // Arrange
        final json = {
          'id': 'trash-2',
          'type': 'VIDEO',
          'status': 'MANAGED',
          'capturedAt': '2024-01-15T10:30:00.000Z',
          'deletedAt': '2024-01-25T14:20:00.000Z',
          'sizeBytes': 5242880,
          'durationSeconds': 180,
        };

        // Act
        final model = TrashFileModel.fromJson(json);

        // Assert
        expect(model.id, 'trash-2');
        expect(model.type, FileType.video);
        expect(model.status, FileStatus.managed);
        expect(model.durationSeconds, 180);
        expect(model.sizeBytes, 5242880);
      });

      test('should handle null optional properties', () {
        // Arrange
        final json = {
          'id': 'trash-1',
          'type': 'IMAGE',
          'status': 'MANAGED',
          'capturedAt': '2024-01-15T10:30:00.000Z',
          'deletedAt': '2024-01-25T14:20:00.000Z',
          'sizeBytes': 1024,
        };

        // Act
        final model = TrashFileModel.fromJson(json);

        // Assert
        expect(model.durationSeconds, null);
        expect(model.originalFolderId, null);
        expect(model.originalFolderName, null);
      });

      test('should convert numeric ID to string', () {
        // Arrange
        final json = {
          'id': 12345,
          'type': 'IMAGE',
          'status': 'MANAGED',
          'capturedAt': '2024-01-15T10:30:00.000Z',
          'deletedAt': '2024-01-25T14:20:00.000Z',
          'sizeBytes': 1024,
        };

        // Act
        final model = TrashFileModel.fromJson(json);

        // Assert
        expect(model.id, '12345');
      });

      test('should parse ISO 8601 date strings', () {
        // Arrange
        final json = {
          'id': 'trash-1',
          'type': 'IMAGE',
          'status': 'MANAGED',
          'capturedAt': '2024-01-15T10:30:00.000Z',
          'deletedAt': '2024-01-25T14:20:00.000Z',
          'sizeBytes': 1024,
        };

        // Act
        final model = TrashFileModel.fromJson(json);

        // Assert
        expect(model.capturedAt, isA<DateTime>());
        expect(model.deletedAt, isA<DateTime>());
      });

      test('should handle null originalFolderId', () {
        // Arrange
        final json = {
          'id': 'trash-1',
          'type': 'IMAGE',
          'status': 'MANAGED',
          'capturedAt': '2024-01-15T10:30:00.000Z',
          'deletedAt': '2024-01-25T14:20:00.000Z',
          'sizeBytes': 1024,
          'originalFolderId': null,
        };

        // Act
        final model = TrashFileModel.fromJson(json);

        // Assert
        expect(model.originalFolderId, null);
      });

      test('should handle null originalFolderName', () {
        // Arrange
        final json = {
          'id': 'trash-1',
          'type': 'IMAGE',
          'status': 'MANAGED',
          'capturedAt': '2024-01-15T10:30:00.000Z',
          'deletedAt': '2024-01-25T14:20:00.000Z',
          'sizeBytes': 1024,
          'originalFolderName': null,
        };

        // Act
        final model = TrashFileModel.fromJson(json);

        // Assert
        expect(model.originalFolderName, null);
      });

      test('should convert numeric originalFolderId to string', () {
        // Arrange
        final json = {
          'id': 'trash-1',
          'type': 'IMAGE',
          'status': 'MANAGED',
          'capturedAt': '2024-01-15T10:30:00.000Z',
          'deletedAt': '2024-01-25T14:20:00.000Z',
          'sizeBytes': 1024,
          'originalFolderId': 999,
        };

        // Act
        final model = TrashFileModel.fromJson(json);

        // Assert
        expect(model.originalFolderId, '999');
      });

      test('should handle lowercase enum values', () {
        // Arrange
        final json = {
          'id': 'trash-1',
          'type': 'image',
          'status': 'managed',
          'capturedAt': '2024-01-15T10:30:00.000Z',
          'deletedAt': '2024-01-25T14:20:00.000Z',
          'sizeBytes': 1024,
        };

        // Act
        final model = TrashFileModel.fromJson(json);

        // Assert
        expect(model.type, FileType.image);
        expect(model.status, FileStatus.managed);
      });

      test('should handle different file statuses', () {
        // Arrange
        final json = {
          'id': 'trash-1',
          'type': 'IMAGE',
          'status': 'PENDING',
          'capturedAt': '2024-01-15T10:30:00.000Z',
          'deletedAt': '2024-01-25T14:20:00.000Z',
          'sizeBytes': 1024,
        };

        // Act
        final model = TrashFileModel.fromJson(json);

        // Assert
        expect(model.status, FileStatus.pending);
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly with all properties', () {
        // Arrange
        final model = TrashFileModel(
          id: 'trash-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testCapturedDate,
          deletedAt: testDeletedDate,
          sizeBytes: 2048576,
          originalFolderId: 'folder-1',
          originalFolderName: 'Vacations',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'trash-1');
        expect(json['type'], 'IMAGE');
        expect(json['status'], 'MANAGED');
        expect(json['capturedAt'], testCapturedDate.toIso8601String());
        expect(json['deletedAt'], testDeletedDate.toIso8601String());
        expect(json['sizeBytes'], 2048576);
        expect(json['originalFolderId'], 'folder-1');
        expect(json['originalFolderName'], 'Vacations');
      });

      test('should handle video in JSON serialization', () {
        // Arrange
        final model = TrashFileModel(
          id: 'trash-2',
          type: FileType.video,
          status: FileStatus.pending,
          capturedAt: testCapturedDate,
          deletedAt: testDeletedDate,
          sizeBytes: 5242880,
          durationSeconds: 180,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'trash-2');
        expect(json['type'], 'VIDEO');
        expect(json['status'], 'PENDING');
        expect(json['durationSeconds'], 180);
        expect(json['sizeBytes'], 5242880);
      });

      test('should handle null optional properties in serialization', () {
        // Arrange
        final model = TrashFileModel(
          id: 'trash-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testCapturedDate,
          deletedAt: testDeletedDate,
          sizeBytes: 1024,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['durationSeconds'], null);
        expect(json['originalFolderId'], null);
        expect(json['originalFolderName'], null);
      });

      test('should serialize dates as ISO 8601 strings', () {
        // Arrange
        final model = TrashFileModel(
          id: 'trash-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testCapturedDate,
          deletedAt: testDeletedDate,
          sizeBytes: 1024,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['capturedAt'], isA<String>());
        expect(json['deletedAt'], isA<String>());
        expect(json['capturedAt'], contains('T'));
        expect(json['deletedAt'], contains('T'));
      });

      test('should serialize enum values to uppercase', () {
        // Arrange
        final model = TrashFileModel(
          id: 'trash-1',
          type: FileType.video,
          status: FileStatus.pending,
          capturedAt: testCapturedDate,
          deletedAt: testDeletedDate,
          sizeBytes: 1024,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['type'], 'VIDEO');
        expect(json['status'], 'PENDING');
      });
    });

    group('fromEntity', () {
      test('should create model from entity with all properties', () {
        // Arrange
        final entity = TrashFile(
          id: 'trash-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testCapturedDate,
          deletedAt: testDeletedDate,
          sizeBytes: 2048576,
          originalFolderId: 'folder-1',
          originalFolderName: 'Vacations',
        );

        // Act
        final model = TrashFileModel.fromEntity(entity);

        // Assert
        expect(model.id, 'trash-1');
        expect(model.type, FileType.image);
        expect(model.status, FileStatus.managed);
        expect(model.capturedAt, testCapturedDate);
        expect(model.deletedAt, testDeletedDate);
        expect(model.sizeBytes, 2048576);
        expect(model.originalFolderId, 'folder-1');
        expect(model.originalFolderName, 'Vacations');
      });

      test('should create model from entity with video', () {
        // Arrange
        final entity = TrashFile(
          id: 'trash-2',
          type: FileType.video,
          status: FileStatus.pending,
          capturedAt: testCapturedDate,
          deletedAt: testDeletedDate,
          sizeBytes: 5242880,
          durationSeconds: 180,
        );

        // Act
        final model = TrashFileModel.fromEntity(entity);

        // Assert
        expect(model.id, 'trash-2');
        expect(model.type, FileType.video);
        expect(model.status, FileStatus.pending);
        expect(model.durationSeconds, 180);
        expect(model.sizeBytes, 5242880);
      });

      test('should create model from entity without optional properties', () {
        // Arrange
        final entity = TrashFile(
          id: 'trash-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testCapturedDate,
          deletedAt: testDeletedDate,
          sizeBytes: 1024,
        );

        // Act
        final model = TrashFileModel.fromEntity(entity);

        // Assert
        expect(model.durationSeconds, null);
        expect(model.originalFolderId, null);
        expect(model.originalFolderName, null);
      });
    });

    group('round-trip conversion', () {
      test('should perform round-trip JSON conversion', () {
        // Arrange
        final original = TrashFileModel(
          id: 'trash-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testCapturedDate,
          deletedAt: testDeletedDate,
          sizeBytes: 2048576,
          originalFolderId: 'folder-1',
          originalFolderName: 'Vacations',
        );

        // Act
        final json = original.toJson();
        final restored = TrashFileModel.fromJson(json);

        // Assert
        expect(restored.id, original.id);
        expect(restored.type, original.type);
        expect(restored.status, original.status);
        expect(restored.capturedAt, original.capturedAt);
        expect(restored.deletedAt, original.deletedAt);
        expect(restored.sizeBytes, original.sizeBytes);
        expect(restored.originalFolderId, original.originalFolderId);
        expect(restored.originalFolderName, original.originalFolderName);
      });

      test('should perform round-trip entity conversion', () {
        // Arrange
        final entity = TrashFile(
          id: 'trash-1',
          type: FileType.video,
          status: FileStatus.pending,
          capturedAt: testCapturedDate,
          deletedAt: testDeletedDate,
          sizeBytes: 5242880,
          durationSeconds: 180,
        );

        // Act
        final model = TrashFileModel.fromEntity(entity);
        final json = model.toJson();
        final restored = TrashFileModel.fromJson(json);

        // Assert
        expect(restored.id, entity.id);
        expect(restored.type, entity.type);
        expect(restored.status, entity.status);
        expect(restored.durationSeconds, entity.durationSeconds);
        expect(restored.sizeBytes, entity.sizeBytes);
      });
    });
  });
}
