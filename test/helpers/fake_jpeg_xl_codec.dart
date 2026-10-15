import 'dart:typed_data';

import 'package:photo_manager_app/core/jpeg_xl/domain/jpeg_xl_codec.dart';

/// JPEG XL codec without libjxl: the "JPEG XL" is a container signature followed by the JPEG with its bytes inverted
/// and the last tenth cut off, so it is smaller and only this codec rebuilds the JPEG.
class FakeJpegXlCodec implements JpegXlCodec {
  static const List<int> signature = [0x00, 0x00, 0x00, 0x0C, 0x4A, 0x58, 0x4C, 0x20, 0x0D, 0x0A, 0x87, 0x0A];

  /// Returned by [jpegToJxl] instead of the conversion (null: the device cannot convert).
  Uint8List? Function(Uint8List jpeg)? onJpegToJxl;

  /// Returned by [jxlToJpeg] instead of the reconstruction.
  Uint8List Function(Uint8List jxl)? onJxlToJpeg;

  bool unavailable = false;
  final Map<String, Uint8List> _originals = {};
  int conversions = 0;
  int reconstructions = 0;

  @override
  Future<Uint8List?> jpegToJxl(Uint8List jpeg) async {
    conversions++;
    if (onJpegToJxl case final override?) {
      return override(jpeg);
    }
    final body = Uint8List.fromList([for (final byte in jpeg.sublist(0, jpeg.length * 9 ~/ 10)) byte ^ 0xFF]);
    final jxl = Uint8List.fromList([...signature, ...body]);
    _originals[String.fromCharCodes(jxl.take(64))] = jpeg;
    return jxl;
  }

  @override
  Future<Uint8List> jxlToJpeg(Uint8List jxl) async {
    reconstructions++;
    if (unavailable) {
      throw const JpegXlUnavailableFailure();
    }
    if (onJxlToJpeg case final override?) {
      return override(jxl);
    }
    return _originals[String.fromCharCodes(jxl.take(64))] ?? (throw const JpegXlUnavailableFailure());
  }

  /// Makes [jpeg] rebuildable from [jxl], for objects that did not go through [jpegToJxl].
  void remember(Uint8List jxl, Uint8List jpeg) => _originals[String.fromCharCodes(jxl.take(64))] = jpeg;
}
