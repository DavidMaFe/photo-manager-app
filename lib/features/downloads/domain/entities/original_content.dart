import 'dart:typed_data';

/// The decrypted original of a file, as it is saved or shared: an original stored in JPEG XL comes as its exact JPEG.
class OriginalContent {
  final String fileName;
  final String mimeType;
  final int length;

  /// The bytes, in order; a video comes in chunks so it is never whole in memory.
  final Stream<Uint8List> bytes;

  const OriginalContent({required this.fileName, required this.mimeType, required this.length, required this.bytes});

  bool get isVideo => mimeType.startsWith('video/');
}
