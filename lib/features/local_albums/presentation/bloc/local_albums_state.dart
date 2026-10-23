import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';

enum LocalAlbumsStatus { loading, loaded, noPermission, error, done }

class LocalAlbumsState extends Equatable {
  final LocalAlbumsStatus status;

  /// The albums of the gallery with their options on the server, by name.
  final List<LocalAlbum> albums;

  /// Options changed on «Tus álbumes» and not saved yet.
  final Map<String, LocalAlbumMode> changes;

  final bool saving;

  /// Only some photos can be read: only their albums are shown.
  final bool limitedAccess;

  /// An error to show once.
  final Failure? failure;

  const LocalAlbumsState({
    this.status = LocalAlbumsStatus.loading,
    this.albums = const [],
    this.changes = const {},
    this.saving = false,
    this.limitedAccess = false,
    this.failure,
  });

  /// The option of an album, with the change of the user if there is one.
  LocalAlbumMode modeOf(LocalAlbum album) => changes[album.localAlbumId] ?? album.mode;

  int get excludedCount => albums.where((album) => modeOf(album) == LocalAlbumMode.excluded).length;

  LocalAlbumsState copyWith({
    LocalAlbumsStatus? status,
    List<LocalAlbum>? albums,
    Map<String, LocalAlbumMode>? changes,
    bool? saving,
    bool? limitedAccess,
    Failure? failure,
  }) {
    return LocalAlbumsState(
      status: status ?? this.status,
      albums: albums ?? this.albums,
      changes: changes ?? this.changes,
      saving: saving ?? this.saving,
      limitedAccess: limitedAccess ?? this.limitedAccess,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, albums, changes, saving, limitedAccess, failure];
}
