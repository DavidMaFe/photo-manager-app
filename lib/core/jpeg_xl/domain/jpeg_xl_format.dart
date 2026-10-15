import 'dart:typed_data';

/// Format checks of the originals, on their bytes (ROADMAP-media-compression.md, Phase 0).
abstract final class JpegXlFormat {
  /// JPEG XL container (ISO/IEC 18181-2), which the recompression with the JPEG reconstruction data produces.
  static const List<int> _container = [0x00, 0x00, 0x00, 0x0C, 0x4A, 0x58, 0x4C, 0x20, 0x0D, 0x0A, 0x87, 0x0A];

  /// JPEG XL bare codestream.
  static const List<int> _codestream = [0xFF, 0x0A];

  static bool isJpegXl(Uint8List bytes) => _startsWith(bytes, _container) || _startsWith(bytes, _codestream);

  static bool isJpeg(Uint8List bytes) =>
      bytes.length > 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;

  /// Whether [jpeg] can be recompressed into a JPEG XL that every libjxl rebuilds exactly.
  ///
  /// JPEG with a DHT segment without tables (length 2, typical of WhatsApp and other apps) are converted by
  /// libjxl 0.10.1, the one of the app, but libjxl 0.11 cannot rebuild them ("Empty Huffman table"): they are
  /// uploaded as they are, so no stored file depends on an old version of the library.
  static bool canRecompress(Uint8List jpeg) {
    if (!isJpeg(jpeg)) {
      return false;
    }
    var i = 2;
    while (i + 3 < jpeg.length) {
      if (jpeg[i] != 0xFF) {
        // Inside entropy-coded data: move to the next marker
        i++;
        continue;
      }
      final marker = jpeg[i + 1];
      // Fill bytes, stuffed zeros and markers without length
      if (marker == 0xFF) {
        i++;
        continue;
      }
      if (marker == 0x00 || marker == 0x01 || (marker >= 0xD0 && marker <= 0xD7)) {
        i += 2;
        continue;
      }
      if (marker == 0xD9) {
        return true;
      }
      final length = (jpeg[i + 2] << 8) | jpeg[i + 3];
      if (length < 2) {
        return false;
      }
      if (marker == 0xC4 && length == 2) {
        return false;
      }
      i += 2 + length;
    }
    return true;
  }

  static bool _startsWith(Uint8List bytes, List<int> prefix) {
    if (bytes.length < prefix.length) {
      return false;
    }
    for (var i = 0; i < prefix.length; i++) {
      if (bytes[i] != prefix[i]) {
        return false;
      }
    }
    return true;
  }
}
