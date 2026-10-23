import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/permissions/app_permission.dart';
import 'package:photo_manager_app/core/permissions/permission_service.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/check_local_albums_review_use_case.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/register_local_albums_use_case.dart';

import '../../../../fixtures/test_data.dart';

class MockLocalAlbumsRepository extends Mock implements LocalAlbumsRepository {}

class MockRegisterLocalAlbumsUseCase extends Mock implements RegisterLocalAlbumsUseCase {}

class MockPermissionService extends Mock implements PermissionService {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  final user = TestUsers.johnDoe;
  late MockLocalAlbumsRepository repository;
  late MockRegisterLocalAlbumsUseCase register;
  late MockPermissionService permissions;
  late MockAuthRepository authRepository;

  CheckLocalAlbumsReviewUseCase useCase({bool supported = true}) =>
      CheckLocalAlbumsReviewUseCase(repository, register, permissions, authRepository, supported: supported);

  setUp(() {
    repository = MockLocalAlbumsRepository();
    register = MockRegisterLocalAlbumsUseCase();
    permissions = MockPermissionService();
    authRepository = MockAuthRepository();
    when(() => authRepository.getCurrentUser()).thenAnswer((_) async => user);
    when(() => repository.isReviewed(user.id)).thenAnswer((_) async => false);
    when(() => repository.markReviewed(user.id)).thenAnswer((_) async {});
    when(() => permissions.isGranted(AppPermission.photos)).thenAnswer((_) async => true);
  });

  group('CheckLocalAlbumsReviewUseCase', () {
    test('should answer the albums when one of them would be imported as an album', () async {
      when(() => register()).thenAnswer((_) async => [TestLocalAlbums.cameraOnServer, TestLocalAlbums.vacacionesOnServer]);

      expect(await useCase()(), [TestLocalAlbums.cameraOnServer, TestLocalAlbums.vacacionesOnServer]);
      verifyNever(() => repository.markReviewed(any()));
    });

    test('should not show the page and mark it as reviewed when there is nothing to import as an album', () async {
      // Only the camera (backed up without an album), or an empty gallery
      when(() => register()).thenAnswer((_) async => [TestLocalAlbums.cameraOnServer]);

      expect(await useCase()(), isNull);
      verify(() => repository.markReviewed(user.id)).called(1);
    });

    test('should not show the page for an empty gallery', () async {
      when(() => register()).thenAnswer((_) async => []);

      expect(await useCase()(), isNull);
      verify(() => repository.markReviewed(user.id)).called(1);
    });

    test('should not show the page again once reviewed', () async {
      when(() => repository.isReviewed(user.id)).thenAnswer((_) async => true);

      expect(await useCase()(), isNull);
      verifyNever(() => register());
    });

    test('should not show the page without access to the photos, and ask again later', () async {
      when(() => permissions.isGranted(AppPermission.photos)).thenAnswer((_) async => false);

      expect(await useCase()(), isNull);
      verifyNever(() => register());
      verifyNever(() => repository.markReviewed(any()));
    });

    test('should not show the page where the albums are not imported yet (iOS)', () async {
      expect(await useCase(supported: false)(), isNull);
      verifyNever(() => repository.isReviewed(any()));
    });

    test('should not show the page without a user', () async {
      when(() => authRepository.getCurrentUser()).thenAnswer((_) async => null);

      expect(await useCase()(), isNull);
    });
  });
}
