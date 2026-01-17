import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_file_model.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';

void main() {
  group('SyncFileModel', () {
    const localId = 'local_123';
    const devicePath = '/storage/photo.jpg';
    const hash = 'abc123def456';
    const fileName = 'photo.jpg';
    const sizeBytes = 1048576;
    final capturedAt = DateTime(2024, 1, 15, 10, 30);
    const mimeType = 'image/jpeg';
    const width = 1920;
    const height = 1080;
    const durationSeconds = 120;

    test('should be a subclass of SyncFile entity', () {
      // Arrange
      final fileModel = SyncFileModel(
        localId: localId,
        devicePath: devicePath,
        hash: hash,
        fileName: fileName,
        sizeBytes: sizeBytes,
        capturedAt: capturedAt,
        mimeType: mimeType,
      );

      // Assert
      expect(fileModel, isA<SyncFile>());
    });

    group('fromJson', () {
      test('should create model from JSON with all fields', () {
        // Arrange
        final json = {
          'path': devicePath,
          'hash': hash,
          'name': fileName,
          'fileSizeBytes': sizeBytes,
          'capturedAt': capturedAt.toIso8601String(),
          'mimeType': mimeType,
          'width': width,
          'height': height,
          'durationSeconds': durationSeconds,
        };

        // Act
        final fileModel = SyncFileModel.fromJson(json);

        // Assert
        expect(fileModel.localId, ''); // fromJson sets localId to empty
        expect(fileModel.devicePath, devicePath);
        expect(fileModel.hash, hash);
        expect(fileModel.fileName, fileName);
        expect(fileModel.sizeBytes, sizeBytes);
        expect(fileModel.capturedAt, capturedAt);
        expect(fileModel.mimeType, mimeType);
        expect(fileModel.width, width);
        expect(fileModel.height, height);
        expect(fileModel.durationSeconds, durationSeconds);
      });

      test('should create model from JSON with only required fields', () {
        // Arrange
        final json = {
          'path': devicePath,
          'hash': hash,
          'name': fileName,
          'fileSizeBytes': sizeBytes,
          'capturedAt': capturedAt.toIso8601String(),
          'mimeType': mimeType,
        };

        // Act
        final fileModel = SyncFileModel.fromJson(json);

        // Assert
        expect(fileModel.devicePath, devicePath);
        expect(fileModel.hash, hash);
        expect(fileModel.fileName, fileName);
        expect(fileModel.sizeBytes, sizeBytes);
        expect(fileModel.capturedAt, capturedAt);
        expect(fileModel.mimeType, mimeType);
        expect(fileModel.width, null);
        expect(fileModel.height, null);
        expect(fileModel.durationSeconds, null);
      });

      test('should parse ISO 8601 date string correctly', () {
        // Arrange
        final dateString = '2024-01-15T10:30:00.000Z';
        final json = {
          'path': devicePath,
          'hash': hash,
          'name': fileName,
          'fileSizeBytes': sizeBytes,
          'capturedAt': dateString,
          'mimeType': mimeType,
        };

        // Act
        final fileModel = SyncFileModel.fromJson(json);

        // Assert
        expect(fileModel.capturedAt, DateTime.parse(dateString));
      });
    });

    group('toJson', () {
      test('should convert model to JSON with all fields', () {
        // Arrange
        final fileModel = SyncFileModel(
          localId: localId,
          devicePath: devicePath,
          hash: hash,
          fileName: fileName,
          sizeBytes: sizeBytes,
          capturedAt: capturedAt,
          mimeType: mimeType,
          width: width,
          height: height,
          durationSeconds: durationSeconds,
        );

        // Act
        final json = fileModel.toJson();

        // Assert
        expect(json['localId'], localId);
        expect(json['path'], devicePath);
        expect(json['hash'], hash);
        expect(json['name'], fileName);
        expect(json['fileSizeBytes'], sizeBytes);
        expect(json['capturedAt'], capturedAt);
        expect(json['mimeType'], mimeType);
        expect(json['width'], width);
        expect(json['height'], height);
        expect(json['durationSeconds'], durationSeconds);
      });

      test('should convert model to JSON with only required fields', () {
        // Arrange
        final fileModel = SyncFileModel(
          localId: localId,
          devicePath: devicePath,
          hash: hash,
          fileName: fileName,
          sizeBytes: sizeBytes,
          capturedAt: capturedAt,
          mimeType: mimeType,
        );

        // Act
        final json = fileModel.toJson();

        // Assert
        expect(json['localId'], localId);
        expect(json['path'], devicePath);
        expect(json['hash'], hash);
        expect(json['name'], fileName);
        expect(json['fileSizeBytes'], sizeBytes);
        expect(json['capturedAt'], capturedAt);
        expect(json['mimeType'], mimeType);
        expect(json.containsKey('width'), false);
        expect(json.containsKey('height'), false);
        expect(json.containsKey('durationSeconds'), false);
      });
    });

    group('fromEntity', () {
      test('should create model from SyncFile entity with all fields', () {
        // Arrange
        final entity = SyncFile(
          localId: localId,
          devicePath: devicePath,
          hash: hash,
          fileName: fileName,
          sizeBytes: sizeBytes,
          capturedAt: capturedAt,
          mimeType: mimeType,
          width: width,
          height: height,
          durationSeconds: durationSeconds,
        );

        // Act
        final fileModel = SyncFileModel.fromEntity(entity);

        // Assert
        expect(fileModel.localId, entity.localId);
        expect(fileModel.devicePath, entity.devicePath);
        expect(fileModel.hash, entity.hash);
        expect(fileModel.fileName, entity.fileName);
        expect(fileModel.sizeBytes, entity.sizeBytes);
        expect(fileModel.capturedAt, entity.capturedAt);
        expect(fileModel.mimeType, entity.mimeType);
        expect(fileModel.width, entity.width);
        expect(fileModel.height, entity.height);
        expect(fileModel.durationSeconds, entity.durationSeconds);
        expect(fileModel, isA<SyncFileModel>());
      });

      test('should create model from entity with only required fields', () {
        // Arrange
        final entity = SyncFile(
          localId: localId,
          devicePath: devicePath,
          hash: hash,
          fileName: fileName,
          sizeBytes: sizeBytes,
          capturedAt: capturedAt,
          mimeType: mimeType,
        );

        // Act
        final fileModel = SyncFileModel.fromEntity(entity);

        // Assert
        expect(fileModel.localId, entity.localId);
        expect(fileModel.width, null);
        expect(fileModel.height, null);
        expect(fileModel.durationSeconds, null);
      });
    });

    group('uploadMetadata', () {
      test('should generate upload metadata with all optional fields', () {
        // Arrange
        final fileModel = SyncFileModel(
          localId: localId,
          devicePath: devicePath,
          hash: hash,
          fileName: fileName,
          sizeBytes: sizeBytes,
          capturedAt: capturedAt,
          mimeType: mimeType,
          width: width,
          height: height,
          durationSeconds: durationSeconds,
        );

        // Act
        final metadata = fileModel.uploadMetadata;

        // Assert
        expect(metadata['originalFileName'], fileName);
        expect(metadata['fileHash'], hash);
        expect(metadata['mimeType'], mimeType);
        expect(metadata['fileSizeBytes'], sizeBytes);
        expect(metadata['capturedAt'], capturedAt.toIso8601String());
        expect(metadata['width'], width);
        expect(metadata['height'], height);
        expect(metadata['durationSeconds'], durationSeconds);
      });

      test('should generate upload metadata without optional fields', () {
        // Arrange
        final fileModel = SyncFileModel(
          localId: localId,
          devicePath: devicePath,
          hash: hash,
          fileName: fileName,
          sizeBytes: sizeBytes,
          capturedAt: capturedAt,
          mimeType: mimeType,
        );

        // Act
        final metadata = fileModel.uploadMetadata;

        // Assert
        expect(metadata['originalFileName'], fileName);
        expect(metadata['fileHash'], hash);
        expect(metadata['mimeType'], mimeType);
        expect(metadata['fileSizeBytes'], sizeBytes);
        expect(metadata['capturedAt'], capturedAt.toIso8601String());
        expect(metadata.containsKey('width'), false);
        expect(metadata.containsKey('height'), false);
        expect(metadata.containsKey('durationSeconds'), false);
      });

      test('should use ISO 8601 format for capturedAt in metadata', () {
        // Arrange
        final fileModel = SyncFileModel(
          localId: localId,
          devicePath: devicePath,
          hash: hash,
          fileName: fileName,
          sizeBytes: sizeBytes,
          capturedAt: capturedAt,
          mimeType: mimeType,
        );

        // Act
        final metadata = fileModel.uploadMetadata;

        // Assert
        expect(metadata['capturedAt'], contains('T'));
        expect(DateTime.parse(metadata['capturedAt']), capturedAt);
      });
    });

    group('JSON round-trip', () {
      test('should maintain data integrity through serialization cycle', () {
        // Arrange
        final originalModel = SyncFileModel(
          localId: localId,
          devicePath: devicePath,
          hash: hash,
          fileName: fileName,
          sizeBytes: sizeBytes,
          capturedAt: capturedAt,
          mimeType: mimeType,
          width: width,
          height: height,
          durationSeconds: durationSeconds,
        );

        // Act
        final json = originalModel.toJson();
        // Convert capturedAt DateTime to ISO string for proper deserialization
        final jsonForDeserialization = Map<String, dynamic>.from(json);
        jsonForDeserialization['capturedAt'] = (json['capturedAt'] as DateTime).toIso8601String();
        final deserializedModel = SyncFileModel.fromJson(jsonForDeserialization);

        // Assert
        // Note: localId is not preserved in fromJson (set to empty string)
        expect(deserializedModel.devicePath, originalModel.devicePath);
        expect(deserializedModel.hash, originalModel.hash);
        expect(deserializedModel.fileName, originalModel.fileName);
        expect(deserializedModel.sizeBytes, originalModel.sizeBytes);
        expect(deserializedModel.capturedAt, originalModel.capturedAt);
        expect(deserializedModel.mimeType, originalModel.mimeType);
        expect(deserializedModel.width, originalModel.width);
        expect(deserializedModel.height, originalModel.height);
        expect(deserializedModel.durationSeconds, originalModel.durationSeconds);
      });
    });

    group('entity methods', () {
      test('should have access to isImage method from parent entity', () {
        // Arrange
        final fileModel = SyncFileModel(
          localId: localId,
          devicePath: devicePath,
          hash: hash,
          fileName: fileName,
          sizeBytes: sizeBytes,
          capturedAt: capturedAt,
          mimeType: 'image/jpeg',
        );

        // Assert
        expect(fileModel.isImage, true);
        expect(fileModel.isVideo, false);
      });

      test('should have access to isVideo method from parent entity', () {
        // Arrange
        final fileModel = SyncFileModel(
          localId: localId,
          devicePath: devicePath,
          hash: hash,
          fileName: 'video.mp4',
          sizeBytes: sizeBytes,
          capturedAt: capturedAt,
          mimeType: 'video/mp4',
        );

        // Assert
        expect(fileModel.isVideo, true);
        expect(fileModel.isImage, false);
      });

      test('should calculate sizeMB correctly from parent entity', () {
        // Arrange
        final fileModel = SyncFileModel(
          localId: localId,
          devicePath: devicePath,
          hash: hash,
          fileName: fileName,
          sizeBytes: 2097152, // 2 MB
          capturedAt: capturedAt,
          mimeType: mimeType,
        );

        // Assert
        expect(fileModel.sizeMB, 2.0);
      });
    });
  });
}