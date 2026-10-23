import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/repositories/local_albums_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/set_local_album_modes_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/backup_progress_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';

import '../../../../fixtures/test_data.dart';

class MockLocalAlbumsRepository extends Mock implements LocalAlbumsRepository {}

class MockSyncDeviceRepository extends Mock implements SyncDeviceRepository {}

class MockBackupProgressRepository extends Mock implements BackupProgressRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  final user = TestUsers.johnDoe;
  late MockLocalAlbumsRepository repository;
  late MockBackupProgressRepository backupProgress;
  late SetLocalAlbumModesUseCase useCase;

  setUpAll(() {
    registerFallbackValue(<String, LocalAlbumMode>{});
    registerFallbackValue(<String>{});
  });

  setUp(() {
    repository = MockLocalAlbumsRepository();
    backupProgress = MockBackupProgressRepository();
    final deviceRepository = MockSyncDeviceRepository();
    final authRepository = MockAuthRepository();
    when(() => deviceRepository.getDeviceUuid()).thenAnswer((_) async => 'uuid');
    when(() => authRepository.getCurrentUser()).thenAnswer((_) async => user);
    when(() => backupProgress.addPending(any(), any())).thenAnswer((_) async {});
    // WhatsApp Images is not backed up; the camera is backed up without an album
    when(() => repository.albums('uuid'))
        .thenAnswer((_) async => [TestLocalAlbums.whatsappOnServer, TestLocalAlbums.cameraOnServer]);
    useCase = SetLocalAlbumModesUseCase(repository, deviceRepository, backupProgress, authRepository);
  });

  group('SetLocalAlbumModesUseCase', () {
    test('should send the options chosen by the user', () async {
      final modes = {TestLocalAlbums.camera.id: LocalAlbumMode.excluded};
      when(() => repository.setModes('uuid', modes)).thenAnswer((_) async => [TestLocalAlbums.cameraOnServer]);

      expect(await useCase(modes), [TestLocalAlbums.cameraOnServer]);
      verifyNever(() => backupProgress.addPending(any(), any()));
    });

    test('should have the next backup try every file of an album that was not backed up and now is', () async {
      // Arrange
      final modes = {TestLocalAlbums.whatsapp.id: LocalAlbumMode.backupOnly};
      when(() => repository.setModes('uuid', modes)).thenAnswer((_) async => []);
      when(() => repository.galleryAlbumAssetIds(TestLocalAlbums.whatsapp.id)).thenAnswer((_) async => {'w1', 'w2'});

      // Act
      await useCase(modes);

      // Assert
      verify(() => backupProgress.addPending(user.id, {'w1', 'w2'})).called(1);
    });

    test('should not add pending files when the server does not take the options', () async {
      final modes = {TestLocalAlbums.whatsapp.id: LocalAlbumMode.album};
      when(() => repository.setModes('uuid', modes)).thenThrow(Exception('Network error'));

      await expectLater(useCase(modes), throwsException);

      verifyNever(() => backupProgress.addPending(any(), any()));
    });

    test('should only read the albums when nothing changes', () async {
      expect(await useCase({}), [TestLocalAlbums.whatsappOnServer, TestLocalAlbums.cameraOnServer]);
      verifyNever(() => repository.setModes(any(), any()));
    });
  });
}
