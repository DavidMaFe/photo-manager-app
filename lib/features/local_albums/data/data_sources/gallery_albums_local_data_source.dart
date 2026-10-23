import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/gallery_album.dart';

/// The albums of the gallery, read with photo_manager (ROADMAP-local-albums.md, Phase 0: about 0.1 s on the S23).
abstract class GalleryAlbumsLocalDataSource {
  Future<List<GalleryAlbum>> albums();
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
}
