import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager_app/core/crypto/data/sodium_crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/pmef_layout.dart';
import 'package:photo_manager_app/core/crypto/domain/wrap_purpose.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_file_ref.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_range.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/repositories/encrypted_media_repository.dart';

import '../../../helpers/e2ee_test_kit.dart';
import '../../../helpers/recording_file_key_repository.dart';

/// A file as the server keeps it: encrypted on the device that uploaded it, with its key wrapped with the master key.
class EncryptedTestFile {
  final String fileId;
  final Uint8List plain;
  final Uint8List thumbnail;

  /// The 2048 px version: 2500 bytes, so it has several chunks of 1 KiB with [smallChunkEngine].
  final Uint8List preview;
  final Map<String, Object?> metadata;
  late final EncryptedFileRef ref;
  late final Uint8List encryptedOriginal;
  late final Uint8List encryptedThumbnail;
  late final Uint8List encryptedPreview;

  EncryptedTestFile._(this.fileId, this.plain, this.thumbnail, this.preview, this.metadata);

  static Future<EncryptedTestFile> create(SodiumCryptoEngine engine, CryptoKey masterKey,
      {String fileId = '7', int plainLength = 5000, int keyVersion = 1, String mime = 'video/mp4',
      Uint8List? plain}) async {
    final file = EncryptedTestFile._(fileId,
        plain ?? Uint8List.fromList(List.generate(plainLength, (i) => (i * 7 + 3) & 0xff)),
        Uint8List.fromList(List.filled(300, 9)), Uint8List.fromList(List.generate(2500, (i) => (i * 3) & 0xff)),
        {'v': 1, 'name': 'VID_$fileId.mp4', 'mime': mime});
    final fileKey = engine.generateKey();
    final dir = await Directory.systemTemp.createTemp('encrypted_test_file');
    try {
      final input = File('${dir.path}/plain')..writeAsBytesSync(file.plain);
      final output = File('${dir.path}/out');
      await engine.encryptFile(fileKey, input, output);
      file.encryptedOriginal = output.readAsBytesSync();
    } finally {
      await dir.delete(recursive: true);
    }
    file.encryptedThumbnail = engine.encryptBytes(fileKey, file.thumbnail);
    file.encryptedPreview = engine.encryptBytes(fileKey, file.preview);
    file.ref = EncryptedFileRef(
      fileId: fileId,
      keyVersion: keyVersion,
      encryptedFileKey: engine.wrapKey(masterKey, fileKey.bytes, WrapPurpose.fileKey),
      encryptedMetadata: engine.encryptMetadata(fileKey, file.metadata),
    );
    return file;
  }
}

/// Engine with chunks of 1 KiB, so small files have several chunks.
Future<SodiumCryptoEngine> smallChunkEngine() async {
  final kit = await E2eeTestKit.create();
  return SodiumCryptoEngine(kit.engine.sodium, layout: const PmefLayout(chunkLog2: 10));
}

/// Serves the encrypted objects of [files] and records the ranges asked.
class FakeEncryptedMediaRepository implements EncryptedMediaRepository {
  final Map<String, EncryptedTestFile> files;
  final List<(int, int)> rangesAsked = [];
  int objectRequests = 0;
  bool cleared = false;

  FakeEncryptedMediaRepository(this.files);

  @override
  Future<Uint8List> object(String fileId, MediaVariant variant) async {
    objectRequests++;
    final file = files[fileId]!;
    return switch (variant) {
      MediaVariant.thumbnail => file.encryptedThumbnail,
      MediaVariant.preview => file.encryptedPreview,
      MediaVariant.original => file.encryptedOriginal,
    };
  }

  @override
  Future<EncryptedRange> originalRange(String fileId, int start, int end) async {
    rangesAsked.add((start, end));
    final encrypted = files[fileId]!.encryptedOriginal;
    return EncryptedRange(bytes: Uint8List.sublistView(encrypted, start, end + 1), totalLength: encrypted.length);
  }

  @override
  Future<void> clearCache() async => cleared = true;
}

RecordingFileKeyRepository keysOf(Iterable<EncryptedTestFile> files) =>
    RecordingFileKeyRepository()..remember(files.map((file) => file.ref));
