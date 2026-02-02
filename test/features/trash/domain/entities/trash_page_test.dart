import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_page.dart';

void main() {
  group('TrashPage', () {
    final now = DateTime.now();
    final recentlyDeleted = now.subtract(const Duration(days: 2));

    final testFile1 = TrashFile(
      id: 'file-1',
      type: FileType.image,
      status: FileStatus.managed,
      capturedAt: DateTime(2024, 1, 15),
      deletedAt: recentlyDeleted,
      sizeBytes: 1024,
    );

    final testFile2 = TrashFile(
      id: 'file-2',
      type: FileType.video,
      status: FileStatus.managed,
      capturedAt: DateTime(2024, 1, 10),
      deletedAt: recentlyDeleted,
      sizeBytes: 2048,
      durationSeconds: 120,
    );

    group('constructor', () {
      test('should create TrashPage with all properties', () {
        // Arrange & Act
        final trashPage = TrashPage(
          files: [testFile1, testFile2],
          currentPage: 0,
          pageSize: 50,
          hasNext: true,
        );

        // Assert
        expect(trashPage.files.length, 2);
        expect(trashPage.currentPage, 0);
        expect(trashPage.pageSize, 50);
        expect(trashPage.hasNext, true);
      });

      test('should create TrashPage with empty files list', () {
        // Arrange & Act
        final trashPage = TrashPage(
          files: const [],
          currentPage: 0,
          pageSize: 50,
          hasNext: false,
        );

        // Assert
        expect(trashPage.files, isEmpty);
        expect(trashPage.currentPage, 0);
        expect(trashPage.pageSize, 50);
        expect(trashPage.hasNext, false);
      });
    });

    group('empty factory', () {
      test('should create empty TrashPage', () {
        // Arrange & Act
        final trashPage = TrashPage.empty();

        // Assert
        expect(trashPage.files, isEmpty);
        expect(trashPage.currentPage, 0);
        expect(trashPage.pageSize, 0);
        expect(trashPage.hasNext, false);
      });

      test('should have page 0', () {
        // Arrange & Act
        final trashPage = TrashPage.empty();

        // Assert
        expect(trashPage.currentPage, 0);
      });

      test('should have pageSize 0', () {
        // Arrange & Act
        final trashPage = TrashPage.empty();

        // Assert
        expect(trashPage.pageSize, 0);
      });

      test('should have hasNext false', () {
        // Arrange & Act
        final trashPage = TrashPage.empty();

        // Assert
        expect(trashPage.hasNext, false);
      });
    });

    group('isEmpty', () {
      test('should return true when files is empty', () {
        // Arrange
        final trashPage = TrashPage(
          files: const [],
          currentPage: 0,
          pageSize: 50,
          hasNext: false,
        );

        // Act
        final isEmpty = trashPage.isEmpty;

        // Assert
        expect(isEmpty, true);
      });

      test('should return false when files has items', () {
        // Arrange
        final trashPage = TrashPage(
          files: [testFile1],
          currentPage: 0,
          pageSize: 50,
          hasNext: false,
        );

        // Act
        final isEmpty = trashPage.isEmpty;

        // Assert
        expect(isEmpty, false);
      });
    });

    group('isNotEmpty', () {
      test('should return false when files is empty', () {
        // Arrange
        final trashPage = TrashPage(
          files: const [],
          currentPage: 0,
          pageSize: 50,
          hasNext: false,
        );

        // Act
        final isNotEmpty = trashPage.isNotEmpty;

        // Assert
        expect(isNotEmpty, false);
      });

      test('should return true when files has items', () {
        // Arrange
        final trashPage = TrashPage(
          files: [testFile1, testFile2],
          currentPage: 0,
          pageSize: 50,
          hasNext: false,
        );

        // Act
        final isNotEmpty = trashPage.isNotEmpty;

        // Assert
        expect(isNotEmpty, true);
      });
    });

    group('isFirstPage', () {
      test('should return true when currentPage is 0', () {
        // Arrange
        final trashPage = TrashPage(
          files: [testFile1],
          currentPage: 0,
          pageSize: 50,
          hasNext: true,
        );

        // Act
        final isFirstPage = trashPage.isFirstPage;

        // Assert
        expect(isFirstPage, true);
      });

      test('should return false when currentPage is greater than 0', () {
        // Arrange
        final trashPage = TrashPage(
          files: [testFile1],
          currentPage: 1,
          pageSize: 50,
          hasNext: false,
        );

        // Act
        final isFirstPage = trashPage.isFirstPage;

        // Assert
        expect(isFirstPage, false);
      });
    });

    group('hasPrevious', () {
      test('should return false when currentPage is 0', () {
        // Arrange
        final trashPage = TrashPage(
          files: [testFile1],
          currentPage: 0,
          pageSize: 50,
          hasNext: true,
        );

        // Act
        final hasPrevious = trashPage.hasPrevious;

        // Assert
        expect(hasPrevious, false);
      });

      test('should return true when currentPage is greater than 0', () {
        // Arrange
        final trashPage = TrashPage(
          files: [testFile1],
          currentPage: 1,
          pageSize: 50,
          hasNext: true,
        );

        // Act
        final hasPrevious = trashPage.hasPrevious;

        // Assert
        expect(hasPrevious, true);
      });

      test('should return true when currentPage is 2', () {
        // Arrange
        final trashPage = TrashPage(
          files: [testFile1],
          currentPage: 2,
          pageSize: 50,
          hasNext: false,
        );

        // Act
        final hasPrevious = trashPage.hasPrevious;

        // Assert
        expect(hasPrevious, true);
      });
    });

    group('nextPage', () {
      test('should return currentPage + 1 when hasNext is true', () {
        // Arrange
        final trashPage = TrashPage(
          files: [testFile1],
          currentPage: 0,
          pageSize: 50,
          hasNext: true,
        );

        // Act
        final nextPage = trashPage.nextPage;

        // Assert
        expect(nextPage, 1);
      });

      test('should return null when hasNext is false', () {
        // Arrange
        final trashPage = TrashPage(
          files: [testFile1],
          currentPage: 2,
          pageSize: 50,
          hasNext: false,
        );

        // Act
        final nextPage = trashPage.nextPage;

        // Assert
        expect(nextPage, null);
      });

      test('should return correct next page for page 1', () {
        // Arrange
        final trashPage = TrashPage(
          files: [testFile1],
          currentPage: 1,
          pageSize: 50,
          hasNext: true,
        );

        // Act
        final nextPage = trashPage.nextPage;

        // Assert
        expect(nextPage, 2);
      });
    });

    group('copyWith', () {
      test('should copy with new files', () {
        // Arrange
        final original = TrashPage(
          files: [testFile1],
          currentPage: 0,
          pageSize: 50,
          hasNext: true,
        );

        // Act
        final copy = original.copyWith(files: [testFile1, testFile2]);

        // Assert
        expect(copy.files.length, 2);
        expect(copy.currentPage, original.currentPage);
        expect(copy.pageSize, original.pageSize);
        expect(copy.hasNext, original.hasNext);
      });

      test('should copy with new currentPage', () {
        // Arrange
        final original = TrashPage(
          files: [testFile1],
          currentPage: 0,
          pageSize: 50,
          hasNext: true,
        );

        // Act
        final copy = original.copyWith(currentPage: 1);

        // Assert
        expect(copy.currentPage, 1);
        expect(copy.files, original.files);
        expect(copy.pageSize, original.pageSize);
        expect(copy.hasNext, original.hasNext);
      });

      test('should copy with new pageSize', () {
        // Arrange
        final original = TrashPage(
          files: [testFile1],
          currentPage: 0,
          pageSize: 50,
          hasNext: true,
        );

        // Act
        final copy = original.copyWith(pageSize: 100);

        // Assert
        expect(copy.pageSize, 100);
        expect(copy.files, original.files);
        expect(copy.currentPage, original.currentPage);
        expect(copy.hasNext, original.hasNext);
      });

      test('should copy with new hasNext', () {
        // Arrange
        final original = TrashPage(
          files: [testFile1],
          currentPage: 0,
          pageSize: 50,
          hasNext: true,
        );

        // Act
        final copy = original.copyWith(hasNext: false);

        // Assert
        expect(copy.hasNext, false);
        expect(copy.files, original.files);
        expect(copy.currentPage, original.currentPage);
        expect(copy.pageSize, original.pageSize);
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final page1 = TrashPage(
          files: [testFile1],
          currentPage: 0,
          pageSize: 50,
          hasNext: true,
        );
        final page2 = TrashPage(
          files: [testFile1],
          currentPage: 0,
          pageSize: 50,
          hasNext: true,
        );

        // Act & Assert
        expect(page1, equals(page2));
      });

      test('should not be equal when files differ', () {
        // Arrange
        final page1 = TrashPage(
          files: [testFile1],
          currentPage: 0,
          pageSize: 50,
          hasNext: true,
        );
        final page2 = TrashPage(
          files: [testFile2],
          currentPage: 0,
          pageSize: 50,
          hasNext: true,
        );

        // Act & Assert
        expect(page1, isNot(equals(page2)));
      });

      test('should not be equal when currentPage differs', () {
        // Arrange
        final page1 = TrashPage(
          files: [testFile1],
          currentPage: 0,
          pageSize: 50,
          hasNext: true,
        );
        final page2 = TrashPage(
          files: [testFile1],
          currentPage: 1,
          pageSize: 50,
          hasNext: true,
        );

        // Act & Assert
        expect(page1, isNot(equals(page2)));
      });

      test('should not be equal when hasNext differs', () {
        // Arrange
        final page1 = TrashPage(
          files: [testFile1],
          currentPage: 0,
          pageSize: 50,
          hasNext: true,
        );
        final page2 = TrashPage(
          files: [testFile1],
          currentPage: 0,
          pageSize: 50,
          hasNext: false,
        );

        // Act & Assert
        expect(page1, isNot(equals(page2)));
      });

      test('should include all properties in props', () {
        // Arrange
        final trashPage = TrashPage(
          files: [testFile1, testFile2],
          currentPage: 1,
          pageSize: 50,
          hasNext: true,
        );

        // Act
        final props = trashPage.props;

        // Assert
        expect(props, contains(trashPage.files));
        expect(props, contains(trashPage.currentPage));
        expect(props, contains(trashPage.pageSize));
        expect(props, contains(trashPage.hasNext));
      });
    });
  });
}
