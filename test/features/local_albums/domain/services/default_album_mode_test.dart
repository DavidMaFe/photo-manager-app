import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/gallery_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/services/default_album_mode.dart';

GalleryAlbum album(String? relativePath, {String name = 'Album'}) =>
    GalleryAlbum(id: '1', name: name, relativePath: relativePath, assetCount: 1);

void main() {
  group('DefaultAlbumMode', () {
    group('of', () {
      test('should import as an album a folder made by the user', () {
        expect(DefaultAlbumMode.of(album('Pictures/Vacaciones 2025/')), LocalAlbumMode.album);
        expect(DefaultAlbumMode.of(album('Pictures/Viajes/Roma 2024/')), LocalAlbumMode.album);
        expect(DefaultAlbumMode.of(album('DCIM/Album test/')), LocalAlbumMode.album);
        expect(DefaultAlbumMode.of(album('Pictures/Mamá/')), LocalAlbumMode.album);
      });

      test('should back up without an album the camera', () {
        expect(DefaultAlbumMode.of(album('DCIM/Camera/')), LocalAlbumMode.backupOnly);
        expect(DefaultAlbumMode.of(album('dcim/camera')), LocalAlbumMode.backupOnly);
      });

      test('should back up without an album screenshots, screen recordings and downloads', () {
        expect(DefaultAlbumMode.of(album('Pictures/Screenshots/')), LocalAlbumMode.backupOnly);
        expect(DefaultAlbumMode.of(album('DCIM/Screenshots/')), LocalAlbumMode.backupOnly);
        expect(DefaultAlbumMode.of(album('DCIM/Screen recordings/')), LocalAlbumMode.backupOnly);
        expect(DefaultAlbumMode.of(album('Download/')), LocalAlbumMode.backupOnly);
      });

      test('should back up without an album the folders of apps', () {
        expect(DefaultAlbumMode.of(album('Pictures/WhatsApp Images/')), LocalAlbumMode.backupOnly);
        expect(DefaultAlbumMode.of(album('Pictures/Instagram/')), LocalAlbumMode.backupOnly);
        expect(DefaultAlbumMode.of(album('Pictures/Telegram/')), LocalAlbumMode.backupOnly);
        expect(DefaultAlbumMode.of(album('Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images/')),
            LocalAlbumMode.backupOnly);
        expect(DefaultAlbumMode.of(album('Pictures/ChatGPT/')), LocalAlbumMode.backupOnly);
      });

      test('should not offer the downloads of Photo Manager', () {
        expect(DefaultAlbumMode.of(album('Pictures/PhotoManager/')), isNull);
        expect(DefaultAlbumMode.of(album('Pictures/PhotoManager/Verano/')), isNull);
      });

      test('should back up without an album when the system does not say the folder', () {
        expect(DefaultAlbumMode.of(album(null)), LocalAlbumMode.backupOnly);
      });

      test('should never offer EXCLUDED by default', () {
        for (final path in ['DCIM/Camera/', 'Pictures/WhatsApp Images/', 'Pictures/Boda/', 'Download/', null]) {
          expect(DefaultAlbumMode.of(album(path)), isNot(LocalAlbumMode.excluded));
        }
      });
    });
  });
}
