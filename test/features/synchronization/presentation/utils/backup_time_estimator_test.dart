import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/synchronization/presentation/utils/backup_time_estimator.dart';

void main() {
  final start = DateTime(2026, 10, 3, 12);

  group('BackupTimeEstimator', () {
    group('update', () {
      test('should return null on the first update', () {
        // Arrange
        final estimator = BackupTimeEstimator();

        // Act
        final remaining = estimator.update(uploaded: 0, total: 10, now: start);

        // Assert
        expect(remaining, isNull);
      });

      test('should return null until enough files are uploaded', () {
        // Arrange
        final estimator = BackupTimeEstimator()..update(uploaded: 0, total: 10, now: start);

        // Act
        final remaining = estimator.update(uploaded: 2, total: 10, now: start.add(const Duration(seconds: 20)));

        // Assert
        expect(remaining, isNull);
      });

      test('should estimate from the average time per file', () {
        // Arrange
        final estimator = BackupTimeEstimator()..update(uploaded: 0, total: 10, now: start);

        // Act: 4 files in 40 s → 10 s per file, 6 left
        final remaining = estimator.update(uploaded: 4, total: 10, now: start.add(const Duration(seconds: 40)));

        // Assert
        expect(remaining, const Duration(seconds: 60));
      });

      test('should measure from the first progress update, not from zero', () {
        // Arrange: the page opened with 5 files already uploaded
        final estimator = BackupTimeEstimator()..update(uploaded: 5, total: 20, now: start);

        // Act: 3 more files in 30 s → 10 s per file, 12 left
        final remaining = estimator.update(uploaded: 8, total: 20, now: start.add(const Duration(seconds: 30)));

        // Assert
        expect(remaining, const Duration(seconds: 120));
      });

      test('should return null when everything is uploaded', () {
        // Arrange
        final estimator = BackupTimeEstimator()..update(uploaded: 0, total: 4, now: start);

        // Act
        final remaining = estimator.update(uploaded: 4, total: 4, now: start.add(const Duration(seconds: 40)));

        // Assert
        expect(remaining, isNull);
      });
    });

    group('reset', () {
      test('should start measuring again after a reset', () {
        // Arrange
        final estimator = BackupTimeEstimator()..update(uploaded: 0, total: 10, now: start);

        // Act
        estimator.reset();
        final remaining = estimator.update(uploaded: 4, total: 10, now: start.add(const Duration(seconds: 40)));

        // Assert
        expect(remaining, isNull);
      });
    });
  });
}
