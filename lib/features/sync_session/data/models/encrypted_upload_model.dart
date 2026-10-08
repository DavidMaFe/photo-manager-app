import 'dart:convert';

import 'package:photo_manager_app/features/sync_session/domain/entities/encrypted_upload.dart';

/// The "metadata" parameter of POST /api/sync_session/upload/ (docs/e2ee-spec.md, section 9).
class EncryptedUploadModel {
  const EncryptedUploadModel._();

  static Map<String, dynamic> metadataToJson(EncryptedUpload upload) => {
        'fileHash': upload.dedupHash,
        'fileType': upload.isVideo ? 'VIDEO' : 'IMAGE',
        // Device local time without offset, as the server keeps capturedAt
        'capturedAt': upload.capturedAt.toIso8601String(),
        if (upload.width != null) 'width': upload.width,
        if (upload.height != null) 'height': upload.height,
        if (upload.durationSeconds != null) 'durationSeconds': upload.durationSeconds,
        'keyVersion': upload.keyVersion,
        'encryptedFileKey': base64Encode(upload.encryptedFileKey),
        'encryptedMetadata': base64Encode(upload.encryptedMetadata),
      };
}
