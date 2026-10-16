import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/downloads/data/models/remote_media_file_model.dart';

void main() {
  group('RemoteMediaFileModel.fromJson', () {
    test('should read the fields of GET /api/file/ids/', () {
      final model = RemoteMediaFileModel.fromJson(const {'id': 5, 'type': 'IMAGE', 'sizeBytes': 42, 'folderId': 9});

      expect(model.id, '5');
      expect(model.type, FileType.image);
      expect(model.sizeBytes, 42);
      expect(model.folderId, '9');
    });

    test('should accept a file without album or size', () {
      final model = RemoteMediaFileModel.fromJson(const {'id': 5, 'type': 'VIDEO'});

      expect(model.folderId, isNull);
      expect(model.sizeBytes, 0);
    });
  });
}
