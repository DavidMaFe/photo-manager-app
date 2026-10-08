import 'dart:convert';

import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_file_ref.dart';

/// `{ encryptedFileKey, keyVersion, encryptedMetadata }` of a file in the API responses.
class EncryptedFileRefModel {
  const EncryptedFileRefModel._();

  /// Null for files uploaded before end-to-end encryption (no key). [idField] is "id" in the file lists and
  /// "fileId" in POST /api/file/keys/.
  static EncryptedFileRef? fromJson(Map<String, dynamic> json, {String idField = 'id'}) {
    final key = json['encryptedFileKey'] as String?;
    final version = json['keyVersion'] as int?;
    if (key == null || version == null) {
      return null;
    }
    final metadata = json['encryptedMetadata'] as String?;
    return EncryptedFileRef(
      fileId: json[idField].toString(),
      keyVersion: version,
      encryptedFileKey: base64Decode(key),
      encryptedMetadata: metadata == null ? null : base64Decode(metadata),
    );
  }
}
