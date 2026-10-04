import 'package:photo_manager_app/features/favorites/domain/entities/favorite_result.dart';


abstract class FavoritesRepository {
  /// Sets (does not toggle) the favorite mark of [fileIds].
  Future<FavoriteResult> setFavorite(List<String> fileIds, bool favorite);
}
