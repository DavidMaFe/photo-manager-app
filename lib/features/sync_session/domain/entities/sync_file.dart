import 'dart:io';


/// A photo or video of the device to back up. [hash] is the SHA-256 of its content; it never leaves the device (the
/// server receives a keyed hash of it).
class SyncFile {
  final String localId;
  final String devicePath;
  final String hash;
  final String fileName;
  final int sizeBytes;
  final DateTime capturedAt;
  final String mimeType;
  final int? width;
  final int?  height;
  final int? durationSeconds;

  /// The album of the gallery the file is in (the bucket of MediaStore on Android), or null. The server puts the file
  /// in the album of Photo Manager linked to it (ROADMAP-local-albums.md).
  final String? localAlbumId;

  SyncFile({
    required this.localId,
    required this.devicePath,
    required this.hash,
    required this. fileName,
    required this.sizeBytes,
    required this.capturedAt,
    required this.mimeType,
    this.width,
    this.height,
    this.durationSeconds,
    this.localAlbumId,
  });

  /// This file in the album [localAlbumId] of the gallery.
  SyncFile inAlbum(String? localAlbumId) => SyncFile(
        localId: localId,
        devicePath: devicePath,
        hash: hash,
        fileName: fileName,
        sizeBytes: sizeBytes,
        capturedAt: capturedAt,
        mimeType: mimeType,
        width: width,
        height: height,
        durationSeconds: durationSeconds,
        localAlbumId: localAlbumId,
      );

  File get file => File(devicePath);

  bool get isImage => mimeType.contains("image/");
  bool get isVideo => mimeType.contains("video/");
  double get sizeMB => sizeBytes / (1024 * 1024);

  @override
  bool operator ==(Object other) {
    if(identical(this, other)) return true;
    return other is SyncFile && other.hash == hash;
  }

  @override
  int get hashCode => hash.hashCode;
}