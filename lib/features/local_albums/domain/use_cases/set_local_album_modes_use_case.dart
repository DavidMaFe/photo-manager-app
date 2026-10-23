import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';

/// The options the user chose for albums of the gallery, by id. Files already uploaded never change: the options only
/// decide what the next backups do.
class SetLocalAlbumModesUseCase {
  final LocalAlbumsRepository _repository;
  final SyncDeviceRepository _syncDeviceRepository;

  SetLocalAlbumModesUseCase(this._repository, this._syncDeviceRepository);

  Future<List<LocalAlbum>> call(Map<String, LocalAlbumMode> modes) async {
    final deviceUuid = await _syncDeviceRepository.getDeviceUuid();
    if (modes.isEmpty) {
      return _repository.albums(deviceUuid);
    }
    return _repository.setModes(deviceUuid, modes);
  }
}
