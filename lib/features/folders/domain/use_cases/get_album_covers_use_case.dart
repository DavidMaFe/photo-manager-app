import '../entities/album_cover.dart';
import '../repositories/covers_repository.dart';


class GetAlbumCoversUseCase {

  final CoversRepository _repository;
  GetAlbumCoversUseCase(this._repository);

  Future<List<AlbumCover>> call(String folderId) async {
    return await _repository.getAlbumCovers(folderId);
  }
}
