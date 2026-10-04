import 'package:photo_manager_app/core/constants/app_constants.dart';
import 'package:photo_manager_app/core/errors/base/failure_codes.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';

import '../entities/album_cover.dart';
import '../repositories/covers_repository.dart';


/// Saves the final order of an album's covers (removing and reordering).
/// An empty list goes back to the automatic covers.
class SetAlbumCoversUseCase {

  final CoversRepository _repository;
  SetAlbumCoversUseCase(this._repository);

  Future<List<AlbumCover>> call({required String folderId, required List<String> orderedFileIds}) async {
    if (orderedFileIds.length > kMaxAlbumCovers) {
      throw const ValidationFailure(code: FailureCodes.folderCoversLimitExceeded);
    }
    if (orderedFileIds.toSet().length != orderedFileIds.length) {
      throw const ValidationFailure(code: FailureCodes.folderCoverDuplicated);
    }
    return await _repository.setAlbumCovers(folderId, orderedFileIds);
  }
}
