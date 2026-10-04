import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/file_management/data/models/file_info_model.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/file_info.dart';

void main() {
  const fullJson = {
    'id': 42,
    'originalFilename': 'IMG_2041.HEIC',
    'type': 'IMAGE',
    'status': 'MANAGED',
    'mimeType': 'image/heic',
    'width': 4032,
    'height': 3024,
    'durationSeconds': null,
    'sizeBytes': 2457600,
    'capturedAt': '2026-10-03T03:00:00',
    'uploadedAt': '2026-10-03T03:04:10',
    'deletedAt': null,
    'isFavorite': true,
    'folderId': 7,
    'folderName': 'Japón',
    'deviceId': 2,
    'deviceName': 'Pixel 8',
  };

  group('FileInfoModel', () {
    group('fromJson', () {
      test('should parse every field and convert numeric IDs to strings', () {
        // Act
        final model = FileInfoModel.fromJson(fullJson);

        // Assert
        expect(model, isA<FileInfo>());
        expect(model.id, '42');
        expect(model.originalFilename, 'IMG_2041.HEIC');
        expect(model.type, FileType.image);
        expect(model.status, FileStatus.managed);
        expect(model.mimeType, 'image/heic');
        expect(model.width, 4032);
        expect(model.height, 3024);
        expect(model.durationSeconds, isNull);
        expect(model.sizeBytes, 2457600);
        expect(model.capturedAt, DateTime(2026, 10, 3, 3));
        expect(model.uploadedAt, DateTime(2026, 10, 3, 3, 4, 10));
        expect(model.deletedAt, isNull);
        expect(model.isFavorite, isTrue);
        expect(model.folderId, '7');
        expect(model.folderName, 'Japón');
        expect(model.deviceId, '2');
        expect(model.deviceName, 'Pixel 8');
        expect(model.hasDimensions, isTrue);
      });

      test('should default the optional fields when they are missing', () {
        // Act
        final model = FileInfoModel.fromJson(const {'id': 1, 'type': 'VIDEO', 'status': 'PENDING'});

        // Assert
        expect(model.type, FileType.video);
        expect(model.status, FileStatus.pending);
        expect(model.sizeBytes, 0);
        expect(model.isFavorite, isFalse);
        expect(model.capturedAt, isNull);
        expect(model.folderId, isNull);
        expect(model.deviceId, isNull);
        expect(model.hasDimensions, isFalse);
      });
    });

    test('should round-trip through toJson', () {
      // Act
      final json = FileInfoModel.fromJson(fullJson).toJson();

      // Assert
      expect(FileInfoModel.fromJson(json), FileInfoModel.fromJson(fullJson));
    });
  });

  group('FileInfo.hasDimensions', () {
    test('should be false with a zero size', () {
      const info = FileInfo(id: '1', type: FileType.image, status: FileStatus.managed, width: 0, height: 10);
      expect(info.hasDimensions, isFalse);
    });
  });
}
