import 'dart:typed_data';

/// What the app needs to open a file: its key wrapped with the master key of [keyVersion] and its encrypted metadata
/// (docs/e2ee-spec.md, sections 4 and 7). The server returns it with every file.
class EncryptedFileRef {
  final String fileId;
  final int keyVersion;
  final Uint8List encryptedFileKey;
  final Uint8List? encryptedMetadata;

  const EncryptedFileRef({
    required this.fileId,
    required this.keyVersion,
    required this.encryptedFileKey,
    this.encryptedMetadata,
  });
}
