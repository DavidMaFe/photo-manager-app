import 'dart:typed_data';

/// Lossless recompression of JPEG into JPEG XL (ROADMAP-media-compression.md): the JPEG XL keeps the DCT
/// coefficients of the JPEG and the data to rebuild it byte for byte, in about 15 % less space.
abstract class JpegXlCodec {
  /// The JPEG XL of [jpeg], or null if this device cannot convert it (no codec on the platform, or the codec failed).
  Future<Uint8List?> jpegToJxl(Uint8List jpeg);

  /// The exact JPEG kept in [jxl]. Throws [JpegXlUnavailableFailure] if this device cannot rebuild it.
  Future<Uint8List> jxlToJpeg(Uint8List jxl);
}

/// The JPEG XL of an original cannot be rebuilt on this device (e.g. a platform without the codec). The viewer keeps
/// the 2048 px version on screen.
class JpegXlUnavailableFailure implements Exception {
  const JpegXlUnavailableFailure();

  @override
  String toString() => 'JpegXlUnavailableFailure';
}
