import 'dart:typed_data';

import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';

/// Thumbnails of the photos and videos of the device. The server cannot generate them with end-to-end encryption
/// (decision D10): 512 px on the long side keeping the proportion, JPEG with quality 0.85.
abstract class MediaThumbnailSource {
  static const int longSide = 512;
  static const int jpegQuality = 85;

  /// JPEG bytes, or null if the device cannot generate it.
  Future<Uint8List?> thumbnail(SyncFile file);
}
