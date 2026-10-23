import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/gallery_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album_registration.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/services/default_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/services/renamed_albums.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';

/// Tells the server the albums the gallery has now (ROADMAP-local-albums.md), before a backup and before the list of
/// albums is shown:
/// - a new album gets its default option ([DefaultAlbumMode]); a known one keeps the one of the user;
/// - a folder renamed on the device ([RenamedAlbums]) keeps its option and its album of Photo Manager;
/// - the folder of the downloads of Photo Manager is not sent.
///
/// Answers the albums of the gallery with their options and their number of files, the new ones marked.
class RegisterLocalAlbumsUseCase {
  final LocalAlbumsRepository _repository;
  final SyncDeviceRepository _syncDeviceRepository;
  final AuthRepository _authRepository;

  RegisterLocalAlbumsUseCase(this._repository, this._syncDeviceRepository, this._authRepository);

  Future<List<LocalAlbum>> call() async {
    final offered = <GalleryAlbum>[];
    final registrations = <LocalAlbumRegistration>[];
    final gallery = await _repository.galleryAlbums();
    final userId = await _userId();
    final lastSeen = userId == null ? const <String, Set<String>>{} : await _repository.lastSeen(userId);

    final candidates = [for (final album in gallery) if (DefaultAlbumMode.of(album) != null) album];
    final renamed = RenamedAlbums.find(previous: lastSeen, current: candidates);
    for (final album in candidates) {
      offered.add(album);
      registrations.add(LocalAlbumRegistration(
        localAlbumId: album.id,
        name: album.name,
        defaultMode: DefaultAlbumMode.of(album)!,
        previousLocalAlbumId: renamed[album.id],
      ));
    }

    final deviceUuid = await _syncDeviceRepository.getDeviceUuid();
    final registered = await _repository.register(deviceUuid, registrations);
    if (userId != null) {
      await _repository.saveLastSeen(userId, offered);
    }

    final counts = {for (final album in offered) album.id: album.assetCount};
    return [for (final album in registered) album.withAssetCount(counts[album.localAlbumId])];
  }

  Future<String?> _userId() async {
    try {
      final user = await _authRepository.getCurrentUser();
      return user == null || user.id.isEmpty ? null : user.id;
    } catch (_) {
      return null;
    }
  }
}
