import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';

void main() {
  group('TrashFile', () {
    final now = DateTime.now();
    final recentlyDeleted = now.subtract(const Duration(days: 2));
    final deletionImminent = now.subtract(const Duration(days: 25));

    group('constructor', () {
      test('should create TrashFile with all required properties', () {
        // Arrange & Act
        final trashFile = TrashFile(
          id: 'trash-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: DateTime(2024, 1, 15),
          deletedAt: recentlyDeleted,
          sizeBytes: 2048576,
        );

        // Assert
        expect(trashFile.id, 'trash-1');
        expect(trashFile.type, FileType.image);
        expect(trashFile.status, FileStatus.managed);
        expect(trashFile.capturedAt, DateTime(2024, 1, 15));
        expect(trashFile.deletedAt, recentlyDeleted);
        expect(trashFile.sizeBytes, 2048576);
      });

      test('should create TrashFile with optional properties', () {
        // Arrange & Act
        final trashFile = TrashFile(
          id: 'trash-1',
          type: FileType.video,
          status: FileStatus.managed,
          capturedAt: DateTime(2024, 1, 15),
          deletedAt: recentlyDeleted,
          sizeBytes: 52428800,
          durationSeconds: 120,
          originalFolderId: 'folder-1',
          originalFolderName: 'Vacations',
        );

        // Assert
        expect(trashFile.durationSeconds, 120);
        expect(trashFile.originalFolderId, 'folder-1');
        expect(trashFile.originalFolderName, 'Vacations');
      });

      test('should extend GalleryFile', () {
        // Arrange & Act
        final trashFile = TrashFile(
          id: 'trash-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: DateTime(2024, 1, 15),
          deletedAt: recentlyDeleted,
          sizeBytes: 2048576,
        );

        // Assert
        expect(trashFile, isA<GalleryFile>());
      });
    });

    group('daysUntilPermanentDeletion', () {
      test('should calculate days correctly for recently deleted file', () {
        // Arrange
        final deletedAt = now.subtract(const Duration(days: 5));
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: deletedAt,
          sizeBytes: 1024,
        );

        // Act
        final days = trashFile.daysUntilPermanentDeletion;

        // Assert
        expect(days, 25); // 30 - 5 = 25
      });

      test('should return 0 when file is at 30-day limit', () {
        // Arrange
        final deletedAt = now.subtract(const Duration(days: 30));
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: deletedAt,
          sizeBytes: 1024,
        );

        // Act
        final days = trashFile.daysUntilPermanentDeletion;

        // Assert
        expect(days, 0);
      });

      test('should return 0 when file is past 30 days', () {
        // Arrange
        final deletedAt = now.subtract(const Duration(days: 35));
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: deletedAt,
          sizeBytes: 1024,
        );

        // Act
        final days = trashFile.daysUntilPermanentDeletion;

        // Assert
        expect(days, 0); // Negative values are converted to 0
      });

      test('should return 30 when file was just deleted', () {
        // Arrange
        final deletedAt = now;
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: deletedAt,
          sizeBytes: 1024,
        );

        // Act
        final days = trashFile.daysUntilPermanentDeletion;

        // Assert
        expect(days, 30);
      });

      test('should handle edge case of file deleted today', () {
        // Arrange
        final deletedAt = DateTime(now.year, now.month, now.day);
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: deletedAt,
          sizeBytes: 1024,
        );

        // Act
        final days = trashFile.daysUntilPermanentDeletion;

        // Assert
        expect(days, greaterThanOrEqualTo(29));
        expect(days, lessThanOrEqualTo(30));
      });
    });

    group('isDeletionImminent', () {
      test('should return true when less than 7 days remain', () {
        // Arrange
        final deletedAt = now.subtract(const Duration(days: 25));
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: deletedAt,
          sizeBytes: 1024,
        );

        // Act
        final isImminent = trashFile.isDeletionImminent;

        // Assert
        expect(isImminent, true); // 30 - 25 = 5 days (< 7)
      });

      test('should return false when more than 7 days remain', () {
        // Arrange
        final deletedAt = now.subtract(const Duration(days: 22));
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: deletedAt,
          sizeBytes: 1024,
        );

        // Act
        final isImminent = trashFile.isDeletionImminent;

        // Assert
        expect(isImminent, false); // 30 - 22 = 8 days (> 7)
      });

      test('should return true when exactly 7 days remain', () {
        // Arrange
        final deletedAt = now.subtract(const Duration(days: 23));
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: deletedAt,
          sizeBytes: 1024,
        );

        // Act
        final isImminent = trashFile.isDeletionImminent;

        // Assert - isDeletionImminent uses <= 7, so 7 days should return true
        expect(isImminent, true);
      });

      test('should return true when 0 days remain', () {
        // Arrange
        final deletedAt = now.subtract(const Duration(days: 30));
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: deletedAt,
          sizeBytes: 1024,
        );

        // Act
        final isImminent = trashFile.isDeletionImminent;

        // Assert
        expect(isImminent, true); // 0 days <= 7
      });
    });

    group('formattedSize', () {
      test('should format bytes correctly', () {
        // Arrange
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 512,
        );

        // Act
        final formatted = trashFile.formattedSize;

        // Assert
        expect(formatted, '512 B');
      });

      test('should format KB correctly', () {
        // Arrange
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 2048, // 2 KB
        );

        // Act
        final formatted = trashFile.formattedSize;

        // Assert
        expect(formatted, '2.0 KB');
      });

      test('should format MB correctly', () {
        // Arrange
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 2097152, // 2 MB
        );

        // Act
        final formatted = trashFile.formattedSize;

        // Assert
        expect(formatted, '2.0 MB');
      });

      test('should format GB correctly', () {
        // Arrange
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.video,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 2147483648, // 2 GB
        );

        // Act
        final formatted = trashFile.formattedSize;

        // Assert
        expect(formatted, '2.00 GB');
      });

      test('should handle zero bytes', () {
        // Arrange
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 0,
        );

        // Act
        final formatted = trashFile.formattedSize;

        // Assert
        expect(formatted, '0 B');
      });

      test('should handle very large files', () {
        // Arrange
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.video,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 107374182400, // 100 GB
        );

        // Act
        final formatted = trashFile.formattedSize;

        // Assert
        expect(formatted, '100.00 GB');
      });
    });

    group('hasOriginalFolder', () {
      test('should return true when folder ID and name exist', () {
        // Arrange
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
          originalFolderId: 'folder-1',
          originalFolderName: 'Vacations',
        );

        // Act
        final hasFolder = trashFile.hasOriginalFolder;

        // Assert
        expect(hasFolder, true);
      });

      test('should return false when folder ID is null', () {
        // Arrange
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
          originalFolderId: null,
          originalFolderName: 'Vacations',
        );

        // Act
        final hasFolder = trashFile.hasOriginalFolder;

        // Assert
        expect(hasFolder, false);
      });

      test('should return false when folder name is null', () {
        // Arrange
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
          originalFolderId: 'folder-1',
          originalFolderName: null,
        );

        // Act
        final hasFolder = trashFile.hasOriginalFolder;

        // Assert
        expect(hasFolder, false);
      });

      test('should return false when both folder ID and name are null', () {
        // Arrange
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
        );

        // Act
        final hasFolder = trashFile.hasOriginalFolder;

        // Assert
        expect(hasFolder, false);
      });
    });

    group('copyWith', () {
      test('should copy with new id', () {
        // Arrange
        final original = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
        );

        // Act
        final copy = original.copyWith(id: 'file-2');

        // Assert
        expect(copy.id, 'file-2');
        expect(copy.type, original.type);
        expect(copy.deletedAt, original.deletedAt);
      });

      test('should copy with new deletedAt', () {
        // Arrange
        final original = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
        );
        final newDeletedAt = now.subtract(const Duration(days: 10));

        // Act
        final copy = original.copyWith(deletedAt: newDeletedAt);

        // Assert
        expect(copy.deletedAt, newDeletedAt);
        expect(copy.id, original.id);
      });

      test('should copy with new originalFolderId', () {
        // Arrange
        final original = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
        );

        // Act
        final copy = original.copyWith(originalFolderId: 'folder-2');

        // Assert
        expect(copy.originalFolderId, 'folder-2');
      });

      test('should copy with new sizeBytes', () {
        // Arrange
        final original = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
        );

        // Act
        final copy = original.copyWith(sizeBytes: 2048);

        // Assert
        expect(copy.sizeBytes, 2048);
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final file1 = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
        );
        final file2 = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
        );

        // Act & Assert
        expect(file1, equals(file2));
      });

      test('should not be equal when id is different', () {
        // Arrange
        final file1 = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
        );
        final file2 = TrashFile(
          id: 'file-2',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
        );

        // Act & Assert
        expect(file1, isNot(equals(file2)));
      });

      test('should have same hashCode for equal objects', () {
        // Arrange
        final file1 = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
        );
        final file2 = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
        );

        // Act & Assert
        expect(file1.hashCode, equals(file2.hashCode));
      });

      test('should include all properties in props', () {
        // Arrange
        final trashFile = TrashFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: now,
          deletedAt: recentlyDeleted,
          sizeBytes: 1024,
          originalFolderId: 'folder-1',
          originalFolderName: 'Vacations',
        );

        // Act
        final props = trashFile.props;

        // Assert
        expect(props, contains(trashFile.deletedAt));
        expect(props, contains(trashFile.originalFolderId));
        expect(props, contains(trashFile.originalFolderName));
        expect(props, contains(trashFile.sizeBytes));
      });
    });
  });
}
