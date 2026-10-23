import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/gallery_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album_registration.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/register_local_albums_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';

import '../../../../fixtures/test_data.dart';

class MockLocalAlbumsRepository extends Mock implements LocalAlbumsRepository {}

class MockSyncDeviceRepository extends Mock implements SyncDeviceRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  const deviceUuid = 'device-uuid';
  late MockLocalAlbumsRepository repository;
  late MockSyncDeviceRepository deviceRepository;
  late MockAuthRepository authRepository;
  late RegisterLocalAlbumsUseCase useCase;
  final user = TestUsers.johnDoe;

  setUpAll(() {
    registerFallbackValue(<GalleryAlbum>[]);
    registerFallbackValue(<LocalAlbumRegistration>[]);
  });

  setUp(() {
    repository = MockLocalAlbumsRepository();
    deviceRepository = MockSyncDeviceRepository();
    authRepository = MockAuthRepository();
    useCase = RegisterLocalAlbumsUseCase(repository, deviceRepository, authRepository, supported: true);

    when(() => deviceRepository.getDeviceUuid()).thenAnswer((_) async => deviceUuid);
    when(() => authRepository.getCurrentUser()).thenAnswer((_) async => user);
    when(() => repository.lastSeen(user.id)).thenAnswer((_) async => {});
    when(() => repository.saveLastSeen(any(), any())).thenAnswer((_) async {});
  });

  void givenGallery(List<GalleryAlbum> albums) {
    when(() => repository.galleryAlbums()).thenAnswer((_) async => albums);
  }

  void givenServerAnswers(List<LocalAlbum> albums) {
    when(() => repository.register(deviceUuid, any())).thenAnswer((_) async => albums);
  }

  List<LocalAlbumRegistration> sent() =>
      verify(() => repository.register(deviceUuid, captureAny())).captured.single as List<LocalAlbumRegistration>;

  group('RegisterLocalAlbumsUseCase', () {
    test('should send every album of the gallery with its default option', () async {
      // Arrange
      givenGallery([TestLocalAlbums.camera, TestLocalAlbums.vacaciones, TestLocalAlbums.whatsapp]);
      givenServerAnswers([]);

      // Act
      await useCase();

      // Assert
      expect(sent(), [
        LocalAlbumRegistration(
            localAlbumId: TestLocalAlbums.camera.id, name: 'Camera', defaultMode: LocalAlbumMode.backupOnly),
        LocalAlbumRegistration(
            localAlbumId: TestLocalAlbums.vacaciones.id, name: 'Vacaciones 2025', defaultMode: LocalAlbumMode.album),
        LocalAlbumRegistration(
            localAlbumId: TestLocalAlbums.whatsapp.id, name: 'WhatsApp Images',
            defaultMode: LocalAlbumMode.backupOnly),
      ]);
    });

    test('should not send the folder of the downloads of Photo Manager', () async {
      givenGallery([TestLocalAlbums.downloads, TestLocalAlbums.vacaciones]);
      givenServerAnswers([]);

      await useCase();

      expect(sent().map((album) => album.localAlbumId), [TestLocalAlbums.vacaciones.id]);
    });

    test('should answer the albums of the server with their number of files', () async {
      givenGallery([TestLocalAlbums.camera, TestLocalAlbums.vacaciones]);
      givenServerAnswers([TestLocalAlbums.cameraOnServer, TestLocalAlbums.vacacionesOnServer]);

      final albums = await useCase();

      expect(albums, [
        TestLocalAlbums.cameraOnServer.withAssetCount(1500),
        TestLocalAlbums.vacacionesOnServer.withAssetCount(600),
      ]);
      expect(albums.last.isNew, isTrue);
    });

    test('should send a renamed folder with its previous id and remember what it saw', () async {
      // Arrange: «Vacaciones 2025» was «Vacaciones» (another id) at the last registration
      when(() => repository.lastSeen(user.id)).thenAnswer((_) async => {'old-id': {'v1', 'v2', 'v3'}});
      givenGallery([TestLocalAlbums.vacaciones]);
      givenServerAnswers([]);

      // Act
      await useCase();

      // Assert
      expect(sent().single.previousLocalAlbumId, 'old-id');
      verify(() => repository.saveLastSeen(user.id, [TestLocalAlbums.vacaciones])).called(1);
    });

    test('should not remember what it saw when the server fails', () async {
      givenGallery([TestLocalAlbums.vacaciones]);
      when(() => repository.register(deviceUuid, any())).thenThrow(Exception('Network error'));

      await expectLater(useCase(), throwsException);

      verifyNever(() => repository.saveLastSeen(any(), any()));
    });

    test('should register the albums without remembering them when the user is not known', () async {
      when(() => authRepository.getCurrentUser()).thenAnswer((_) async => null);
      givenGallery([TestLocalAlbums.vacaciones]);
      givenServerAnswers([]);

      await useCase();

      expect(sent().single.previousLocalAlbumId, isNull);
      verifyNever(() => repository.lastSeen(any()));
      verifyNever(() => repository.saveLastSeen(any(), any()));
    });

    test('should register nothing where the albums are not imported yet (iOS)', () async {
      final ios = RegisterLocalAlbumsUseCase(repository, deviceRepository, authRepository, supported: false);

      expect(await ios(), isEmpty);
      verifyNever(() => repository.galleryAlbums());
      verifyNever(() => repository.register(any(), any()));
    });

    test('should send an empty list for a gallery without albums', () async {
      givenGallery([]);
      givenServerAnswers([]);

      expect(await useCase(), isEmpty);
      expect(sent(), isEmpty);
    });
  });
}
