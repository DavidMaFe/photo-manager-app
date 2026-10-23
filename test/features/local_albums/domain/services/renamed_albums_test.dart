import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/gallery_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/services/renamed_albums.dart';

GalleryAlbum album(String id, Set<String> sample) =>
    GalleryAlbum(id: id, name: id, relativePath: 'Pictures/$id/', assetCount: sample.length, sampleAssetIds: sample);

void main() {
  group('RenamedAlbums', () {
    group('find', () {
      test('should recognize a new album with the files of an album that is gone', () {
        final renamed = RenamedAlbums.find(
          previous: {'old': {'a', 'b', 'c'}, 'kept': {'x'}},
          current: [album('new', {'a', 'b', 'c'}), album('kept', {'x'})],
        );

        expect(renamed, {'new': 'old'});
      });

      test('should not take as renamed an album whose old id is still in the gallery', () {
        final renamed = RenamedAlbums.find(
          previous: {'old': {'a', 'b'}},
          current: [album('old', {'b'}), album('new', {'a'})],
        );

        expect(renamed, isEmpty);
      });

      test('should treat as new an album without files of an album that is gone', () {
        final renamed = RenamedAlbums.find(previous: {'old': {'a'}}, current: [album('new', {'z'})]);

        expect(renamed, isEmpty);
      });

      test('should give each album that is gone to one new album only, the one with more of its files', () {
        final renamed = RenamedAlbums.find(
          previous: {'old': {'a', 'b', 'c'}},
          current: [album('one', {'a'}), album('most', {'a', 'b', 'c'})],
        );

        expect(renamed, {'most': 'old'});
      });

      test('should find nothing the first time', () {
        expect(RenamedAlbums.find(previous: {}, current: [album('new', {'a'})]), isEmpty);
      });
    });
  });
}
