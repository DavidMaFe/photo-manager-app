import 'dart:typed_data';

import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';

/// Reduced versions of the photos and videos of the device. The server cannot generate them with end-to-end
/// encryption (decision D10):
/// - the thumbnail, for the gallery: 512 px on the long side keeping the proportion, JPEG with quality 0.85
/// - the preview, for the viewer (ROADMAP-media-compression.md): 2048 px on the long side, JPEG with quality 0.85
abstract class MediaThumbnailSource {
  static const int longSide = 512;
  static const int jpegQuality = 85;
  static const int previewLongSide = 2048;
  static const int previewJpegQuality = 85;

  /// JPEG bytes, or null if the device cannot generate it.
  Future<Uint8List?> thumbnail(SyncFile file);

  /// JPEG bytes of the 2048 px version, or null for videos, for images that are not bigger than 2048 px (the viewer
  /// opens the original, which is already small) and when the device cannot generate it.
  Future<Uint8List?> preview(SyncFile file);
}
