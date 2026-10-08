import 'dart:typed_data';

import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_file_ref.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/repositories/file_key_repository.dart';

/// Keeps the keys the repositories register, to check that every list of files fills the key directory.
class RecordingFileKeyRepository implements FileKeyRepository {
  final List<EncryptedFileRef> remembered = [];

  @override
  void remember(Iterable<EncryptedFileRef> refs) => remembered.addAll(refs);

  @override
  Future<EncryptedFileRef> refFor(String fileId) async => remembered.lastWhere((ref) => ref.fileId == fileId);

  @override
  void clear() => remembered.clear();

  static EncryptedFileRef ref(String fileId) =>
      EncryptedFileRef(fileId: fileId, keyVersion: 1, encryptedFileKey: Uint8List(72), encryptedMetadata: Uint8List(50));
}

extension EncryptedFileRefTestCopy on EncryptedFileRef {
  EncryptedFileRef copyWithoutMetadata() =>
      EncryptedFileRef(fileId: fileId, keyVersion: keyVersion, encryptedFileKey: encryptedFileKey);
}
