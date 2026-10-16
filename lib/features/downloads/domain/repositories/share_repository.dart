import 'dart:typed_data';

/// Sharing files with other apps through the share sheet of the system.
abstract class ShareRepository {
  /// Path of a file of the gallery, readable by the share sheet.
  Future<String> galleryFilePath(String localId);

  /// Writes a decrypted original into the private cache of the app, only to share it; returns its path.
  Future<String> writeTemporary(String fileName, Stream<Uint8List> bytes);

  /// Free bytes of the private storage of the app, where the temporary files go.
  Future<int> temporaryFreeBytes();

  /// Opens the share sheet with these files.
  Future<void> share(List<String> paths);

  /// Removes every temporary file (when the app comes back to the foreground and when it starts).
  Future<void> clearTemporary();
}
