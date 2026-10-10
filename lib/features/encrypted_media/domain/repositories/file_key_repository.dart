import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_file_ref.dart';

/// Wrapped keys of the files, by id. The lists of files fill it; the files only known by id (album covers) are asked
/// to the server in batches.
abstract class FileKeyRepository {
  void remember(Iterable<EncryptedFileRef> refs);

  /// Throws UnencryptedFileFailure if the file has no key.
  Future<EncryptedFileRef> refFor(String fileId);

  /// Forgets every key (logout).
  void clear();
}
