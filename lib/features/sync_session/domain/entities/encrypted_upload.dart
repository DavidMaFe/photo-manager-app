import 'dart:io';
import 'dart:typed_data';

/// A file ready to upload, encrypted on this device (docs/e2ee-spec.md, sections 6, 7 and 9). The server only receives
/// these values: the content, the thumbnail and the metadata are encrypted with a key of the file, which travels
/// wrapped with the current master key.
class EncryptedUpload {
  /// PMEF file in the temporary directory; it is deleted after the upload.
  final File encryptedFile;

  /// PMEF thumbnail (512 px on the long side), or null if it could not be generated.
  final Uint8List? encryptedThumbnail;

  /// Keyed hash of the content, to detect duplicates without revealing it.
  final String dedupHash;
  final bool isVideo;
  final DateTime capturedAt;
  final int? width;
  final int? height;
  final int? durationSeconds;
  final int keyVersion;
  final Uint8List encryptedFileKey;

  /// Original name and real MIME type, encrypted with the key of the file.
  final Uint8List encryptedMetadata;

  const EncryptedUpload({
    required this.encryptedFile,
    required this.encryptedThumbnail,
    required this.dedupHash,
    required this.isVideo,
    required this.capturedAt,
    this.width,
    this.height,
    this.durationSeconds,
    required this.keyVersion,
    required this.encryptedFileKey,
    required this.encryptedMetadata,
  });
}
