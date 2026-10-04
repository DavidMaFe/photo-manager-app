import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/file_management/presentation/models/album_viewer_context.dart';

import '../../../../fixtures/test_data.dart';

void main() {
  group('AlbumViewerContext.fromFolder', () {
    test('should build the path and know the album and its parent', () {
      // Act
      final context = AlbumViewerContext.fromFolder(TestFolders.album(
        id: 'a3',
        name: 'Atardeceres',
        parentFolderId: 'a2',
        path: '/Vacaciones 2024/Playa/Atardeceres',
      ));

      // Assert
      expect(context.folderId, 'a3');
      expect(context.path, 'Vacaciones 2024 › Playa › Atardeceres');
      expect(context.nameOf('a3'), 'Atardeceres');
      expect(context.nameOf('a2'), 'Playa');
      expect(context.nameOf('a1'), isNull);
    });

    test('should work for a root album', () {
      // Act
      final context = AlbumViewerContext.fromFolder(TestFolders.album(id: 'a1', name: 'Viajes', path: '/Viajes'));

      // Assert
      expect(context.path, 'Viajes');
      expect(context.albumNames, {'a1': 'Viajes'});
    });
  });
}
