import '../entities/album_cover.dart';
import '../entities/cover_change.dart';
import '../entities/cover_target.dart';
import '../entities/folder_covers.dart';


abstract class CoversRepository {
  /// Albums the photos can be covers of, from the root down. With several
  /// photos, only the albums every photo is in (common ancestors).
  Future<List<CoverTarget>> getCoverTargets(List<String> fileIds);

  /// Applies every change of [fileId] at once (all or nothing).
  Future<List<FolderCovers>> applyCoverChanges(String fileId, List<CoverChange> changes);

  Future<List<AlbumCover>> getAlbumCovers(String folderId);

  /// Final order of the album's covers; also removes the ones left out.
  Future<List<AlbumCover>> setAlbumCovers(String folderId, List<String> orderedFileIds);
}
