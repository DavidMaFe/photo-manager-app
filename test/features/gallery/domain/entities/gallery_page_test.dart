import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_page.dart';

void main() {
  group('GalleryPage', () {
    final testDate = DateTime(2024, 1, 15);

    final testFiles = [
      GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      ),
      GalleryFile(
        id: 'file-2',
        type: FileType.video,
        status: FileStatus.pending,
        durationSeconds: 120,
        capturedAt: testDate,
      ),
    ];

    test('should create gallery page entity with all properties', () {
      // Arrange & Act
      final galleryPage = GalleryPage(
        files: testFiles,
        currentPage: 0,
        pageSize: 50,
        hasNext: true,
      );

      // Assert
      expect(galleryPage.files, testFiles);
      expect(galleryPage.currentPage, 0);
      expect(galleryPage.pageSize, 50);
      expect(galleryPage.hasNext, true);
    });

    test('should create empty gallery page', () {
      // Arrange & Act
      final galleryPage = GalleryPage.empty();

      // Assert
      expect(galleryPage.files, isEmpty);
      expect(galleryPage.currentPage, 0);
      expect(galleryPage.pageSize, 0);
      expect(galleryPage.hasNext, false);
    });

    test('should support Equatable properties', () {
      // Arrange
      final page1 = GalleryPage(
        files: testFiles,
        currentPage: 0,
        pageSize: 50,
        hasNext: true,
      );

      final page2 = GalleryPage(
        files: testFiles,
        currentPage: 0,
        pageSize: 50,
        hasNext: true,
      );

      final page3 = GalleryPage(
        files: testFiles,
        currentPage: 1,
        pageSize: 50,
        hasNext: false,
      );

      // Assert
      expect(page1, equals(page2));
      expect(page1, isNot(equals(page3)));
    });

    test('should return true for isEmpty when files list is empty', () {
      // Arrange
      final galleryPage = GalleryPage(
        files: const [],
        currentPage: 0,
        pageSize: 50,
        hasNext: false,
      );

      // Assert
      expect(galleryPage.isEmpty, true);
      expect(galleryPage.isNotEmpty, false);
    });

    test('should return true for isNotEmpty when files list has items', () {
      // Arrange
      final galleryPage = GalleryPage(
        files: testFiles,
        currentPage: 0,
        pageSize: 50,
        hasNext: true,
      );

      // Assert
      expect(galleryPage.isNotEmpty, true);
      expect(galleryPage.isEmpty, false);
    });

    test('should return true for isFirstPage when currentPage is 0', () {
      // Arrange
      final galleryPage = GalleryPage(
        files: testFiles,
        currentPage: 0,
        pageSize: 50,
        hasNext: true,
      );

      // Assert
      expect(galleryPage.isFirstPage, true);
    });

    test('should return false for isFirstPage when currentPage is greater than 0', () {
      // Arrange
      final galleryPage = GalleryPage(
        files: testFiles,
        currentPage: 2,
        pageSize: 50,
        hasNext: true,
      );

      // Assert
      expect(galleryPage.isFirstPage, false);
    });

    test('should return true for hasPrevious when currentPage is greater than 0', () {
      // Arrange
      final galleryPage = GalleryPage(
        files: testFiles,
        currentPage: 3,
        pageSize: 50,
        hasNext: true,
      );

      // Assert
      expect(galleryPage.hasPrevious, true);
    });

    test('should return false for hasPrevious when currentPage is 0', () {
      // Arrange
      final galleryPage = GalleryPage(
        files: testFiles,
        currentPage: 0,
        pageSize: 50,
        hasNext: true,
      );

      // Assert
      expect(galleryPage.hasPrevious, false);
    });

    test('should return nextPage number when hasNext is true', () {
      // Arrange
      final galleryPage = GalleryPage(
        files: testFiles,
        currentPage: 2,
        pageSize: 50,
        hasNext: true,
      );

      // Assert
      expect(galleryPage.nextPage, 3);
    });

    test('should return null for nextPage when hasNext is false', () {
      // Arrange
      final galleryPage = GalleryPage(
        files: testFiles,
        currentPage: 2,
        pageSize: 50,
        hasNext: false,
      );

      // Assert
      expect(galleryPage.nextPage, null);
    });

    test('should create copy with updated files', () {
      // Arrange
      final original = GalleryPage(
        files: testFiles,
        currentPage: 0,
        pageSize: 50,
        hasNext: true,
      );

      final newFiles = [
        GalleryFile(
          id: 'file-3',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
        ),
      ];

      // Act
      final copy = original.copyWith(files: newFiles);

      // Assert
      expect(copy.files, newFiles);
      expect(copy.currentPage, 0);
      expect(copy.pageSize, 50);
      expect(copy.hasNext, true);
    });

    test('should create copy with all properties updated', () {
      // Arrange
      final original = GalleryPage(
        files: testFiles,
        currentPage: 0,
        pageSize: 50,
        hasNext: true,
      );

      final newFiles = [
        GalleryFile(
          id: 'file-3',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
        ),
      ];

      // Act
      final copy = original.copyWith(
        files: newFiles,
        currentPage: 2,
        pageSize: 100,
        hasNext: false,
      );

      // Assert
      expect(copy.files, newFiles);
      expect(copy.currentPage, 2);
      expect(copy.pageSize, 100);
      expect(copy.hasNext, false);
    });

    test('should handle page with many files', () {
      // Arrange
      final manyFiles = List.generate(
        100,
        (index) => GalleryFile(
          id: 'file-$index',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
        ),
      );

      // Act
      final galleryPage = GalleryPage(
        files: manyFiles,
        currentPage: 5,
        pageSize: 100,
        hasNext: true,
      );

      // Assert
      expect(galleryPage.files.length, 100);
      expect(galleryPage.isNotEmpty, true);
    });

    test('should handle large page size', () {
      // Arrange & Act
      final galleryPage = GalleryPage(
        files: testFiles,
        currentPage: 0,
        pageSize: 1000,
        hasNext: false,
      );

      // Assert
      expect(galleryPage.pageSize, 1000);
    });

    test('should handle high page number', () {
      // Arrange & Act
      final galleryPage = GalleryPage(
        files: testFiles,
        currentPage: 999,
        pageSize: 50,
        hasNext: true,
      );

      // Assert
      expect(galleryPage.currentPage, 999);
      expect(galleryPage.nextPage, 1000);
      expect(galleryPage.hasPrevious, true);
      expect(galleryPage.isFirstPage, false);
    });

    test('should include all properties in props for Equatable', () {
      // Arrange
      final galleryPage = GalleryPage(
        files: testFiles,
        currentPage: 2,
        pageSize: 50,
        hasNext: true,
      );

      // Assert
      expect(
        galleryPage.props,
        equals([testFiles, 2, 50, true]),
      );
    });

    test('should handle single file in page', () {
      // Arrange
      final singleFile = [
        GalleryFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
        ),
      ];

      // Act
      final galleryPage = GalleryPage(
        files: singleFile,
        currentPage: 0,
        pageSize: 50,
        hasNext: false,
      );

      // Assert
      expect(galleryPage.files.length, 1);
      expect(galleryPage.isNotEmpty, true);
      expect(galleryPage.isEmpty, false);
    });
  });
}
