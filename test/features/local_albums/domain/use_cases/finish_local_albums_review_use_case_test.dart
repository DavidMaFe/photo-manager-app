import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/finish_local_albums_review_use_case.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/set_local_album_modes_use_case.dart';

import '../../../../fixtures/test_data.dart';

class MockSetLocalAlbumModesUseCase extends Mock implements SetLocalAlbumModesUseCase {}

class MockLocalAlbumsRepository extends Mock implements LocalAlbumsRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  final user = TestUsers.johnDoe;
  late MockSetLocalAlbumModesUseCase setModes;
  late MockLocalAlbumsRepository repository;
  late FinishLocalAlbumsReviewUseCase useCase;

  setUpAll(() => registerFallbackValue(<String, LocalAlbumMode>{}));

  setUp(() {
    setModes = MockSetLocalAlbumModesUseCase();
    repository = MockLocalAlbumsRepository();
    final authRepository = MockAuthRepository();
    when(() => authRepository.getCurrentUser()).thenAnswer((_) async => user);
    when(() => repository.markReviewed(user.id)).thenAnswer((_) async {});
    when(() => setModes(any())).thenAnswer((_) async => []);
    useCase = FinishLocalAlbumsReviewUseCase(setModes, repository, authRepository);
  });

  group('FinishLocalAlbumsReviewUseCase', () {
    test('should save the changes and not show the page again', () async {
      await useCase({'1': LocalAlbumMode.excluded});

      verify(() => setModes({'1': LocalAlbumMode.excluded})).called(1);
      verify(() => repository.markReviewed(user.id)).called(1);
    });

    test('should only mark it as reviewed when nothing changed', () async {
      await useCase({});

      verifyNever(() => setModes(any()));
      verify(() => repository.markReviewed(user.id)).called(1);
    });

    test('should show the page again when the changes cannot be saved', () async {
      when(() => setModes(any())).thenThrow(Exception('Network error'));

      await expectLater(useCase({'1': LocalAlbumMode.excluded}), throwsException);

      verifyNever(() => repository.markReviewed(any()));
    });
  });
}
