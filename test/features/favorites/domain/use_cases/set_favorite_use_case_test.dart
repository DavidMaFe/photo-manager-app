import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/favorites/domain/entities/favorite_result.dart';
import 'package:photo_manager_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:photo_manager_app/features/favorites/domain/use_cases/set_favorite_use_case.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late MockFavoritesRepository repository;
  late SetFavoriteUseCase useCase;

  setUp(() {
    repository = MockFavoritesRepository();
    useCase = SetFavoriteUseCase(repository);
  });

  group('SetFavoriteUseCase', () {
    test('should mark the files as favorites', () async {
      // Arrange
      const result = FavoriteResult(updatedIds: ['1', '2'], failedIds: []);
      when(() => repository.setFavorite(any(), any())).thenAnswer((_) async => result);

      // Act
      final actual = await useCase(fileIds: ['1', '2'], favorite: true);

      // Assert
      expect(actual, result);
      verify(() => repository.setFavorite(['1', '2'], true)).called(1);
    });

    test('should return a partial success with the failed files', () async {
      // Arrange
      const result = FavoriteResult(updatedIds: ['1'], failedIds: ['2']);
      when(() => repository.setFavorite(any(), any())).thenAnswer((_) async => result);

      // Act
      final actual = await useCase(fileIds: ['1', '2'], favorite: false);

      // Assert
      expect(actual.failedIds, ['2']);
      expect(actual.hasFailures, isTrue);
    });

    test('should send each file once', () async {
      // Arrange
      when(() => repository.setFavorite(any(), any()))
          .thenAnswer((_) async => const FavoriteResult(updatedIds: [], failedIds: []));

      // Act
      await useCase(fileIds: ['1', '1', '2'], favorite: true);

      // Assert
      verify(() => repository.setFavorite(['1', '2'], true)).called(1);
    });

    test('should reject an empty list without calling the repository', () async {
      // Act & Assert
      await expectLater(useCase(fileIds: [], favorite: true), throwsA(isA<ValidationFailure>()));
      verifyNever(() => repository.setFavorite(any(), any()));
    });
  });
}
