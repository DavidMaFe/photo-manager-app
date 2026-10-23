import 'package:photo_manager_app/features/local_albums/domain/entities/gallery_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';

/// The option proposed for an album of the gallery (ROADMAP-local-albums.md, Phase 0):
/// - «Solo copia» for the camera, screenshots and screen recordings, downloads and the folders of apps;
/// - not offered (null) for the folder where Photo Manager saves its downloads: those files are already on the server;
/// - «Como álbum» for everything else.
///
/// Without a folder (iOS) everything is «Solo copia», as before.
class DefaultAlbumMode {
  const DefaultAlbumMode._();

  static const _backupOnlyFolders = {
    'screenshots', 'screen recordings', 'screenrecorder', 'screenrecords', 'capturas', 'capturas de pantalla',
    'download', 'downloads', 'descargas',
  };

  static const _apps = [
    'whatsapp', 'telegram', 'instagram', 'messenger', 'facebook', 'snapchat', 'tiktok', 'twitter', 'signal',
    'discord', 'wechat', 'viber', 'chatgpt', 'threads', 'pinterest', 'reddit',
  ];

  static LocalAlbumMode? of(GalleryAlbum album) {
    final path = album.relativePath;
    if (path == null) return LocalAlbumMode.backupOnly;

    final segments = path.toLowerCase().split('/').map((segment) => segment.trim()).where((s) => s.isNotEmpty);
    final parts = segments.toList();
    if (parts.isEmpty) return LocalAlbumMode.album;

    if (parts.length >= 2 && parts[0] == 'pictures' && parts[1] == 'photomanager') return null;
    if (parts.length >= 2 && parts[0] == 'dcim' && parts[1] == 'camera') return LocalAlbumMode.backupOnly;
    if (parts[0] == 'android') return LocalAlbumMode.backupOnly;
    if (parts.any(_backupOnlyFolders.contains)) return LocalAlbumMode.backupOnly;
    if (parts.any((part) => _apps.any(part.contains))) return LocalAlbumMode.backupOnly;
    return LocalAlbumMode.album;
  }
}
