import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';

void main() {
  group('GalleryFile', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should create gallery file entity with all properties', () {
      // Arrange & Act
      final galleryFile = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        durationSeconds: null,
        capturedAt: testDate,
      );

      // Assert
      expect(galleryFile.id, 'file-1');
      expect(galleryFile.type, FileType.image);
      expect(galleryFile.status, FileStatus.managed);
      expect(galleryFile.durationSeconds, null);
      expect(galleryFile.capturedAt, testDate);
    });

    test('should create gallery file with video duration', () {
      // Arrange & Act
      final galleryFile = GalleryFile(
        id: 'file-2',
        type: FileType.video,
        status: FileStatus.managed,
        durationSeconds: 120,
        capturedAt: testDate,
      );

      // Assert
      expect(galleryFile.durationSeconds, 120);
    });

    test('should support Equatable properties', () {
      // Arrange
      final file1 = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      );

      final file2 = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      );

      final file3 = GalleryFile(
        id: 'file-2',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      );

      // Assert
      expect(file1, equals(file2));
      expect(file1, isNot(equals(file3)));
    });

    test('should return true for isImage when type is image', () {
      // Arrange
      final galleryFile = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      );

      // Assert
      expect(galleryFile.isImage, true);
      expect(galleryFile.isVideo, false);
    });

    test('should return true for isVideo when type is video', () {
      // Arrange
      final galleryFile = GalleryFile(
        id: 'file-1',
        type: FileType.video,
        status: FileStatus.managed,
        capturedAt: testDate,
      );

      // Assert
      expect(galleryFile.isVideo, true);
      expect(galleryFile.isImage, false);
    });

    test('should return true for isPending when status is pending', () {
      // Arrange
      final galleryFile = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.pending,
        capturedAt: testDate,
      );

      // Assert
      expect(galleryFile.isPending, true);
      expect(galleryFile.isManaged, false);
    });

    test('should return true for isManaged when status is managed', () {
      // Arrange
      final galleryFile = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      );

      // Assert
      expect(galleryFile.isManaged, true);
      expect(galleryFile.isPending, false);
    });

    test('should create copy with updated properties', () {
      // Arrange
      final original = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.pending,
        durationSeconds: null,
        capturedAt: testDate,
      );

      // Act
      final copy = original.copyWith(
        status: FileStatus.managed,
      );

      // Assert
      expect(copy.id, 'file-1');
      expect(copy.type, FileType.image);
      expect(copy.status, FileStatus.managed);
      expect(copy.durationSeconds, null);
      expect(copy.capturedAt, testDate);
    });

    test('should create copy with all properties updated', () {
      // Arrange
      final original = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.pending,
        durationSeconds: null,
        capturedAt: testDate,
      );

      final newDate = DateTime(2024, 2, 20);

      // Act
      final copy = original.copyWith(
        id: 'file-2',
        type: FileType.video,
        status: FileStatus.managed,
        durationSeconds: 180,
        capturedAt: newDate,
      );

      // Assert
      expect(copy.id, 'file-2');
      expect(copy.type, FileType.video);
      expect(copy.status, FileStatus.managed);
      expect(copy.durationSeconds, 180);
      expect(copy.capturedAt, newDate);
    });

    test('should handle special characters in id', () {
      // Arrange & Act
      final galleryFile = GalleryFile(
        id: 'file-@#\$%',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      );

      // Assert
      expect(galleryFile.id, 'file-@#\$%');
    });

    test('should handle very long id', () {
      // Arrange
      final longId = 'f' * 200;

      // Act
      final galleryFile = GalleryFile(
        id: longId,
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      );

      // Assert
      expect(galleryFile.id, longId);
      expect(galleryFile.id.length, 200);
    });

    test('should handle zero duration for video', () {
      // Arrange & Act
      final galleryFile = GalleryFile(
        id: 'file-1',
        type: FileType.video,
        status: FileStatus.managed,
        durationSeconds: 0,
        capturedAt: testDate,
      );

      // Assert
      expect(galleryFile.durationSeconds, 0);
    });

    test('should handle very long video duration', () {
      // Arrange & Act
      final galleryFile = GalleryFile(
        id: 'file-1',
        type: FileType.video,
        status: FileStatus.managed,
        durationSeconds: 36000, // 10 hours
        capturedAt: testDate,
      );

      // Assert
      expect(galleryFile.durationSeconds, 36000);
    });

    test('should handle past date for capturedAt', () {
      // Arrange
      final pastDate = DateTime(2000, 1, 1);

      // Act
      final galleryFile = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: pastDate,
      );

      // Assert
      expect(galleryFile.capturedAt, pastDate);
    });

    test('should handle future date for capturedAt', () {
      // Arrange
      final futureDate = DateTime(2030, 12, 31);

      // Act
      final galleryFile = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: futureDate,
      );

      // Assert
      expect(galleryFile.capturedAt, futureDate);
    });

    test('should include all properties in props for Equatable', () {
      // Arrange
      final galleryFile = GalleryFile(
        id: 'file-1',
        type: FileType.video,
        status: FileStatus.pending,
        durationSeconds: 120,
        capturedAt: testDate,
      );

      // Assert
      expect(
        galleryFile.props,
        equals(['file-1', FileType.video, FileStatus.pending, 120, testDate, 0, false, const <String>[]]),
      );
    });

    test('should default sizeBytes to 0', () {
      // Arrange & Act
      final galleryFile = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      );

      // Assert
      expect(galleryFile.sizeBytes, 0);
    });

    test('should copy sizeBytes with copyWith', () {
      // Arrange
      final galleryFile = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
        sizeBytes: 100,
      );

      // Act
      final copy = galleryFile.copyWith(sizeBytes: 2048);

      // Assert
      expect(copy.sizeBytes, 2048);
      expect(galleryFile.copyWith().sizeBytes, 100);
    });

    test('should allow a null capturedAt', () {
      // Arrange & Act
      const galleryFile = GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: null,
      );

      // Assert
      expect(galleryFile.capturedAt, isNull);
      expect(galleryFile.copyWith(status: FileStatus.pending).capturedAt, isNull);
    });

    group('favorites and covers', () {
      test('should not be favorite nor cover by default', () {
        // Arrange & Act
        final galleryFile = GalleryFile(id: 'f', type: FileType.image, status: FileStatus.managed, capturedAt: testDate);

        // Assert
        expect(galleryFile.isFavorite, isFalse);
        expect(galleryFile.coverOf, isEmpty);
        expect(galleryFile.isCoverOf('a1'), isFalse);
      });

      test('should tell the albums it is a cover of', () {
        // Arrange
        final galleryFile = GalleryFile(
          id: 'f',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
          coverOf: const ['root', 'beach'],
        );

        // Assert
        expect(galleryFile.isCoverOf('beach'), isTrue);
        expect(galleryFile.isCoverOf('sunsets'), isFalse);
      });

      test('should copy isFavorite and coverOf', () {
        // Arrange
        final galleryFile = GalleryFile(id: 'f', type: FileType.image, status: FileStatus.managed, capturedAt: testDate);

        // Act
        final copy = galleryFile.copyWith(isFavorite: true, coverOf: const ['a1']);

        // Assert
        expect(copy.isFavorite, isTrue);
        expect(copy.coverOf, ['a1']);
        expect(copy.copyWith(sizeBytes: 1).isFavorite, isTrue);
        expect(copy == galleryFile, isFalse);
      });
    });
  });
}
