import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/favorites/data/data_sources/favorites_remote_data_source.dart';
import 'package:photo_manager_app/features/favorites/data/models/favorite_result_model.dart';
import 'package:photo_manager_app/features/favorites/data/repositories/favorites_data_repository.dart';

class MockFavoritesRemoteDataSource extends Mock implements FavoritesRemoteDataSource {}

void main() {
  group('FavoritesDataRepository', () {
    test('should delegate to the remote data source', () async {
      // Arrange
      final remote = MockFavoritesRemoteDataSource();
      const result = FavoriteResultModel(updatedIds: ['1'], failedIds: ['2']);
      when(() => remote.setFavorite(any(), any())).thenAnswer((_) async => result);

      // Act
      final actual = await FavoritesDataRepository(remote).setFavorite(['1', '2'], false);

      // Assert
      expect(actual, result);
      verify(() => remote.setFavorite(['1', '2'], false)).called(1);
    });
  });
}
