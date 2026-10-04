import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/gallery/data/models/gallery_file_model.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';

void main() {
  group('GalleryFileModel', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should be a subclass of GalleryFile entity', () {
      // Arrange
      final model = GalleryFileModel(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      );

      // Assert
      expect(model, isA<GalleryFile>());
    });

    test('should create model from JSON with image file', () {
      // Arrange
      final json = {
        'id': 123,
        'type': 'IMAGE',
        'status': 'MANAGED',
        'capturedAt': '2024-01-15T10:30:00.000Z',
      };

      // Act
      final model = GalleryFileModel.fromJson(json);

      // Assert
      expect(model.id, '123');
      expect(model.type, FileType.image);
      expect(model.status, FileStatus.managed);
      expect(model.durationSeconds, null);
      expect(model.capturedAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
    });

    test('should parse JSON with video file and duration', () {
      // Arrange
      final json = {
        'id': 456,
        'type': 'VIDEO',
        'status': 'MANAGED',
        'durationSeconds': 180,
        'capturedAt': '2024-01-15T10:30:00.000Z',
      };

      // Act
      final model = GalleryFileModel.fromJson(json);

      // Assert
      expect(model.id, '456');
      expect(model.type, FileType.video);
      expect(model.status, FileStatus.managed);
      expect(model.durationSeconds, 180);
      expect(model.capturedAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
    });

    test('should handle null durationSeconds in JSON', () {
      // Arrange
      final json = {
        'id': 'file-1',
        'type': 'IMAGE',
        'status': 'MANAGED',
        'capturedAt': '2024-01-15T10:30:00.000Z',
      };

      // Act
      final model = GalleryFileModel.fromJson(json);

      // Assert
      expect(model.durationSeconds, null);
    });

    test('should handle numeric id in fromJson', () {
      // Arrange
      final json = {
        'id': 12345,
        'type': 'IMAGE',
        'status': 'MANAGED',
        'capturedAt': '2024-01-15T10:30:00.000Z',
      };

      // Act
      final model = GalleryFileModel.fromJson(json);

      // Assert
      expect(model.id, '12345');
    });

    test('should ignore the old misspelled key durationSecionds', () {
      // Arrange
      final json = {
        'id': 'file-1',
        'type': 'VIDEO',
        'status': 'MANAGED',
        'durationSecionds': 120,
        'capturedAt': '2024-01-15T10:30:00.000Z',
      };

      // Act
      final model = GalleryFileModel.fromJson(json);

      // Assert
      expect(model.durationSeconds, null);
    });

    test('should parse sizeBytes when present', () {
      // Arrange
      final json = {
        'id': 'file-1',
        'type': 'IMAGE',
        'status': 'MANAGED',
        'sizeBytes': 2457600,
        'capturedAt': '2024-01-15T10:30:00.000Z',
      };

      // Act
      final model = GalleryFileModel.fromJson(json);

      // Assert
      expect(model.sizeBytes, 2457600);
    });

    test('should default sizeBytes to 0 when missing', () {
      // Arrange
      final json = {
        'id': 'file-1',
        'type': 'IMAGE',
        'status': 'MANAGED',
        'capturedAt': '2024-01-15T10:30:00.000Z',
      };

      // Act
      final model = GalleryFileModel.fromJson(json);

      // Assert
      expect(model.sizeBytes, 0);
    });

    test('should parse null capturedAt as null', () {
      // Arrange
      final json = {
        'id': 'file-1',
        'type': 'IMAGE',
        'status': 'MANAGED',
        'capturedAt': null,
      };

      // Act
      final model = GalleryFileModel.fromJson(json);

      // Assert
      expect(model.capturedAt, isNull);
    });

    test('should parse missing capturedAt as null', () {
      // Arrange
      final json = {'id': 'file-1', 'type': 'IMAGE', 'status': 'MANAGED'};

      // Act
      final model = GalleryFileModel.fromJson(json);

      // Assert
      expect(model.capturedAt, isNull);
    });

    test('should parse local date without time zone without converting it', () {
      // Arrange: the server sends local time with no offset
      final json = {
        'id': 'file-1',
        'type': 'IMAGE',
        'status': 'MANAGED',
        'capturedAt': '2026-10-03T03:00:00',
      };

      // Act
      final model = GalleryFileModel.fromJson(json);

      // Assert
      expect(model.capturedAt, DateTime(2026, 10, 3, 3));
      expect(model.capturedAt!.isUtc, isFalse);
    });

    test('should serialize null capturedAt and sizeBytes in toJson', () {
      // Arrange
      const model = GalleryFileModel(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: null,
        sizeBytes: 1024,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['capturedAt'], isNull);
      expect(json['sizeBytes'], 1024);
    });

    test('should convert to JSON correctly', () {
      // Arrange
      final model = GalleryFileModel(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        durationSeconds: null,
        capturedAt: testDate,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], 'file-1');
      expect(json['type'], 'IMAGE');
      expect(json['status'], 'MANAGED');
      expect(json['durationSeconds'], null);
      expect(json['capturedAt'], testDate.toIso8601String());
    });

    test('should handle video in JSON serialization', () {
      // Arrange
      final model = GalleryFileModel(
        id: 'file-2',
        type: FileType.video,
        status: FileStatus.pending,
        durationSeconds: 180,
        capturedAt: testDate,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], 'file-2');
      expect(json['type'], 'VIDEO');
      expect(json['status'], 'PENDING');
      expect(json['durationSeconds'], 180);
      expect(json['capturedAt'], testDate.toIso8601String());
    });

    test('should create model from entity', () {
      // Arrange
      final entity = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        durationSeconds: null,
        capturedAt: testDate,
      );

      // Act
      final model = GalleryFileModel.fromEntity(entity);

      // Assert
      expect(model.id, 'file-1');
      expect(model.type, FileType.image);
      expect(model.status, FileStatus.managed);
      expect(model.durationSeconds, null);
      expect(model.capturedAt, testDate);
    });

    test('should create model from entity with all properties', () {
      // Arrange
      final entity = GalleryFile(
        id: 'file-1',
        type: FileType.video,
        status: FileStatus.pending,
        durationSeconds: 180,
        capturedAt: testDate,
      );

      // Act
      final model = GalleryFileModel.fromEntity(entity);

      // Assert
      expect(model.id, 'file-1');
      expect(model.type, FileType.video);
      expect(model.status, FileStatus.pending);
      expect(model.durationSeconds, 180);
      expect(model.capturedAt, testDate);
    });

    test('should read durationSeconds key', () {
      // Arrange
      final json = {
        'id': '123',
        'type': 'VIDEO',
        'status': 'MANAGED',
        'durationSeconds': 150,
        'capturedAt': testDate.toIso8601String(),
      };

      // Act
      final model = GalleryFileModel.fromJson(json);

      // Assert
      expect(model.durationSeconds, 150);
    });

    test('should handle missing durationSeconds field in JSON', () {
      // Arrange
      final json = {
        'id': 'file-1',
        'type': 'IMAGE',
        'status': 'MANAGED',
        'capturedAt': '2024-01-15T10:30:00.000Z',
      };

      // Act
      final model = GalleryFileModel.fromJson(json);

      // Assert
      expect(model.durationSeconds, null);
    });

    test('should handle numeric id in JSON', () {
      // Arrange
      final json = {
        'id': 12345,
        'type': 'IMAGE',
        'status': 'MANAGED',
        'capturedAt': '2024-01-15T10:30:00Z',
      };

      // Act
      final model = GalleryFileModel.fromJson(json);

      // Assert
      expect(model.id, '12345');
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final model = GalleryFileModel(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        durationSeconds: null,
        capturedAt: testDate,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], 'file-1');
      expect(json['type'], 'IMAGE');
      expect(json['status'], 'MANAGED');
      expect(json['durationSeconds'], null);
      expect(json['capturedAt'], testDate.toIso8601String());
    });

    test('should serialize video with duration to JSON', () {
      // Arrange
      final model = GalleryFileModel(
        id: 'file-2',
        type: FileType.video,
        status: FileStatus.pending,
        durationSeconds: 120,
        capturedAt: testDate,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], 'file-2');
      expect(json['type'], 'VIDEO');
      expect(json['status'], 'PENDING');
      expect(json['durationSeconds'], 120);
    });

    test('should perform round-trip conversion', () {
      // Arrange
      final original = GalleryFileModel(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        durationSeconds: null,
        capturedAt: testDate,
      );

      // Act
      final json = original.toJson();
      final restored = GalleryFileModel.fromJson(json);

      // Assert
      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.status, original.status);
      expect(restored.durationSeconds, original.durationSeconds);
      expect(restored.capturedAt, original.capturedAt);
    });

    test('should create from entity', () {
      // Arrange
      final entity = GalleryFile(
        id: 'file-1',
        type: FileType.video,
        status: FileStatus.pending,
        durationSeconds: 180,
        capturedAt: testDate,
      );

      // Act
      final model = GalleryFileModel.fromEntity(entity);

      // Assert
      expect(model.id, entity.id);
      expect(model.type, entity.type);
      expect(model.status, entity.status);
      expect(model.durationSeconds, entity.durationSeconds);
      expect(model.capturedAt, entity.capturedAt);
    });

    test('should create from entity without duration', () {
      // Arrange
      final entity = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      );

      // Act
      final model = GalleryFileModel.fromEntity(entity);

      // Assert
      expect(model.durationSeconds, null);
    });
  });
}
