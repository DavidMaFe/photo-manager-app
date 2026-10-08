import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/wrap_purpose.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/app_temporary_files.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/encrypted_upload.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/media_thumbnail_source.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/upload_file_use_case.dart';

import '../../../../helpers/e2ee_test_kit.dart';

class MockSyncSessionRepository extends Mock implements SyncSessionRepository {}

class FakeEncryptedUpload extends Fake implements EncryptedUpload {}

class FakeThumbnailSource implements MediaThumbnailSource {
  Uint8List? thumbnailBytes;

  @override
  Future<Uint8List?> thumbnail(SyncFile file) async => thumbnailBytes;
}

/// What the server received: the upload and the bytes of the encrypted file, read before the use case deletes it.
class _Sent {
  late EncryptedUpload upload;
  late Uint8List encryptedFile;
}

void main() {
  late E2eeTestKit kit;
  late MockSyncSessionRepository repository;
  late FakeThumbnailSource thumbnails;
  late Directory tempDir;
  late UploadFileUseCase useCase;
  late NewKeyMaterial account;
  late List<_Sent> sent;

  const sessionId = 'session_123';
  final content = Uint8List.fromList(List.generate(3 * 1024 * 1024 + 123, (i) => (i * 31) & 0xff));

  setUpAll(() => registerFallbackValue(FakeEncryptedUpload()));

  setUp(() async {
    kit = await E2eeTestKit.create();
    account = await kit.material('the password', E2eeTestKit.cheapParams());
    await kit.keyring.storeNewKey(3, account);
    repository = MockSyncSessionRepository();
    thumbnails = FakeThumbnailSource()..thumbnailBytes = Uint8List.fromList(List.filled(20000, 7));
    tempDir = await Directory.systemTemp.createTemp('upload_use_case');
    useCase = UploadFileUseCase(repository, kit.engine, kit.store, thumbnails,
        AppTemporaryFiles(baseDirectory: () async => tempDir));
    sent = [];

    when(() => repository.uploadFile(sessionId: any(named: 'sessionId'), upload: any(named: 'upload')))
        .thenAnswer((invocation) async {
      final upload = invocation.namedArguments[#upload] as EncryptedUpload;
      sent.add(_Sent()
        ..upload = upload
        ..encryptedFile = await upload.encryptedFile.readAsBytes());
      return 'server-${sent.length}';
    });
  });

  tearDown(() => tempDir.delete(recursive: true));

  Future<SyncFile> photo({String name = 'IMG_0001.HEIC', String mime = 'image/heic', int? duration}) async {
    final file = File('${tempDir.path}/$name')..writeAsBytesSync(content);
    return SyncFile(
      localId: 'local-1',
      devicePath: file.path,
      hash: sha256.convert(content).toString(),
      fileName: name,
      sizeBytes: content.length,
      capturedAt: DateTime(2024, 8, 15, 18, 30),
      mimeType: mime,
      width: 4032,
      height: 3024,
      durationSeconds: duration,
    );
  }

  /// The key of the file, unwrapped with the master key as the viewing device will do.
  CryptoKey fileKeyOf(EncryptedUpload upload) =>
      CryptoKey(kit.engine.unwrapKey(account.masterKey, upload.encryptedFileKey, WrapPurpose.fileKey));

  Directory uploadsDir() => Directory('${tempDir.path}/uploads');

  group('UploadFileUseCase', () {
    // ==================== HAPPY PATH TESTS ====================

    test('should upload the content encrypted with a key that only the master key opens', () async {
      // Act
      final result = await useCase(sessionId: sessionId, file: await photo());

      // Assert
      expect(result.serverFileId, 'server-1');
      final upload = sent.single.upload;
      expect(upload.keyVersion, 3);
      expect(sent.single.encryptedFile.length, greaterThan(content.length));
      expect(utf8.decode(sent.single.encryptedFile.sublist(0, 4)), 'PMEF');

      // The device that views it unwraps the key and decrypts the content
      final key = fileKeyOf(upload);
      final encrypted = File('${tempDir.path}/check.pmef')..writeAsBytesSync(sent.single.encryptedFile);
      final decrypted = File('${tempDir.path}/check.out');
      await kit.engine.decryptFile(key, encrypted, decrypted);
      expect(await decrypted.readAsBytes(), content);
    });

    test('should encrypt the thumbnail and the metadata with the same key', () async {
      await useCase(sessionId: sessionId, file: await photo());

      final upload = sent.single.upload;
      final key = fileKeyOf(upload);
      expect(kit.engine.decryptBytes(key, upload.encryptedThumbnail!), thumbnails.thumbnailBytes);
      expect(kit.engine.decryptMetadata(key, upload.encryptedMetadata),
          {'v': 1, 'name': 'IMG_0001.HEIC', 'mime': 'image/heic'});
    });

    test('should send the keyed hash of the content instead of its SHA-256', () async {
      final file = await photo();

      await useCase(sessionId: sessionId, file: file);

      final dedupKey = kit.engine.dedupKey(account.masterKey);
      final expected = kit.engine.dedupHash(dedupKey, Uint8List.fromList(sha256.convert(content).bytes));
      expect(sent.single.upload.dedupHash, expected);
      expect(sent.single.upload.dedupHash, isNot(file.hash));
    });

    test('should send the fields the server keeps in clear', () async {
      await useCase(sessionId: sessionId, file: await photo(name: 'VID.mp4', mime: 'video/mp4', duration: 12));

      final upload = sent.single.upload;
      expect(upload.isVideo, isTrue);
      expect(upload.capturedAt, DateTime(2024, 8, 15, 18, 30));
      expect(upload.width, 4032);
      expect(upload.height, 3024);
      expect(upload.durationSeconds, 12);
    });

    test('should use a new key for every file', () async {
      final file = await photo();

      await useCase(sessionId: sessionId, file: file);
      await useCase(sessionId: sessionId, file: file);

      expect(fileKeyOf(sent[0].upload).bytes, isNot(fileKeyOf(sent[1].upload).bytes));
      expect(sent[0].encryptedFile, isNot(sent[1].encryptedFile));
    });

    // ==================== BUSINESS LOGIC TESTS ====================

    test('should upload without a thumbnail when the device cannot generate it', () async {
      thumbnails.thumbnailBytes = null;

      await useCase(sessionId: sessionId, file: await photo());

      expect(sent.single.upload.encryptedThumbnail, isNull);
    });

    test('should delete the encrypted copy after the upload', () async {
      await useCase(sessionId: sessionId, file: await photo());

      expect(uploadsDir().listSync(), isEmpty);
    });

    test('should delete the encrypted copy when the upload fails', () async {
      when(() => repository.uploadFile(sessionId: any(named: 'sessionId'), upload: any(named: 'upload')))
          .thenThrow(Exception('network'));

      await expectLater(useCase(sessionId: sessionId, file: await photo()), throwsException);

      expect(uploadsDir().listSync(), isEmpty);
    });

    test('should throw MissingCurrentKeyFailure without a current key on this device', () async {
      await kit.store.clear();

      await expectLater(useCase(sessionId: sessionId, file: await photo()),
          throwsA(isA<MissingCurrentKeyFailure>()));
      verifyNever(() => repository.uploadFile(sessionId: any(named: 'sessionId'), upload: any(named: 'upload')));
    });

    // ==================== VALIDATION ERROR TESTS ====================

    test('should throw with an empty session id', () async {
      await expectLater(useCase(sessionId: '  ', file: await photo()), throwsException);
      verifyNever(() => repository.uploadFile(sessionId: any(named: 'sessionId'), upload: any(named: 'upload')));
    });
  });
}
