import 'package:photo_manager_app/features/local_albums/data/data_sources/gallery_albums_local_data_source.dart';
import 'package:photo_manager_app/features/local_albums/data/data_sources/local_album_snapshot_local_data_source.dart';
import 'package:photo_manager_app/features/local_albums/data/data_sources/local_albums_remote_data_source.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/gallery_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album_registration.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';

class LocalAlbumsDataRepository implements LocalAlbumsRepository {
  final GalleryAlbumsLocalDataSource galleryDataSource;
  final LocalAlbumSnapshotLocalDataSource snapshotDataSource;
  final LocalAlbumsRemoteDataSource remoteDataSource;

  LocalAlbumsDataRepository({
    required this.galleryDataSource,
    required this.snapshotDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<GalleryAlbum>> galleryAlbums() => galleryDataSource.albums();

  @override
  Future<Map<String, Set<String>>> lastSeen(String userId) => snapshotDataSource.lastSeen(userId);

  @override
  Future<void> saveLastSeen(String userId, List<GalleryAlbum> albums) => snapshotDataSource.save(userId, albums);

  @override
  Future<List<LocalAlbum>> register(String deviceUuid, List<LocalAlbumRegistration> albums) =>
      remoteDataSource.register(deviceUuid, albums);

  @override
  Future<List<LocalAlbum>> albums(String deviceUuid) => remoteDataSource.getAlbums(deviceUuid);

  @override
  Future<List<LocalAlbum>> setModes(String deviceUuid, Map<String, LocalAlbumMode> modes) =>
      remoteDataSource.setModes(deviceUuid, modes);
}
