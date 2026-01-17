import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';

void main() {
  group('Synchronization', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should create synchronization entity with all properties', () {
      // Arrange & Act
      final synchronization = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 95,
        failedFiles: 5,
      );

      // Assert
      expect(synchronization.id, 'sync-1');
      expect(synchronization.startedAt, testDate);
      expect(synchronization.status, SynchronizationStatus.completed);
      expect(synchronization.totalFiles, 100);
      expect(synchronization.uploadedFiles, 95);
      expect(synchronization.failedFiles, 5);
    });

    test('should support Equatable properties', () {
      // Arrange
      final sync1 = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      final sync2 = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      final sync3 = Synchronization(
        id: 'sync-2',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      // Assert
      expect(sync1, equals(sync2));
      expect(sync1, isNot(equals(sync3)));
    });

    test('should return true for isCompleted when status is completed', () {
      // Arrange
      final synchronization = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      // Assert
      expect(synchronization.isCompleted, true);
      expect(synchronization.isInProgress, false);
      expect(synchronization.hasFailed, false);
    });

    test('should return true for isInProgress when status is inProgress', () {
      // Arrange
      final synchronization = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.inProgress,
        totalFiles: 100,
        uploadedFiles: 50,
        failedFiles: 0,
      );

      // Assert
      expect(synchronization.isInProgress, true);
      expect(synchronization.isCompleted, false);
      expect(synchronization.hasFailed, false);
    });

    test('should return true for hasFailed when status is failed', () {
      // Arrange
      final synchronization = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.failed,
        totalFiles: 100,
        uploadedFiles: 30,
        failedFiles: 70,
      );

      // Assert
      expect(synchronization.hasFailed, true);
      expect(synchronization.isCompleted, false);
      expect(synchronization.isInProgress, false);
    });

    test('should handle cancelled status', () {
      // Arrange
      final synchronization = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.cancelled,
        totalFiles: 100,
        uploadedFiles: 40,
        failedFiles: 0,
      );

      // Assert
      expect(synchronization.status, SynchronizationStatus.cancelled);
      expect(synchronization.hasFailed, false);
      expect(synchronization.isCompleted, false);
      expect(synchronization.isInProgress, false);
    });

    test('should handle zero uploaded files', () {
      // Arrange
      final synchronization = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.inProgress,
        totalFiles: 100,
        uploadedFiles: 0,
        failedFiles: 0,
      );

      // Assert
      expect(synchronization.uploadedFiles, 0);
      expect(synchronization.failedFiles, 0);
    });

    test('should handle zero failed files', () {
      // Arrange
      final synchronization = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      // Assert
      expect(synchronization.failedFiles, 0);
    });

    test('should handle all files failed', () {
      // Arrange
      final synchronization = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.failed,
        totalFiles: 100,
        uploadedFiles: 0,
        failedFiles: 100,
      );

      // Assert
      expect(synchronization.failedFiles, 100);
      expect(synchronization.uploadedFiles, 0);
    });

    test('should handle special characters in id', () {
      // Arrange & Act
      final synchronization = Synchronization(
        id: 'sync-@#\$%',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 10,
        uploadedFiles: 10,
        failedFiles: 0,
      );

      // Assert
      expect(synchronization.id, 'sync-@#\$%');
    });

    test('should handle very long id', () {
      // Arrange
      final longId = 's' * 200;

      // Act
      final synchronization = Synchronization(
        id: longId,
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 10,
        uploadedFiles: 10,
        failedFiles: 0,
      );

      // Assert
      expect(synchronization.id, longId);
      expect(synchronization.id.length, 200);
    });

    test('should handle large file counts', () {
      // Arrange & Act
      final synchronization = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 10000,
        uploadedFiles: 9950,
        failedFiles: 50,
      );

      // Assert
      expect(synchronization.totalFiles, 10000);
      expect(synchronization.uploadedFiles, 9950);
      expect(synchronization.failedFiles, 50);
    });

    test('should handle past date for startedAt', () {
      // Arrange
      final pastDate = DateTime(2000, 1, 1);

      // Act
      final synchronization = Synchronization(
        id: 'sync-1',
        startedAt: pastDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      // Assert
      expect(synchronization.startedAt, pastDate);
    });

    test('should handle future date for startedAt', () {
      // Arrange
      final futureDate = DateTime(2030, 12, 31);

      // Act
      final synchronization = Synchronization(
        id: 'sync-1',
        startedAt: futureDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      // Assert
      expect(synchronization.startedAt, futureDate);
    });

    test('should include all properties in props for Equatable', () {
      // Arrange
      final synchronization = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.inProgress,
        totalFiles: 100,
        uploadedFiles: 50,
        failedFiles: 5,
      );

      // Assert
      expect(
        synchronization.props,
        equals(['sync-1', testDate, SynchronizationStatus.inProgress, 100, 50, 5]),
      );
    });

    test('should handle single file synchronization', () {
      // Arrange & Act
      final synchronization = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 1,
        uploadedFiles: 1,
        failedFiles: 0,
      );

      // Assert
      expect(synchronization.totalFiles, 1);
      expect(synchronization.uploadedFiles, 1);
    });
  });
}
