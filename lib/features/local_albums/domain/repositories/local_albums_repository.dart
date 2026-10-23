import 'package:photo_manager_app/features/local_albums/domain/entities/gallery_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album_registration.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';

/// The albums of the gallery of this device and their options on the server (ROADMAP-local-albums.md).
abstract class LocalAlbumsRepository {
  /// The albums of the gallery with files.
  Future<List<GalleryAlbum>> galleryAlbums();

  /// The albums the last registration of the account saw, with some ids of their files.
  Future<Map<String, Set<String>>> lastSeen(String userId);

  Future<void> saveLastSeen(String userId, List<GalleryAlbum> albums);

  /// Registers what the gallery has; answers the albums sent, with their options.
  Future<List<LocalAlbum>> register(String deviceUuid, List<LocalAlbumRegistration> albums);

  /// Every album the server knows of this device.
  Future<List<LocalAlbum>> albums(String deviceUuid);

  /// The options chosen by the user; answers every album of the device.
  Future<List<LocalAlbum>> setModes(String deviceUuid, Map<String, LocalAlbumMode> modes);
}
