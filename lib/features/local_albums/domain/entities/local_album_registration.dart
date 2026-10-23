import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';

/// An album of the gallery sent to the server: the server keeps the option of a known one and uses [defaultMode]
/// for a new one. [previousLocalAlbumId] is its id before its folder was renamed on the device.
class LocalAlbumRegistration {
  final String localAlbumId;
  final String name;
  final LocalAlbumMode defaultMode;
  final String? previousLocalAlbumId;

  const LocalAlbumRegistration({
    required this.localAlbumId,
    required this.name,
    required this.defaultMode,
    this.previousLocalAlbumId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalAlbumRegistration &&
          other.localAlbumId == localAlbumId &&
          other.name == name &&
          other.defaultMode == defaultMode &&
          other.previousLocalAlbumId == previousLocalAlbumId;

  @override
  int get hashCode => Object.hash(localAlbumId, name, defaultMode, previousLocalAlbumId);
}
