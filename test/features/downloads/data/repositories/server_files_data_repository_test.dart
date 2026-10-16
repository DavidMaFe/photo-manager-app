import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/downloads/data/data_sources/server_files_remote_data_source.dart';
import 'package:photo_manager_app/features/downloads/data/models/remote_media_file_model.dart';
import 'package:photo_manager_app/features/downloads/data/repositories/server_files_data_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/downloadable_file.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_file_ref.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/repositories/file_key_repository.dart';
import 'package:photo_manager_app/features/gallery/data/models/gallery_file_model.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';
import 'dart:typed_data';

class MockServerFilesRemoteDataSource extends Mock implements ServerFilesRemoteDataSource {}

class MockFileKeyRepository extends Mock implements FileKeyRepository {}

class MockSyncDeviceRepository extends Mock implements SyncDeviceRepository {}

void main() {
  late MockServerFilesRemoteDataSource remote;
  late MockFileKeyRepository keys;
  late MockSyncDeviceRepository devices;
  late ServerFilesDataRepository repository;

  GalleryFileModel galleryFile(String id, {EncryptedFileRef? ref}) => GalleryFileModel(
        id: id,
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: DateTime(2024, 8, 3),
        encryptedRef: ref,
      );

  setUp(() {
    remote = MockServerFilesRemoteDataSource();
    keys = MockFileKeyRepository();
    devices = MockSyncDeviceRepository();
    repository = ServerFilesDataRepository(remoteDataSource: remote, fileKeyRepository: keys,
        syncDeviceRepository: devices);
    when(() => devices.getDeviceUuid()).thenAnswer((_) async => 'phone-uuid');
    when(() => remote.markOnDevice(any(), any())).thenAnswer((_) async {});
  });

  group('ServerFilesDataRepository', () {
    test('should list the files of an album', () async {
      const file = RemoteMediaFileModel(id: '1', type: FileType.image, sizeBytes: 5);
      when(() => remote.getFiles(folderId: '3', includeSubfolders: true)).thenAnswer((_) async => [file]);

      expect(await repository.files(folderId: '3', includeSubfolders: true), [file]);
    });

    test('should ask for the details in batches of 200 and keep the keys of the files', () async {
      final ids = [for (var i = 0; i < 450; i++) '$i'];
      final ref = EncryptedFileRef(fileId: '0', keyVersion: 1, encryptedFileKey: Uint8List(72));
      when(() => remote.getFilesByIds(any())).thenAnswer((i) async => [
            for (final id in i.positionalArguments[0] as List<String>) galleryFile(id, ref: id == '0' ? ref : null),
          ]);

      final files = await repository.downloadable(ids);

      expect(files, hasLength(450));
      expect(files.first, DownloadableFile(id: '0', type: FileType.image, capturedAt: DateTime(2024, 8, 3)));
      verify(() => remote.getFilesByIds(ids.sublist(0, 200))).called(1);
      verify(() => remote.getFilesByIds(ids.sublist(200, 400))).called(1);
      verify(() => remote.getFilesByIds(ids.sublist(400))).called(1);
      verify(() => keys.remember([ref])).called(1);
    });

    test('should report the files to the server with the uuid of this device in batches of 200', () async {
      final ids = [for (var i = 0; i < 201; i++) '$i'];

      await repository.markOnDevice(ids);

      verify(() => remote.markOnDevice('phone-uuid', ids.sublist(0, 200))).called(1);
      verify(() => remote.markOnDevice('phone-uuid', ['200'])).called(1);
    });

    test('should not call the server without files', () async {
      await repository.markOnDevice([]);

      verifyNever(() => remote.markOnDevice(any(), any()));
    });
  });
}
