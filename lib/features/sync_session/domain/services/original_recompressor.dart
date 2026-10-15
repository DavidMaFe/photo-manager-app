import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:photo_manager_app/core/jpeg_xl/domain/jpeg_xl_codec.dart';
import 'package:photo_manager_app/core/jpeg_xl/domain/jpeg_xl_format.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';

/// The original of a JPEG recompressed into JPEG XL without loss (ROADMAP-media-compression.md, Phase 3): about 15 %
/// less to upload and to store, and the exact JPEG comes back when it is opened.
class OriginalRecompressor {
  final JpegXlCodec _codec;

  OriginalRecompressor(this._codec);

  /// The JPEG XL to upload as the original of [file], or null to upload the file as it is: it is not a JPEG, it is a
  /// JPEG that not every libjxl rebuilds ([JpegXlFormat.canRecompress]), the device cannot convert it, the JPEG XL
  /// does not give back the same bytes, or it is not smaller.
  Future<Uint8List?> jpegXlOf(SyncFile file) async {
    if (!file.isImage) {
      return null;
    }
    final jpeg = await file.file.readAsBytes();
    if (!JpegXlFormat.canRecompress(jpeg)) {
      return null;
    }
    final jxl = await _codec.jpegToJxl(jpeg);
    if (jxl == null || jxl.length >= jpeg.length) {
      return null;
    }
    // Checked before it leaves the device: a JPEG XL that does not rebuild the original is never stored
    try {
      final rebuilt = await _codec.jxlToJpeg(jxl);
      if (sha256.convert(rebuilt).toString() != sha256.convert(jpeg).toString()) {
        return null;
      }
    } on JpegXlUnavailableFailure {
      return null;
    }
    return jxl;
  }
}
