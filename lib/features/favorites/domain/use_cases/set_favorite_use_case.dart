import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/favorites/domain/entities/favorite_result.dart';
import 'package:photo_manager_app/features/favorites/domain/repositories/favorites_repository.dart';


/// Marks or unmarks files as favorites. Partial success is allowed: the
/// result says which files could not change.
class SetFavoriteUseCase {

  final FavoritesRepository _repository;
  SetFavoriteUseCase(this._repository);

  Future<FavoriteResult> call({required List<String> fileIds, required bool favorite}) async {
    final ids = fileIds.toSet().toList();
    if (ids.isEmpty) {
      throw const ValidationFailure(code: 'FILE_IDS_REQUIRED');
    }
    return await _repository.setFavorite(ids, favorite);
  }
}
