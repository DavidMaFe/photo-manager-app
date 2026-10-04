import '../../domain/entities/album_cover.dart';
import '../../domain/entities/cover_change.dart';
import '../../domain/entities/cover_target.dart';
import '../../domain/entities/folder_covers.dart';
import '../../domain/repositories/covers_repository.dart';
import '../data_sources/covers_remote_data_source.dart';


class CoversDataRepository implements CoversRepository {

  final CoversRemoteDataSource remoteDataSource;
  CoversDataRepository(this.remoteDataSource);

  /// One call per photo; with several photos keeps only the albums all of
  /// them are in, in the first photo's order (root first).
  @override
  Future<List<CoverTarget>> getCoverTargets(List<String> fileIds) async {
    final targetsPerFile = <List<CoverTarget>>[];
    for (final fileId in fileIds) {
      targetsPerFile.add(await remoteDataSource.getCoverTargets(fileId));
    }
    if (targetsPerFile.isEmpty) return const [];
    if (targetsPerFile.length == 1) return targetsPerFile.single;

    final others = targetsPerFile.skip(1).map((targets) => {for (final t in targets) t.folderId: t}).toList();
    return [
      for (final target in targetsPerFile.first)
        if (others.every((byId) => byId.containsKey(target.folderId)))
          CoverTarget(
            folderId: target.folderId,
            name: target.name,
            depth: target.depth,
            // "The photo is here" only if every photo is directly in this album.
            containsDirectly: target.containsDirectly &&
                others.every((byId) => byId[target.folderId]!.containsDirectly),
            covers: target.covers,
          ),
    ];
  }

  @override
  Future<List<FolderCovers>> applyCoverChanges(String fileId, List<CoverChange> changes) async {
    return await remoteDataSource.applyCoverChanges(fileId, changes);
  }

  @override
  Future<List<AlbumCover>> getAlbumCovers(String folderId) async {
    return await remoteDataSource.getAlbumCovers(folderId);
  }

  @override
  Future<List<AlbumCover>> setAlbumCovers(String folderId, List<String> orderedFileIds) async {
    return await remoteDataSource.setAlbumCovers(folderId, orderedFileIds);
  }
}
