import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/crypto/data/sodium_crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_failures.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/decrypted_range_reader.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/file_key_unwrapper.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/video_stream_server.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/use_cases/clear_media_data_use_case.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/use_cases/get_file_metadata_use_case.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/use_cases/load_media_use_case.dart';

import '../../../helpers/e2ee_test_kit.dart';
import '../../../helpers/recording_file_key_repository.dart';
import '../helpers/encrypted_media_fixtures.dart';

class FakeVideoStreamServer implements VideoStreamServer {
  bool stopped = false;

  @override
  Future<Uri> urlFor(String fileId, {String? mimeType}) async => Uri.parse('http://127.0.0.1/v/x');

  @override
  Future<void> stop() async => stopped = true;
}

void main() {
  late E2eeTestKit kit;
  late SodiumCryptoEngine engine;
  late NewKeyMaterial account;
  late EncryptedTestFile video;
  late RecordingFileKeyRepository fileKeys;
  late FakeEncryptedMediaRepository media;
  late FileKeyUnwrapper unwrapper;

  setUp(() async {
    kit = await E2eeTestKit.create();
    engine = await smallChunkEngine();
    account = await kit.material('the password', E2eeTestKit.cheapParams());
    await kit.keyring.storeNewKey(1, account);
    // 5000 bytes in chunks of 1 KiB: 5 chunks, the last one of 904 bytes
    video = await EncryptedTestFile.create(engine, account.masterKey);
    fileKeys = keysOf([video]);
    media = FakeEncryptedMediaRepository({video.fileId: video});
    unwrapper = FileKeyUnwrapper(engine, kit.store, fileKeys);
  });

  group('FileKeyUnwrapper', () {
    test('should open the key of the file with the master key of its version', () async {
      final key = await unwrapper.keyFor(video.fileId);

      expect(engine.decryptBytes(key, video.encryptedThumbnail), video.thumbnail);
    });

    test('should keep the opened key in memory', () async {
      final first = await unwrapper.keyFor(video.fileId);
      fileKeys.clear();

      expect(identical(await unwrapper.keyFor(video.fileId), first), isTrue);
    });

    test('should throw LockedFileFailure when this device does not hold the version of the file', () async {
      final locked = await EncryptedTestFile.create(engine, account.masterKey, fileId: '8', keyVersion: 4);
      fileKeys.remember([locked.ref]);

      await expectLater(unwrapper.keyFor('8'), throwsA(isA<LockedFileFailure>()));
    });

    test('should wipe and forget the keys on clear', () async {
      final key = await unwrapper.keyFor(video.fileId);

      unwrapper.clear();

      expect(key.bytes.every((byte) => byte == 0), isTrue);
      expect(identical(await unwrapper.keyFor(video.fileId), key), isFalse);
    });
  });

  group('LoadMediaUseCase', () {
    test('should decrypt the thumbnail', () async {
      final bytes = await LoadMediaUseCase(media, unwrapper, engine)(video.fileId, MediaVariant.thumbnail);

      expect(bytes, video.thumbnail);
    });

    test('should decrypt the original in another isolate', () async {
      final bytes = await LoadMediaUseCase(media, unwrapper, engine)(video.fileId, MediaVariant.original);

      expect(bytes, video.plain);
    });

    test('should not download anything for a locked file', () async {
      final locked = await EncryptedTestFile.create(engine, account.masterKey, fileId: '8', keyVersion: 4);
      fileKeys.remember([locked.ref]);

      await expectLater(LoadMediaUseCase(media, unwrapper, engine)('8', MediaVariant.thumbnail),
          throwsA(isA<LockedFileFailure>()));
      expect(media.objectRequests, 0);
    });
  });

  group('GetFileMetadataUseCase', () {
    test('should decrypt the original name and the real MIME type', () async {
      final metadata = await GetFileMetadataUseCase(fileKeys, unwrapper, engine)(video.fileId);

      expect(metadata.name, 'VID_7.mp4');
      expect(metadata.mimeType, 'video/mp4');
    });

    test('should give empty metadata for a file without it', () async {
      fileKeys.remember([RecordingFileKeyRepository.ref('9').copyWithoutMetadata()]);

      final metadata = await GetFileMetadataUseCase(fileKeys, unwrapper, engine)('9');

      expect(metadata.name, isNull);
    });
  });

  group('DecryptedRangeReader', () {
    late DecryptedRangeReader reader;

    setUp(() => reader = DecryptedRangeReader(media, unwrapper, engine));

    test('should give the plaintext size from the encrypted one', () async {
      expect(await reader.plainLength(video.fileId), 5000);
    });

    test('should read a range inside one chunk', () async {
      expect(await reader.read(video.fileId, 10, 99), video.plain.sublist(10, 100));
    });

    test('should read a range across several chunks, asking only for those chunks', () async {
      final bytes = await reader.read(video.fileId, 1000, 3100);

      expect(bytes, video.plain.sublist(1000, 3101));
      // Header first, then chunks 0..3 (1000 is in chunk 0, 3100 in chunk 3) and nothing of chunk 4
      expect(media.rangesAsked.last, (32, 32 + 4 * (1024 + 16) - 1));
    });

    test('should read the end of the file, which is in the final chunk', () async {
      expect(await reader.read(video.fileId, 4500, 4999), video.plain.sublist(4500));
    });

    test('should ask for the header only once per file', () async {
      await reader.read(video.fileId, 0, 10);
      await reader.read(video.fileId, 20, 30);

      expect(media.rangesAsked.where((range) => range == (0, 31)), hasLength(1));
    });

    test('should reject ranges outside the plaintext', () async {
      await expectLater(reader.read(video.fileId, 4000, 5000), throwsRangeError);
      await expectLater(reader.read(video.fileId, 10, 5), throwsRangeError);
    });
  });

  group('ClearMediaDataUseCase', () {
    test('should forget the keys, stop the proxy and empty the cache', () async {
      final key = await unwrapper.keyFor(video.fileId);
      final server = FakeVideoStreamServer();

      await ClearMediaDataUseCase(fileKeys, unwrapper, DecryptedRangeReader(media, unwrapper, engine), server, media)();

      expect(fileKeys.remembered, isEmpty);
      expect(key.bytes.every((byte) => byte == 0), isTrue);
      expect(server.stopped, isTrue);
      expect(media.cleared, isTrue);
    });
  });
}
