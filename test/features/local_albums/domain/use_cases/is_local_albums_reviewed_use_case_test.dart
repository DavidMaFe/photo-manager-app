import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/is_local_albums_reviewed_use_case.dart';

import '../../../../fixtures/test_data.dart';

class MockLocalAlbumsRepository extends Mock implements LocalAlbumsRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockLocalAlbumsRepository repository;
  late MockAuthRepository authRepository;
  late IsLocalAlbumsReviewedUseCase useCase;

  setUp(() {
    repository = MockLocalAlbumsRepository();
    authRepository = MockAuthRepository();
    useCase = IsLocalAlbumsReviewedUseCase(repository, authRepository);
  });

  group('IsLocalAlbumsReviewedUseCase', () {
    test('should say whether the account went through «Tus álbumes»', () async {
      when(() => authRepository.getCurrentUser()).thenAnswer((_) async => TestUsers.johnDoe);
      when(() => repository.isReviewed(TestUsers.johnDoe.id)).thenAnswer((_) async => false);

      expect(await useCase(), isFalse);
    });

    test('should take it as reviewed without a user, so nothing waits for it', () async {
      when(() => authRepository.getCurrentUser()).thenAnswer((_) async => null);

      expect(await useCase(), isTrue);
      verifyNever(() => repository.isReviewed(any()));
    });
  });
}
