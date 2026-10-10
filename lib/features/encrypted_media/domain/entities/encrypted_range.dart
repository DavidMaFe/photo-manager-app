import 'dart:typed_data';

/// Some bytes of an encrypted object and the total size of the object.
class EncryptedRange {
  final Uint8List bytes;
  final int totalLength;

  const EncryptedRange({required this.bytes, required this.totalLength});
}
