import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/synchronization/data/models/synchronization_model.dart';
import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';

void main() {
  group('SynchronizationModel', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should be a subclass of Synchronization entity', () {
      // Arrange
      final model = SynchronizationModel(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      // Assert
      expect(model, isA<Synchronization>());
    });

    test('should create model from JSON', () {
      // Arrange
      final json = {
        'syncSessionId': 123,
        'startedAt': '2024-01-15T10:30:00.000Z',
        'status': 'COMPLETED',
        'syncFiles': 100,
        'uploadedFiles': 100,
        'failedFiles': 0,
      };

      // Act
      final model = SynchronizationModel.fromJson(json);

      // Assert
      expect(model.id, '123');
      expect(model.startedAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
      expect(model.status, SynchronizationStatus.completed);
      expect(model.totalFiles, 100);
      expect(model.uploadedFiles, 100);
      expect(model.failedFiles, 0);
    });

    test('should handle numeric syncSessionId in JSON', () {
      // Arrange
      final json = {
        'syncSessionId': 456,
        'startedAt': '2024-01-15T10:30:00.000Z',
        'status': 'IN_PROGRESS',
        'syncFiles': 50,
        'uploadedFiles': 25,
        'failedFiles': 0,
      };

      // Act
      final model = SynchronizationModel.fromJson(json);

      // Assert
      expect(model.id, '456');
    });

    test('should handle string syncSessionId in JSON', () {
      // Arrange
      final json = {
        'syncSessionId': 'sync-789',
        'startedAt': '2024-01-15T10:30:00.000Z',
        'status': 'FAILED',
        'syncFiles': 100,
        'uploadedFiles': 30,
        'failedFiles': 70,
      };

      // Act
      final model = SynchronizationModel.fromJson(json);

      // Assert
      expect(model.id, 'sync-789');
    });

    test('should parse all status values from JSON', () {
      // Test COMPLETED
      final completedJson = {
        'syncSessionId': '1',
        'startedAt': '2024-01-15T10:30:00.000Z',
        'status': 'COMPLETED',
        'syncFiles': 100,
        'uploadedFiles': 100,
        'failedFiles': 0,
      };
      final completedModel = SynchronizationModel.fromJson(completedJson);
      expect(completedModel.status, SynchronizationStatus.completed);

      // Test IN_PROGRESS
      final inProgressJson = {
        'syncSessionId': '2',
        'startedAt': '2024-01-15T10:30:00.000Z',
        'status': 'IN_PROGRESS',
        'syncFiles': 100,
        'uploadedFiles': 50,
        'failedFiles': 0,
      };
      final inProgressModel = SynchronizationModel.fromJson(inProgressJson);
      expect(inProgressModel.status, SynchronizationStatus.inProgress);

      // Test FAILED
      final failedJson = {
        'syncSessionId': '3',
        'startedAt': '2024-01-15T10:30:00.000Z',
        'status': 'FAILED',
        'syncFiles': 100,
        'uploadedFiles': 30,
        'failedFiles': 70,
      };
      final failedModel = SynchronizationModel.fromJson(failedJson);
      expect(failedModel.status, SynchronizationStatus.failed);

      // Test CANCELLED
      final cancelledJson = {
        'syncSessionId': '4',
        'startedAt': '2024-01-15T10:30:00.000Z',
        'status': 'CANCELLED',
        'syncFiles': 100,
        'uploadedFiles': 40,
        'failedFiles': 0,
      };
      final cancelledModel = SynchronizationModel.fromJson(cancelledJson);
      expect(cancelledModel.status, SynchronizationStatus.cancelled);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final model = SynchronizationModel(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['syncSessionId'], 'sync-1');
      expect(json['startedAt'], testDate.toIso8601String());
      expect(json['status'], 'COMPLETED');
      expect(json['syncFiles'], 100);
      expect(json['uploadedFiles'], 100);
      expect(json['failedFiles'], 0);
    });

    test('should serialize with in progress status', () {
      // Arrange
      final model = SynchronizationModel(
        id: 'sync-2',
        startedAt: testDate,
        status: SynchronizationStatus.inProgress,
        totalFiles: 50,
        uploadedFiles: 25,
        failedFiles: 0,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['status'], 'IN_PROGRESS');
      expect(json['syncFiles'], 50);
      expect(json['uploadedFiles'], 25);
    });

    test('should serialize with failed status', () {
      // Arrange
      final model = SynchronizationModel(
        id: 'sync-3',
        startedAt: testDate,
        status: SynchronizationStatus.failed,
        totalFiles: 100,
        uploadedFiles: 30,
        failedFiles: 70,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['status'], 'FAILED');
      expect(json['failedFiles'], 70);
    });

    test('should perform round-trip conversion', () {
      // Arrange
      final original = SynchronizationModel(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 95,
        failedFiles: 5,
      );

      // Act
      final json = original.toJson();
      final restored = SynchronizationModel.fromJson(json);

      // Assert
      expect(restored.id, original.id);
      expect(restored.startedAt, original.startedAt);
      expect(restored.status, original.status);
      expect(restored.totalFiles, original.totalFiles);
      expect(restored.uploadedFiles, original.uploadedFiles);
      expect(restored.failedFiles, original.failedFiles);
    });

    test('should handle zero files', () {
      // Arrange
      final json = {
        'syncSessionId': 'sync-1',
        'startedAt': '2024-01-15T10:30:00.000Z',
        'status': 'COMPLETED',
        'syncFiles': 0,
        'uploadedFiles': 0,
        'failedFiles': 0,
      };

      // Act
      final model = SynchronizationModel.fromJson(json);

      // Assert
      expect(model.totalFiles, 0);
      expect(model.uploadedFiles, 0);
      expect(model.failedFiles, 0);
    });

    test('should handle large file counts', () {
      // Arrange
      final json = {
        'syncSessionId': 'sync-1',
        'startedAt': '2024-01-15T10:30:00.000Z',
        'status': 'COMPLETED',
        'syncFiles': 10000,
        'uploadedFiles': 9950,
        'failedFiles': 50,
      };

      // Act
      final model = SynchronizationModel.fromJson(json);

      // Assert
      expect(model.totalFiles, 10000);
      expect(model.uploadedFiles, 9950);
      expect(model.failedFiles, 50);
    });

    test('should handle date parsing with different formats', () {
      // Arrange
      final json = {
        'syncSessionId': 'sync-1',
        'startedAt': '2024-01-15T10:30:00Z',
        'status': 'COMPLETED',
        'syncFiles': 100,
        'uploadedFiles': 100,
        'failedFiles': 0,
      };

      // Act
      final model = SynchronizationModel.fromJson(json);

      // Assert
      expect(model.startedAt, DateTime.parse('2024-01-15T10:30:00Z'));
    });

    test('should map field names correctly', () {
      // Arrange
      final json = {
        'syncSessionId': 'test-id', // Maps to id
        'startedAt': '2024-01-15T10:30:00.000Z',
        'status': 'COMPLETED',
        'syncFiles': 100, // Maps to totalFiles
        'uploadedFiles': 100, // Maps to uploadedFiles
        'failedFiles': 0, // Maps to failedFiles
      };

      // Act
      final model = SynchronizationModel.fromJson(json);

      // Assert
      expect(model.id, 'test-id');
      expect(model.totalFiles, 100);
      expect(model.uploadedFiles, 100);
      expect(model.failedFiles, 0);
    });

    test('should map field names correctly in toJson', () {
      // Arrange
      final model = SynchronizationModel(
        id: 'test-id',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json.containsKey('syncSessionId'), true);
      expect(json.containsKey('syncFiles'), true);
      expect(json.containsKey('uploadedFiles'), true);
      expect(json.containsKey('failedFiles'), true);
    });
  });
}
