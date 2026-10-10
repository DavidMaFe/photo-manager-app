import 'dart:typed_data';

import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_range.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';

/// The encrypted objects of the files. They are kept on disk only encrypted, in a cache with a size limit
/// (docs/e2ee-spec.md, section 11).
abstract class EncryptedMediaRepository {
  Future<Uint8List> object(String fileId, MediaVariant variant);

  /// Bytes [start]..[end] (both inclusive) of the original, for the video proxy.
  Future<EncryptedRange> originalRange(String fileId, int start, int end);

  Future<void> clearCache();
}
