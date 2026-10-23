import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';

/// The albums of the gallery this device registered, with their options, the ones still in the gallery with their
/// number of files. Ordered by name.
class GetLocalAlbumsUseCase {
  final LocalAlbumsRepository _repository;
  final SyncDeviceRepository _syncDeviceRepository;

  GetLocalAlbumsUseCase(this._repository, this._syncDeviceRepository);

  Future<List<LocalAlbum>> call() async {
    final deviceUuid = await _syncDeviceRepository.getDeviceUuid();
    final albums = await _repository.albums(deviceUuid);
    final counts = {for (final album in await _repository.galleryAlbums()) album.id: album.assetCount};
    return [for (final album in albums) album.withAssetCount(counts[album.localAlbumId])];
  }
}
