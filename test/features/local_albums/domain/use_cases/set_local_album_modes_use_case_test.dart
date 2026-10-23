import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/set_local_album_modes_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';

import '../../../../fixtures/test_data.dart';

class MockLocalAlbumsRepository extends Mock implements LocalAlbumsRepository {}

class MockSyncDeviceRepository extends Mock implements SyncDeviceRepository {}

void main() {
  late MockLocalAlbumsRepository repository;
  late SetLocalAlbumModesUseCase useCase;

  setUpAll(() {
    registerFallbackValue(<String, LocalAlbumMode>{});
  });

  setUp(() {
    repository = MockLocalAlbumsRepository();
    final deviceRepository = MockSyncDeviceRepository();
    when(() => deviceRepository.getDeviceUuid()).thenAnswer((_) async => 'uuid');
    useCase = SetLocalAlbumModesUseCase(repository, deviceRepository);
  });

  group('SetLocalAlbumModesUseCase', () {
    test('should send the options chosen by the user', () async {
      final modes = {TestLocalAlbums.whatsapp.id: LocalAlbumMode.excluded};
      when(() => repository.setModes('uuid', modes)).thenAnswer((_) async => [TestLocalAlbums.whatsappOnServer]);

      expect(await useCase(modes), [TestLocalAlbums.whatsappOnServer]);
    });

    test('should only read the albums when nothing changes', () async {
      when(() => repository.albums('uuid')).thenAnswer((_) async => [TestLocalAlbums.cameraOnServer]);

      expect(await useCase({}), [TestLocalAlbums.cameraOnServer]);
      verifyNever(() => repository.setModes(any(), any()));
    });
  });
}
