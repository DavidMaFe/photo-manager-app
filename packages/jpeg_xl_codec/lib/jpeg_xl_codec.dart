import 'package:flutter/services.dart';

/// Channel of the native side. The work runs on a background thread of the plugin, one conversion at a time
/// (libjxl reserves several hundred MB of native memory while it works).
class JpegXlCodecChannel {
  static const MethodChannel _channel = MethodChannel('com.photomanagerpro/jpeg_xl_codec');

  const JpegXlCodecChannel();

  /// JPEG XL with the data to rebuild [jpeg] byte for byte (libjxl `JxlEncoderStoreJPEGMetadata`).
  Future<Uint8List> jpegToJxl(Uint8List jpeg) async =>
      (await _channel.invokeMethod<Uint8List>('jpegToJxl', jpeg))!;

  /// The exact JPEG kept in [jxl].
  Future<Uint8List> jxlToJpeg(Uint8List jxl) async =>
      (await _channel.invokeMethod<Uint8List>('jxlToJpeg', jxl))!;
}
