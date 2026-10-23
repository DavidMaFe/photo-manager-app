import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';

/// An album of the gallery as the server knows it, with its option (ROADMAP-local-albums.md).
class LocalAlbum {
  final String localAlbumId;
  final String name;
  final LocalAlbumMode mode;

  /// The album of Photo Manager it is linked to, or null until a file of it is uploaded.
  final String? folderId;

  /// The album was registered just now: the backup took the default option.
  final bool isNew;

  /// Files of the album in the gallery, or null if it is not in the gallery now.
  final int? assetCount;

  const LocalAlbum({
    required this.localAlbumId,
    required this.name,
    required this.mode,
    this.folderId,
    this.isNew = false,
    this.assetCount,
  });

  LocalAlbum withAssetCount(int? assetCount) => LocalAlbum(
        localAlbumId: localAlbumId,
        name: name,
        mode: mode,
        folderId: folderId,
        isNew: isNew,
        assetCount: assetCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalAlbum &&
          other.localAlbumId == localAlbumId &&
          other.name == name &&
          other.mode == mode &&
          other.folderId == folderId &&
          other.isNew == isNew &&
          other.assetCount == assetCount;

  @override
  int get hashCode => Object.hash(localAlbumId, name, mode, folderId, isNew, assetCount);
}
