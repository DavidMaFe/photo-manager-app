import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/domain/services/original_content_reader.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/file_metadata.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/decrypted_range_reader.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/use_cases/get_file_metadata_use_case.dart';

import '../../../../helpers/fake_jpeg_xl_codec.dart';
import '../../../../helpers/jpeg_test_bytes.dart';

class MockDecryptedRangeReader extends Mock implements DecryptedRangeReader {}

class MockGetFileMetadataUseCase extends Mock implements GetFileMetadataUseCase {}

void main() {
  late MockDecryptedRangeReader rangeReader;
  late MockGetFileMetadataUseCase getMetadata;
  late FakeJpegXlCodec codec;
  late OriginalContentReader reader;

  setUp(() {
    rangeReader = MockDecryptedRangeReader();
    getMetadata = MockGetFileMetadataUseCase();
    codec = FakeJpegXlCodec();
    reader = OriginalContentReader(rangeReader, getMetadata, codec);
  });

  group('OriginalContentReader', () {
    test('should read a photo whole with its real name and type', () async {
      final png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 1, 2]);
      when(() => getMetadata('1')).thenAnswer((_) async => const FileMetadata(name: 'IMG_1.png', mimeType: 'image/png'));
      when(() => rangeReader.plainLength('1')).thenAnswer((_) async => png.length);
      when(() => rangeReader.read('1', 0, png.length - 1)).thenAnswer((_) async => png);

      final content = await reader.read('1', isVideo: false);

      expect(content.fileName, 'IMG_1.png');
      expect(content.mimeType, 'image/png');
      expect(content.length, png.length);
      expect(await content.bytes.single, png);
      expect(codec.reconstructions, 0);
    });

    test('should give back the exact JPEG of an original stored in JPEG XL', () async {
      final jpeg = JpegTestBytes.baseline();
      final jxl = (await codec.jpegToJxl(jpeg))!;
      when(() => getMetadata('1')).thenAnswer((_) async => const FileMetadata(name: 'IMG_1.jpg', mimeType: 'image/jpeg'));
      when(() => rangeReader.plainLength('1')).thenAnswer((_) async => jxl.length);
      when(() => rangeReader.read('1', 0, jxl.length - 1)).thenAnswer((_) async => jxl);

      final content = await reader.read('1', isVideo: false);

      expect(await content.bytes.single, jpeg);
      expect(content.length, jpeg.length);
      expect(content.mimeType, 'image/jpeg');
      expect(codec.reconstructions, 1);
    });

    test('should read a video in chunks of 8 MB', () async {
      const length = OriginalContentReader.chunkLength * 2 + 10;
      when(() => getMetadata('2')).thenAnswer((_) async => const FileMetadata(name: 'VID.mp4', mimeType: 'video/mp4'));
      when(() => rangeReader.plainLength('2')).thenAnswer((_) async => length);
      when(() => rangeReader.read('2', any(), any())).thenAnswer(
          (i) async => Uint8List((i.positionalArguments[2] as int) - (i.positionalArguments[1] as int) + 1));

      final content = await reader.read('2', isVideo: true);
      final chunks = await content.bytes.toList();

      expect(chunks.map((chunk) => chunk.length), [OriginalContentReader.chunkLength,
        OriginalContentReader.chunkLength, 10]);
      verify(() => rangeReader.read('2', 0, OriginalContentReader.chunkLength - 1)).called(1);
      verify(() => rangeReader.read('2', OriginalContentReader.chunkLength * 2, length - 1)).called(1);
    });

    test('should make up a name and type from the kind of file when the metadata has none', () async {
      when(() => getMetadata('2')).thenAnswer((_) async => const FileMetadata());
      when(() => rangeReader.plainLength('2')).thenAnswer((_) async => 0);

      final video = await reader.read('2', isVideo: true);
      when(() => getMetadata('3')).thenAnswer((_) async => const FileMetadata());
      when(() => rangeReader.plainLength('3')).thenAnswer((_) async => 0);
      final photo = await reader.read('3', isVideo: false);

      expect(video.fileName, 'PhotoManager_2.mp4');
      expect(video.mimeType, 'video/mp4');
      expect(photo.fileName, 'PhotoManager_3.jpg');
      expect(photo.mimeType, 'image/jpeg');
    });
  });
}
