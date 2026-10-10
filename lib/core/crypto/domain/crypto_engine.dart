import 'dart:io';
import 'dart:typed_data';

import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/identity_key_pair.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/password_keys.dart';
import 'package:photo_manager_app/core/crypto/domain/pmef_layout.dart';
import 'package:photo_manager_app/core/crypto/domain/wrap_purpose.dart';

/// Every cryptographic operation of the end-to-end encryption (docs/e2ee-spec.md). Implementations must reproduce the
/// test vectors of docs/e2ee-test-vectors.json byte by byte.
///
/// Decryption errors throw [DecryptionFailure]; they never reveal key material.
abstract class CryptoEngine {
  PmefLayout get layout;

  Uint8List randomBytes(int length);

  /// New random 32-byte key (master key, file key or recovery key).
  CryptoKey generateKey();

  /// Argon2id over the NFC-normalized password, then authKey and KEK (section 5).
  Future<PasswordKeys> deriveFromPassword(String password, KdfParams params);

  CryptoKey recoveryWrapKey(CryptoKey recoveryKey);

  CryptoKey recoveryAuthKey(CryptoKey recoveryKey);

  CryptoKey dedupKey(CryptoKey masterKey);

  /// Proof that a device holds the master key, without revealing it.
  CryptoKey masterKeyAuth(CryptoKey masterKey);

  /// nonce (24 B) || XChaCha20-Poly1305(secret) with AAD "PM-WRAP-v1|purpose" (section 4.1).
  Uint8List wrapKey(CryptoKey wrappingKey, Uint8List secret, WrapPurpose purpose);

  Uint8List unwrapKey(CryptoKey wrappingKey, Uint8List wrapped, WrapPurpose purpose);

  IdentityKeyPair generateIdentityKeyPair();

  /// SHA-256 of the plain content, read in chunks (a 100 MB video is never loaded in memory).
  Future<Uint8List> contentSha256(File file);

  /// Keyed hash the server uses to detect duplicates without learning the content (section 7.2).
  String dedupHash(CryptoKey dedupKey, Uint8List contentSha256);

  Uint8List encryptMetadata(CryptoKey fileKey, Map<String, Object?> metadata);

  Map<String, Object?> decryptMetadata(CryptoKey fileKey, Uint8List encrypted);

  /// PMEF in memory, for small objects such as thumbnails.
  Uint8List encryptBytes(CryptoKey key, Uint8List plain);

  Uint8List decryptBytes(CryptoKey key, Uint8List encrypted);

  /// Same as [decryptBytes] in another isolate, for big objects (originals of up to 20 MB).
  Future<Uint8List> decryptBytesInBackground(CryptoKey key, Uint8List encrypted);

  /// PMEF file to file with one chunk in memory at a time.
  Future<void> encryptFile(CryptoKey key, File input, File output);

  Future<void> decryptFile(CryptoKey key, File input, File output);

  /// One chunk, given the header of its object (random access for the video proxy).
  Uint8List decryptChunk(CryptoKey key, Uint8List header, int index, Uint8List encryptedChunk, {required bool isFinal});
}
