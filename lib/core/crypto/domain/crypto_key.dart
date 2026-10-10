import 'dart:typed_data';

/// Symmetric key material (32 bytes) handled by the domain without depending on the crypto library.
///
/// [dispose] overwrites the bytes with zeros once the key is no longer needed.
class CryptoKey {
  static const int length = 32;

  final Uint8List bytes;

  CryptoKey(this.bytes) {
    if (bytes.length != length) {
      throw ArgumentError.value(bytes.length, 'bytes', 'A key must have $length bytes');
    }
  }

  void dispose() => bytes.fillRange(0, bytes.length, 0);
}
