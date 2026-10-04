import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/gallery/data/models/pending_files_model.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/pending_files.dart';

void main() {
  group('PendingFilesModel', () {
    group('fromJson', () {
      test('should convert numeric IDs to strings and read the size', () {
        // Act
        final model = PendingFilesModel.fromJson(const {'fileIds': [10, 11], 'totalSizeBytes': 5000});

        // Assert
        expect(model, isA<PendingFiles>());
        expect(model.fileIds, ['10', '11']);
        expect(model.totalSizeBytes, 5000);
        expect(model.isEmpty, isFalse);
      });

      test('should default to no files and size 0 when fields are missing', () {
        // Act
        final model = PendingFilesModel.fromJson(const {});

        // Assert
        expect(model.fileIds, isEmpty);
        expect(model.totalSizeBytes, 0);
        expect(model.isEmpty, isTrue);
      });
    });

    test('should serialize to JSON', () {
      // Arrange
      const model = PendingFilesModel(fileIds: ['1'], totalSizeBytes: 3);

      // Act & Assert
      expect(model.toJson(), {'fileIds': ['1'], 'totalSizeBytes': 3});
    });
  });
}
