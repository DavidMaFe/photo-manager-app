import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/jpeg_xl/domain/jpeg_xl_format.dart';

import '../../helpers/fake_jpeg_xl_codec.dart';
import '../../helpers/jpeg_test_bytes.dart';

void main() {
  group('JpegXlFormat', () {
    group('isJpegXl', () {
      test('should recognise the JPEG XL container and the bare codestream', () {
        expect(JpegXlFormat.isJpegXl(Uint8List.fromList([...FakeJpegXlCodec.signature, 1, 2])), isTrue);
        expect(JpegXlFormat.isJpegXl(Uint8List.fromList([0xFF, 0x0A, 0xFA])), isTrue);
      });

      test('should not take a JPEG or a short object for JPEG XL', () {
        expect(JpegXlFormat.isJpegXl(JpegTestBytes.baseline()), isFalse);
        expect(JpegXlFormat.isJpegXl(Uint8List.fromList([0x00, 0x00, 0x00])), isFalse);
        expect(JpegXlFormat.isJpegXl(Uint8List(0)), isFalse);
      });
    });

    group('canRecompress', () {
      test('should accept a baseline JPEG and a progressive one with full tables', () {
        expect(JpegXlFormat.canRecompress(JpegTestBytes.baseline()), isTrue);
        expect(JpegXlFormat.canRecompress(JpegTestBytes.progressive()), isTrue);
      });

      test('should accept data after the end of the image (Samsung trailers)', () {
        expect(JpegXlFormat.canRecompress(JpegTestBytes.baseline(tail: [0x53, 0x45, 0x46, 0x54, 0xFF, 0xC4])), isTrue);
      });

      test('should refuse a JPEG with a DHT segment without tables, which libjxl 0.11 cannot rebuild', () {
        expect(JpegXlFormat.canRecompress(JpegTestBytes.progressiveWithEmptyDht()), isFalse);
      });

      test('should refuse what is not a JPEG or a segment with an impossible length', () {
        expect(JpegXlFormat.canRecompress(Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0, 0])), isFalse);
        expect(JpegXlFormat.canRecompress(Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x01, 0, 0])), isFalse);
      });

      test('should not read past the end of a truncated JPEG', () {
        final jpeg = JpegTestBytes.baseline();

        expect(() => JpegXlFormat.canRecompress(Uint8List.sublistView(jpeg, 0, jpeg.length - 20)), returnsNormally);
      });
    });
  });
}
