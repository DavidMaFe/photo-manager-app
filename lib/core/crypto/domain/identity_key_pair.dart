import 'dart:typed_data';

import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';

/// X25519 key pair of the user, prepared for sharing files and albums in the future.
class IdentityKeyPair {
  final Uint8List publicKey;
  final CryptoKey secretKey;

  const IdentityKeyPair({required this.publicKey, required this.secretKey});
}
