import 'package:photo_manager_app/features/favorites/data/data_sources/favorites_remote_data_source.dart';
import 'package:photo_manager_app/features/favorites/domain/entities/favorite_result.dart';
import 'package:photo_manager_app/features/favorites/domain/repositories/favorites_repository.dart';


class FavoritesDataRepository implements FavoritesRepository {

  final FavoritesRemoteDataSource remoteDataSource;
  FavoritesDataRepository(this.remoteDataSource);

  @override
  Future<FavoriteResult> setFavorite(List<String> fileIds, bool favorite) async {
    return await remoteDataSource.setFavorite(fileIds, favorite);
  }
}
