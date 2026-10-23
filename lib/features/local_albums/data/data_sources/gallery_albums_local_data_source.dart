import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/gallery_album.dart';

/// The albums of the gallery, read with photo_manager (ROADMAP-local-albums.md, Phase 0: about 0.1 s on the S23).
abstract class GalleryAlbumsLocalDataSource {
  Future<List<GalleryAlbum>> albums();

  Future<Set<String>> assetIds(String albumId);
}

class GalleryAlbumsLocalDataSourceImpl implements GalleryAlbumsLocalDataSource {
  /// Ids of files kept per album to recognize it when its folder is renamed.
  static const int sampleSize = 20;

  @override
  Future<List<GalleryAlbum>> albums() async {
    final paths = await PhotoManager.getAssetPathList(type: RequestType.common, hasAll: false);
    final albums = <GalleryAlbum>[];
    for (final path in paths) {
      final count = await path.assetCountAsync;
      if (count == 0) continue;
      final sample = await path.getAssetListRange(start: 0, end: sampleSize);
      albums.add(GalleryAlbum(
        id: path.id,
        name: path.name,
        relativePath: sample.isEmpty ? null : sample.first.relativePath,
        assetCount: count,
        sampleAssetIds: {for (final asset in sample) asset.id},
      ));
    }
    return albums;
  }

  @override
  Future<Set<String>> assetIds(String albumId) async {
    final paths = await PhotoManager.getAssetPathList(type: RequestType.common, hasAll: false);
    final path = paths.where((path) => path.id == albumId).firstOrNull;
    if (path == null) return {};
    final count = await path.assetCountAsync;
    final ids = <String>{};
    for (var page = 0; page * 500 < count; page++) {
      ids.addAll((await path.getAssetListPaged(page: page, size: 500)).map((asset) => asset.id));
    }
    return ids;
  }
}
