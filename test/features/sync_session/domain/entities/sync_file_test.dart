import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';

void main() {
  group('SyncFile Entity', () {
    test('should create sync file with all fields', () {
      // Arrange
      final capturedAt = DateTime(2024, 1, 15, 10, 30);

      // Act
      final syncFile = SyncFile(
        localId: 'local_123',
        devicePath: '/storage/emulated/0/DCIM/photo.jpg',
        hash: 'abc123hash',
        fileName: 'photo.jpg',
        sizeBytes: 1048576,
        capturedAt: capturedAt,
        mimeType: 'image/jpeg',
        width: 1920,
        height: 1080,
        durationSeconds: null,
      );

      // Assert
      expect(syncFile.localId, 'local_123');
      expect(syncFile.devicePath, '/storage/emulated/0/DCIM/photo.jpg');
      expect(syncFile.hash, 'abc123hash');
      expect(syncFile.fileName, 'photo.jpg');
      expect(syncFile.sizeBytes, 1048576);
      expect(syncFile.capturedAt, capturedAt);
      expect(syncFile.mimeType, 'image/jpeg');
      expect(syncFile.width, 1920);
      expect(syncFile.height, 1080);
      expect(syncFile.durationSeconds, null);
    });

    test('should create sync file with video metadata', () {
      // Arrange & Act
      final syncFile = SyncFile(
        localId: 'local_456',
        devicePath: '/storage/video.mp4',
        hash: 'def456hash',
        fileName: 'video.mp4',
        sizeBytes: 10485760,
        capturedAt: DateTime(2024, 1, 15),
        mimeType: 'video/mp4',
        width: 1920,
        height: 1080,
        durationSeconds: 120,
      );

      // Assert
      expect(syncFile.durationSeconds, 120);
      expect(syncFile.isVideo, true);
      expect(syncFile.isImage, false);
    });

    test('should create sync file without optional dimensions', () {
      // Arrange & Act
      final syncFile = SyncFile(
        localId: 'local_789',
        devicePath: '/storage/file.dat',
        hash: 'ghi789hash',
        fileName: 'file.dat',
        sizeBytes: 512,
        capturedAt: DateTime(2024, 1, 15),
        mimeType: 'application/octet-stream',
      );

      // Assert
      expect(syncFile.width, null);
      expect(syncFile.height, null);
      expect(syncFile.durationSeconds, null);
    });

    test('file getter should return File instance', () {
      // Arrange
      final syncFile = SyncFile(
        localId: 'local_123',
        devicePath: '/storage/photo.jpg',
        hash: 'hash123',
        fileName: 'photo.jpg',
        sizeBytes: 1024,
        capturedAt: DateTime(2024, 1, 15),
        mimeType: 'image/jpeg',
      );

      // Act
      final file = syncFile.file;

      // Assert
      expect(file.path, '/storage/photo.jpg');
    });

    test('isImage should return true for image mime types', () {
      // Arrange
      final syncFile = SyncFile(
        localId: 'local_123',
        devicePath: '/storage/photo.jpg',
        hash: 'hash123',
        fileName: 'photo.jpg',
        sizeBytes: 1024,
        capturedAt: DateTime(2024, 1, 15),
        mimeType: 'image/jpeg',
      );

      // Act & Assert
      expect(syncFile.isImage, true);
      expect(syncFile.isVideo, false);
    });

    test('isImage should return true for various image formats', () {
      final mimeTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];

      for (final mimeType in mimeTypes) {
        final syncFile = SyncFile(
          localId: 'local_123',
          devicePath: '/storage/file',
          hash: 'hash',
          fileName: 'file',
          sizeBytes: 1024,
          capturedAt: DateTime(2024, 1, 15),
          mimeType: mimeType,
        );

        expect(syncFile.isImage, true, reason: 'Failed for $mimeType');
      }
    });

    test('isVideo should return true for video mime types', () {
      // Arrange
      final syncFile = SyncFile(
        localId: 'local_456',
        devicePath: '/storage/video.mp4',
        hash: 'hash456',
        fileName: 'video.mp4',
        sizeBytes: 10485760,
        capturedAt: DateTime(2024, 1, 15),
        mimeType: 'video/mp4',
      );

      // Act & Assert
      expect(syncFile.isVideo, true);
      expect(syncFile.isImage, false);
    });

    test('isVideo should return true for various video formats', () {
      final mimeTypes = ['video/mp4', 'video/mpeg', 'video/quicktime', 'video/x-msvideo'];

      for (final mimeType in mimeTypes) {
        final syncFile = SyncFile(
          localId: 'local_123',
          devicePath: '/storage/file',
          hash: 'hash',
          fileName: 'file',
          sizeBytes: 1024,
          capturedAt: DateTime(2024, 1, 15),
          mimeType: mimeType,
        );

        expect(syncFile.isVideo, true, reason: 'Failed for $mimeType');
      }
    });

    test('sizeMB should calculate size correctly', () {
      // Arrange
      final syncFile = SyncFile(
        localId: 'local_123',
        devicePath: '/storage/photo.jpg',
        hash: 'hash123',
        fileName: 'photo.jpg',
        sizeBytes: 1048576, // 1 MB
        capturedAt: DateTime(2024, 1, 15),
        mimeType: 'image/jpeg',
      );

      // Act
      final sizeMB = syncFile.sizeMB;

      // Assert
      expect(sizeMB, 1.0);
    });

    test('sizeMB should calculate fractional size correctly', () {
      // Arrange
      final syncFile = SyncFile(
        localId: 'local_123',
        devicePath: '/storage/photo.jpg',
        hash: 'hash123',
        fileName: 'photo.jpg',
        sizeBytes: 524288, // 0.5 MB
        capturedAt: DateTime(2024, 1, 15),
        mimeType: 'image/jpeg',
      );

      // Act
      final sizeMB = syncFile.sizeMB;

      // Assert
      expect(sizeMB, 0.5);
    });

    test('equality should be true for same hash', () {
      // Arrange
      final syncFile1 = SyncFile(
        localId: 'local_123',
        devicePath: '/storage/photo1.jpg',
        hash: 'same_hash',
        fileName: 'photo1.jpg',
        sizeBytes: 1024,
        capturedAt: DateTime(2024, 1, 15),
        mimeType: 'image/jpeg',
      );
      final syncFile2 = SyncFile(
        localId: 'local_456',
        devicePath: '/storage/photo2.jpg',
        hash: 'same_hash',
        fileName: 'photo2.jpg',
        sizeBytes: 2048,
        capturedAt: DateTime(2024, 1, 16),
        mimeType: 'image/png',
      );

      // Act & Assert
      expect(syncFile1 == syncFile2, true);
      expect(syncFile1.hashCode, syncFile2.hashCode);
    });

    test('equality should be false for different hashes', () {
      // Arrange
      final syncFile1 = SyncFile(
        localId: 'local_123',
        devicePath: '/storage/photo.jpg',
        hash: 'hash1',
        fileName: 'photo.jpg',
        sizeBytes: 1024,
        capturedAt: DateTime(2024, 1, 15),
        mimeType: 'image/jpeg',
      );
      final syncFile2 = SyncFile(
        localId: 'local_123',
        devicePath: '/storage/photo.jpg',
        hash: 'hash2',
        fileName: 'photo.jpg',
        sizeBytes: 1024,
        capturedAt: DateTime(2024, 1, 15),
        mimeType: 'image/jpeg',
      );

      // Act & Assert
      expect(syncFile1 == syncFile2, false);
      expect(syncFile1.hashCode, isNot(syncFile2.hashCode));
    });

    test('equality should be true for identical instances', () {
      // Arrange
      final syncFile = SyncFile(
        localId: 'local_123',
        devicePath: '/storage/photo.jpg',
        hash: 'hash123',
        fileName: 'photo.jpg',
        sizeBytes: 1024,
        capturedAt: DateTime(2024, 1, 15),
        mimeType: 'image/jpeg',
      );

      // Act & Assert
      expect(syncFile == syncFile, true);
    });
  });
}