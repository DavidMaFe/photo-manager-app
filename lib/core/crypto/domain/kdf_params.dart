import 'dart:typed_data';

/// Argon2id parameters of a password (docs/e2ee-spec.md, section 5.1).
class KdfParams {
  static const String argon2id13 = 'argon2id13';
  static const int saltLength = 16;

  /// Defaults for new passwords: 3 iterations and 64 MiB (decision D7).
  static const int defaultOps = 3;
  static const int defaultMemBytes = 64 * 1024 * 1024;

  final Uint8List salt;
  final String algorithm;
  final int ops;
  final int memBytes;

  KdfParams({
    required this.salt,
    this.algorithm = argon2id13,
    this.ops = defaultOps,
    this.memBytes = defaultMemBytes,
  }) {
    if (salt.length != saltLength) {
      throw ArgumentError.value(salt.length, 'salt', 'The salt must have $saltLength bytes');
    }
    if (algorithm != argon2id13) {
      throw ArgumentError.value(algorithm, 'algorithm', 'Only $argon2id13 is supported');
    }
  }
}
