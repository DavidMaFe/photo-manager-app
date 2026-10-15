import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/original_recompressor.dart';

import '../../../../helpers/fake_jpeg_xl_codec.dart';
import '../../../../helpers/jpeg_test_bytes.dart';

void main() {
  late Directory tempDir;
  late FakeJpegXlCodec codec;
  late OriginalRecompressor recompressor;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('recompressor');
    codec = FakeJpegXlCodec();
    recompressor = OriginalRecompressor(codec);
  });

  tearDown(() => tempDir.delete(recursive: true));

  SyncFile fileOf(Uint8List content, {String mime = 'image/jpeg', String name = 'IMG_0001.jpg'}) {
    final file = File('${tempDir.path}/$name')..writeAsBytesSync(content);
    return SyncFile(
      localId: 'local-1',
      devicePath: file.path,
      hash: sha256.convert(content).toString(),
      fileName: name,
      sizeBytes: content.length,
      capturedAt: DateTime(2024, 8, 15),
      mimeType: mime,
    );
  }

  group('OriginalRecompressor', () {
    // ==================== HAPPY PATH TESTS ====================

    test('should recompress a JPEG into a smaller JPEG XL that rebuilds it exactly', () async {
      final jpeg = JpegTestBytes.baseline(tail: List.filled(400, 7));

      final jxl = await recompressor.jpegXlOf(fileOf(jpeg));

      expect(jxl, isNotNull);
      expect(jxl!.length, lessThan(jpeg.length));
      expect(await codec.jxlToJpeg(jxl), jpeg);
      // Checked before the upload
      expect(codec.reconstructions, 2);
    });

    // ==================== BUSINESS LOGIC TESTS ====================

    test('should leave videos and other images as they are', () async {
      expect(await recompressor.jpegXlOf(fileOf(Uint8List(100), mime: 'video/mp4', name: 'v.mp4')), isNull);
      expect(await recompressor.jpegXlOf(fileOf(Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 1, 2]),
          mime: 'image/png', name: 'a.png')), isNull);
      expect(codec.conversions, 0);
    });

    test('should leave as they are the JPEG that libjxl 0.11 could not rebuild', () async {
      expect(await recompressor.jpegXlOf(fileOf(JpegTestBytes.progressiveWithEmptyDht())), isNull);
      expect(codec.conversions, 0);
    });

    test('should upload the JPEG as it is when the device cannot convert it', () async {
      codec.onJpegToJxl = (_) => null;

      expect(await recompressor.jpegXlOf(fileOf(JpegTestBytes.baseline())), isNull);
    });

    test('should not use a JPEG XL that does not give back the same bytes', () async {
      final jpeg = JpegTestBytes.baseline(tail: List.filled(400, 7));
      codec.onJxlToJpeg = (_) => Uint8List.fromList([...jpeg]..[10] ^= 1);

      expect(await recompressor.jpegXlOf(fileOf(jpeg)), isNull);
    });

    test('should not use a JPEG XL that cannot be rebuilt on the device', () async {
      codec.unavailable = true;

      expect(await recompressor.jpegXlOf(fileOf(JpegTestBytes.baseline(tail: List.filled(400, 7)))), isNull);
    });

    test('should not use a JPEG XL that is not smaller', () async {
      codec.onJpegToJxl = (jpeg) => Uint8List.fromList([...FakeJpegXlCodec.signature, ...jpeg]);

      expect(await recompressor.jpegXlOf(fileOf(JpegTestBytes.baseline())), isNull);
    });

    test('should check the content and not trust the MIME type', () async {
      // A JPEG reported as HEIC by the gallery is still a JPEG
      final jpeg = JpegTestBytes.baseline(tail: List.filled(400, 7));

      expect(await recompressor.jpegXlOf(fileOf(jpeg, mime: 'image/heic', name: 'x.heic')), isNotNull);
    });
  });
}
