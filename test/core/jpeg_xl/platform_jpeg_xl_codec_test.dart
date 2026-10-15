import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/jpeg_xl/data/platform_jpeg_xl_codec.dart';
import 'package:photo_manager_app/core/jpeg_xl/domain/jpeg_xl_codec.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.photomanagerpro/jpeg_xl_codec');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const codec = PlatformJpegXlCodec();

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('PlatformJpegXlCodec', () {
    test('should send the bytes to the plugin and return its result', () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return Uint8List.fromList(call.method == 'jpegToJxl' ? [1, 2] : [3, 4, 5]);
      });

      expect(await codec.jpegToJxl(Uint8List.fromList([9, 9, 9])), [1, 2]);
      expect(await codec.jxlToJpeg(Uint8List.fromList([1, 2])), [3, 4, 5]);
      expect(calls.map((c) => c.method), ['jpegToJxl', 'jxlToJpeg']);
      expect(calls.first.arguments, [9, 9, 9]);
    });

    test('should give no JPEG XL when the plugin fails, so the JPEG is uploaded as it is', () async {
      messenger.setMockMethodCallHandler(channel, (call) async => throw PlatformException(code: 'JXL_FAILED'));

      expect(await codec.jpegToJxl(Uint8List(3)), isNull);
    });

    test('should give no JPEG XL on a platform without the plugin', () async {
      // No handler: MissingPluginException, as on iOS
      expect(await codec.jpegToJxl(Uint8List(3)), isNull);
    });

    test('should throw JpegXlUnavailableFailure when the JPEG cannot be rebuilt', () async {
      await expectLater(codec.jxlToJpeg(Uint8List(3)), throwsA(isA<JpegXlUnavailableFailure>()));

      messenger.setMockMethodCallHandler(channel, (call) async => throw PlatformException(code: 'JXL_FAILED'));
      await expectLater(codec.jxlToJpeg(Uint8List(3)), throwsA(isA<JpegXlUnavailableFailure>()));
    });
  });
}
