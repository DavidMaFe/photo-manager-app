import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/local_albums/data/models/local_album_model.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album_registration.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';

void main() {
  group('LocalAlbumModel', () {
    group('fromJson', () {
      test('should read an album of the server', () {
        final album = LocalAlbumModel.fromJson(
            {'localAlbumId': '747804901', 'name': 'Vacaciones 2025', 'mode': 'ALBUM', 'folderId': 42, 'isNew': true});

        expect(album.localAlbumId, '747804901');
        expect(album.name, 'Vacaciones 2025');
        expect(album.mode, LocalAlbumMode.album);
        expect(album.folderId, '42');
        expect(album.isNew, isTrue);
      });

      test('should read an album without an album of Photo Manager yet', () {
        final album = LocalAlbumModel.fromJson(
            {'localAlbumId': '1', 'name': 'Camera', 'mode': 'BACKUP_ONLY', 'folderId': null, 'isNew': false});

        expect(album.mode, LocalAlbumMode.backupOnly);
        expect(album.folderId, isNull);
        expect(album.isNew, isFalse);
      });

      test('should fail with an unknown option', () {
        expect(() => LocalAlbumModel.fromJson({'localAlbumId': '1', 'name': 'X', 'mode': 'SOMETIMES'}),
            throwsFormatException);
      });
    });

    group('registrationToJson', () {
      test('should send the previous id only for a renamed folder', () {
        expect(
          LocalAlbumModel.registrationToJson(const LocalAlbumRegistration(
              localAlbumId: '2', name: 'Verano 2023 Playa', defaultMode: LocalAlbumMode.album,
              previousLocalAlbumId: '1')),
          {'localAlbumId': '2', 'name': 'Verano 2023 Playa', 'defaultMode': 'ALBUM', 'previousLocalAlbumId': '1'},
        );
        expect(
          LocalAlbumModel.registrationToJson(const LocalAlbumRegistration(
              localAlbumId: '3', name: 'Camera', defaultMode: LocalAlbumMode.backupOnly)),
          {'localAlbumId': '3', 'name': 'Camera', 'defaultMode': 'BACKUP_ONLY'},
        );
      });
    });
  });
}
