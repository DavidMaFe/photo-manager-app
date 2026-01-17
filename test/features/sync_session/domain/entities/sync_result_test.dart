import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';

void main() {
  group('SyncResult Entity', () {
    test('should create sync result with all fields', () {
      // Arrange & Act
      final syncResult = SyncResult(
        totalFiles: 100,
        uploadedFiles: 95,
        failedFiles: 5,
      );

      // Assert
      expect(syncResult.totalFiles, 100);
      expect(syncResult.uploadedFiles, 95);
      expect(syncResult.failedFiles, 5);
    });

    test('should create empty sync result', () {
      // Act
      final syncResult = SyncResult.empty('session_123');

      // Assert
      expect(syncResult.totalFiles, 0);
      expect(syncResult.uploadedFiles, 0);
      expect(syncResult.failedFiles, 0);
    });

    test('isSuccess should return true when no failures and files uploaded', () {
      // Arrange
      final syncResult = SyncResult(
        totalFiles: 10,
        uploadedFiles: 10,
        failedFiles: 0,
      );

      // Act & Assert
      expect(syncResult.isSuccess, true);
    });

    test('isSuccess should return false when there are failures', () {
      // Arrange
      final syncResult = SyncResult(
        totalFiles: 10,
        uploadedFiles: 8,
        failedFiles: 2,
      );

      // Act & Assert
      expect(syncResult.isSuccess, false);
    });

    test('isSuccess should return false when no files uploaded', () {
      // Arrange
      final syncResult = SyncResult(
        totalFiles: 10,
        uploadedFiles: 0,
        failedFiles: 0,
      );

      // Act & Assert
      expect(syncResult.isSuccess, false);
    });

    test('hasFailures should return true when failed files exist', () {
      // Arrange
      final syncResult = SyncResult(
        totalFiles: 10,
        uploadedFiles: 8,
        failedFiles: 2,
      );

      // Act & Assert
      expect(syncResult.hasFailures, true);
    });

    test('hasFailures should return false when no failed files', () {
      // Arrange
      final syncResult = SyncResult(
        totalFiles: 10,
        uploadedFiles: 10,
        failedFiles: 0,
      );

      // Act & Assert
      expect(syncResult.hasFailures, false);
    });

    test('isEmpty should return true when no files uploaded', () {
      // Arrange
      final syncResult = SyncResult(
        totalFiles: 10,
        uploadedFiles: 0,
        failedFiles: 10,
      );

      // Act & Assert
      expect(syncResult.isEmpty, true);
    });

    test('isEmpty should return false when files were uploaded', () {
      // Arrange
      final syncResult = SyncResult(
        totalFiles: 10,
        uploadedFiles: 5,
        failedFiles: 5,
      );

      // Act & Assert
      expect(syncResult.isEmpty, false);
    });

    test('successRate should calculate correctly for full success', () {
      // Arrange
      final syncResult = SyncResult(
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      // Act
      final rate = syncResult.successRate;

      // Assert
      expect(rate, 100.0);
    });

    test('successRate should calculate correctly for partial success', () {
      // Arrange
      final syncResult = SyncResult(
        totalFiles: 100,
        uploadedFiles: 75,
        failedFiles: 25,
      );

      // Act
      final rate = syncResult.successRate;

      // Assert
      expect(rate, 75.0);
    });

    test('successRate should return 0 for zero total files', () {
      // Arrange
      final syncResult = SyncResult(
        totalFiles: 0,
        uploadedFiles: 0,
        failedFiles: 0,
      );

      // Act
      final rate = syncResult.successRate;

      // Assert
      expect(rate, 0.0);
    });

    test('successRate should calculate decimal percentages correctly', () {
      // Arrange
      final syncResult = SyncResult(
        totalFiles: 3,
        uploadedFiles: 2,
        failedFiles: 1,
      );

      // Act
      final rate = syncResult.successRate;

      // Assert
      expect(rate, closeTo(66.67, 0.01));
    });
  });
}