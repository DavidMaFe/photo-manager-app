import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/services/current_user_id.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/backup_progress_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';

/// The options the user chose for albums of the gallery, by id. Files already uploaded never change: the options only
/// decide what the next backups do. An album that was «No copiar» and now is backed up gets all its files tried by
/// the next backup, also the ones that arrived while it was not backed up.
class SetLocalAlbumModesUseCase {
  final LocalAlbumsRepository _repository;
  final SyncDeviceRepository _syncDeviceRepository;
  final BackupProgressRepository _backupProgress;
  final AuthRepository _authRepository;

  SetLocalAlbumModesUseCase(this._repository, this._syncDeviceRepository, this._backupProgress, this._authRepository);

  Future<List<LocalAlbum>> call(Map<String, LocalAlbumMode> modes) async {
    final deviceUuid = await _syncDeviceRepository.getDeviceUuid();
    if (modes.isEmpty) {
      return _repository.albums(deviceUuid);
    }

    final before = {for (final album in await _repository.albums(deviceUuid)) album.localAlbumId: album.mode};
    final albums = await _repository.setModes(deviceUuid, modes);

    final backedUpAgain = [
      for (final entry in modes.entries)
        if (before[entry.key] == LocalAlbumMode.excluded && entry.value != LocalAlbumMode.excluded) entry.key,
    ];
    final userId = backedUpAgain.isEmpty ? null : await currentUserId(_authRepository);
    if (userId != null) {
      for (final localAlbumId in backedUpAgain) {
        await _backupProgress.addPending(userId, await _repository.galleryAlbumAssetIds(localAlbumId));
      }
    }
    return albums;
  }
}
