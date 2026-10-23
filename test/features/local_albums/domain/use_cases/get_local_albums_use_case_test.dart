import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/get_local_albums_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';

import '../../../../fixtures/test_data.dart';

class MockLocalAlbumsRepository extends Mock implements LocalAlbumsRepository {}

class MockSyncDeviceRepository extends Mock implements SyncDeviceRepository {}

void main() {
  group('GetLocalAlbumsUseCase', () {
    test('should answer the albums of the server, with the number of files of the ones in the gallery', () async {
      // Arrange: WhatsApp Images is no longer in the gallery
      final repository = MockLocalAlbumsRepository();
      final deviceRepository = MockSyncDeviceRepository();
      when(() => deviceRepository.getDeviceUuid()).thenAnswer((_) async => 'uuid');
      when(() => repository.albums('uuid'))
          .thenAnswer((_) async => [TestLocalAlbums.cameraOnServer, TestLocalAlbums.whatsappOnServer]);
      when(() => repository.galleryAlbums()).thenAnswer((_) async => [TestLocalAlbums.camera]);

      // Act
      final albums = await GetLocalAlbumsUseCase(repository, deviceRepository)();

      // Assert
      expect(albums.first.assetCount, 1500);
      expect(albums.last.assetCount, isNull);
      expect(albums.last.mode, TestLocalAlbums.whatsappOnServer.mode);
    });
  });
}
