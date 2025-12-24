import 'dart:io';


class SyncFile {
  final String devicePath;
  final String hash;
  final String fileName;
  final int sizeBytes;
  final DateTime capturedAt;
  final String mimeType;
  final int? width;
  final int?  height;
  final int? durationSeconds;

  SyncFile({
    required this.devicePath,
    required this.hash,
    required this. fileName,
    required this.sizeBytes,
    required this.capturedAt,
    required this.mimeType,
    this.width,
    this.height,
    this.durationSeconds
  });

  File get file => File(devicePath);

  bool get isImage => mimeType.contains("image/");
  bool get isVideo => mimeType.contains("video/");
  double get sizeMB => sizeBytes / (1024 * 1024);

  Map<String, dynamic> get metadata => {
    'originalFileName': fileName,
    'fileHash': hash,
    'mimeType': mimeType,
    'fileSizeBytes': sizeBytes,
    'capturedAt': capturedAt,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
    if (durationSeconds != null) 'durationSeconds': durationSeconds
  };

  @override
  bool operator ==(Object other) {
    if(identical(this, other)) return true;
    return other is SyncFile && other.hash == hash;
  }

  @override
  int get hashCode => hash.hashCode;
}