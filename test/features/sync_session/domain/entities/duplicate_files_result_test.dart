import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/duplicate_files_result.dart';

void main() {
  group('DuplicateFilesResult Entity', () {
    test('should create duplicate files result with all fields', () {
      // Arrange & Act
      final result = DuplicateFilesResult(
        filesToUpload: ['hash1', 'hash2', 'hash3'],
        duplicatesCount: 2,
        totalFiles: 5,
      );

      // Assert
      expect(result.filesToUpload, ['hash1', 'hash2', 'hash3']);
      expect(result.duplicatesCount, 2);
      expect(result.totalFiles, 5);
    });

    test('should create empty duplicate files result', () {
      // Act
      final result = DuplicateFilesResult.empty();

      // Assert
      expect(result.filesToUpload, []);
      expect(result.duplicatesCount, 0);
      expect(result.totalFiles, 0);
    });

    test('hasFilesToUpload should return true when files to upload exist', () {
      // Arrange
      final result = DuplicateFilesResult(
        filesToUpload: ['hash1', 'hash2'],
        duplicatesCount: 3,
        totalFiles: 5,
      );

      // Act & Assert
      expect(result.hasFilesToUpload, true);
    });

    test('hasFilesToUpload should return false when no files to upload', () {
      // Arrange
      final result = DuplicateFilesResult(
        filesToUpload: [],
        duplicatesCount: 5,
        totalFiles: 5,
      );

      // Act & Assert
      expect(result.hasFilesToUpload, false);
    });

    test('allFilesAreDuplicates should return true when all are duplicates', () {
      // Arrange
      final result = DuplicateFilesResult(
        filesToUpload: [],
        duplicatesCount: 10,
        totalFiles: 10,
      );

      // Act & Assert
      expect(result.allFilesAreDuplicates, true);
    });

    test('allFilesAreDuplicates should return false when some files to upload', () {
      // Arrange
      final result = DuplicateFilesResult(
        filesToUpload: ['hash1', 'hash2'],
        duplicatesCount: 3,
        totalFiles: 5,
      );

      // Act & Assert
      expect(result.allFilesAreDuplicates, false);
    });

    test('allFilesAreDuplicates should return false when no duplicates', () {
      // Arrange
      final result = DuplicateFilesResult(
        filesToUpload: ['hash1', 'hash2', 'hash3'],
        duplicatesCount: 0,
        totalFiles: 3,
      );

      // Act & Assert
      expect(result.allFilesAreDuplicates, false);
    });

    test('should handle single file to upload', () {
      // Arrange
      final result = DuplicateFilesResult(
        filesToUpload: ['hash1'],
        duplicatesCount: 4,
        totalFiles: 5,
      );

      // Assert
      expect(result.hasFilesToUpload, true);
      expect(result.filesToUpload.length, 1);
    });

    test('should handle large list of files to upload', () {
      // Arrange
      final largeList = List.generate(1000, (index) => 'hash_$index');
      final result = DuplicateFilesResult(
        filesToUpload: largeList,
        duplicatesCount: 500,
        totalFiles: 1500,
      );

      // Assert
      expect(result.filesToUpload.length, 1000);
      expect(result.hasFilesToUpload, true);
    });

    test('should handle scenario with no duplicates', () {
      // Arrange
      final result = DuplicateFilesResult(
        filesToUpload: ['hash1', 'hash2', 'hash3', 'hash4', 'hash5'],
        duplicatesCount: 0,
        totalFiles: 5,
      );

      // Assert
      expect(result.hasFilesToUpload, true);
      expect(result.allFilesAreDuplicates, false);
      expect(result.filesToUpload.length, 5);
    });

    test('empty result should have no files and no duplicates', () {
      // Arrange
      final result = DuplicateFilesResult.empty();

      // Assert
      expect(result.hasFilesToUpload, false);
      expect(result.allFilesAreDuplicates, false);
      expect(result.totalFiles, 0);
    });
  });
}