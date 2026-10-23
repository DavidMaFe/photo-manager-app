import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album_registration.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';

/// An album of `GET`/`PUT /api/device/{deviceUuid}/albums/` (ROADMAP-local-albums.md).
class LocalAlbumModel extends LocalAlbum {
  const LocalAlbumModel({
    required super.localAlbumId,
    required super.name,
    required super.mode,
    super.folderId,
    super.isNew,
  });

  factory LocalAlbumModel.fromJson(Map<String, dynamic> json) => LocalAlbumModel(
        localAlbumId: json['localAlbumId'] as String,
        name: json['name'] as String,
        mode: LocalAlbumMode.fromCode(json['mode'] as String),
        folderId: json['folderId']?.toString(),
        isNew: json['isNew'] as bool? ?? false,
      );

  static Map<String, dynamic> registrationToJson(LocalAlbumRegistration album) => {
        'localAlbumId': album.localAlbumId,
        'name': album.name,
        'defaultMode': album.defaultMode.code,
        if (album.previousLocalAlbumId != null) 'previousLocalAlbumId': album.previousLocalAlbumId,
      };
}
