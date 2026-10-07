import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as dart_crypto;
import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/decryption_failure.dart';
import 'package:photo_manager_app/core/crypto/domain/identity_key_pair.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/password_keys.dart';
import 'package:photo_manager_app/core/crypto/domain/pmef_layout.dart';
import 'package:photo_manager_app/core/crypto/domain/wrap_purpose.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

/// [CryptoEngine] on libsodium (docs/e2ee-spec.md). Keys only become libsodium secure keys for the duration of each
/// call, and those are disposed right after.
class SodiumCryptoEngine implements CryptoEngine {
  static const int _nonceLength = 24;
  static const String _metadataAad = 'PM-META-v1';
  static const String _wrapAadPrefix = 'PM-WRAP-v1|';

  final SodiumSumo sodium;

  @override
  final PmefLayout layout;

  SodiumCryptoEngine(this.sodium, {this.layout = const PmefLayout()});

  // ==================== KEYS ====================

  @override
  Uint8List randomBytes(int length) => sodium.randombytes.buf(length);

  @override
  CryptoKey generateKey() => CryptoKey(randomBytes(CryptoKey.length));

  @override
  Future<PasswordKeys> deriveFromPassword(String password, KdfParams params) async {
    // NFC: the same password typed on iOS and Android must give the same bytes (decision D8)
    final normalized = unorm.nfc(password);
    final salt = params.salt;
    final ops = params.ops;
    final memBytes = params.memBytes;

    // Argon2id takes from tens to hundreds of milliseconds on a phone: it runs in another isolate so the UI keeps
    // animating. Only sendable values (strings, numbers and bytes) cross the isolate boundary.
    final derived = await sodium.runIsolated((sodium, _, __) {
      final secret = sodium.crypto.pwhash(
        outLen: CryptoKey.length,
        password: normalized.toCharArray(),
        salt: salt,
        opsLimit: ops,
        memLimit: memBytes,
        alg: CryptoPwhashAlgorithm.argon2id13,
      );
      try {
        return [
          for (final (id, context) in [(1, 'PMauth__'), (2, 'PMkek___')])
            _extract(sodium.crypto.kdf.deriveFromKey(
                masterKey: secret, context: context, subkeyId: BigInt.from(id), subkeyLen: CryptoKey.length)),
        ];
      } finally {
        secret.dispose();
      }
    });
    return PasswordKeys(authKey: CryptoKey(derived[0]), kek: CryptoKey(derived[1]));
  }

  static Uint8List _extract(SecureKey key) {
    try {
      return key.extractBytes();
    } finally {
      key.dispose();
    }
  }

  @override
  CryptoKey recoveryWrapKey(CryptoKey recoveryKey) => _deriveFrom(recoveryKey, 1, 'PMrecwrp');

  @override
  CryptoKey recoveryAuthKey(CryptoKey recoveryKey) => _deriveFrom(recoveryKey, 2, 'PMrecaut');

  @override
  CryptoKey dedupKey(CryptoKey masterKey) => _deriveFrom(masterKey, 1, 'PMdedup_');

  @override
  CryptoKey masterKeyAuth(CryptoKey masterKey) => _deriveFrom(masterKey, 2, 'PMmkauth');

  @override
  Uint8List wrapKey(CryptoKey wrappingKey, Uint8List secret, WrapPurpose purpose) {
    return _seal(wrappingKey, secret, _aad(purpose), randomBytes(_nonceLength));
  }

  /// Same as [wrapKey] with a fixed nonce. Only for the test vectors.
  Uint8List wrapKeyWithNonce(CryptoKey wrappingKey, Uint8List secret, WrapPurpose purpose, Uint8List nonce) {
    return _seal(wrappingKey, secret, _aad(purpose), nonce);
  }

  @override
  Uint8List unwrapKey(CryptoKey wrappingKey, Uint8List wrapped, WrapPurpose purpose) {
    return _open(wrappingKey, wrapped, _aad(purpose));
  }

  @override
  IdentityKeyPair generateIdentityKeyPair() {
    final keyPair = sodium.crypto.box.keyPair();
    try {
      return IdentityKeyPair(publicKey: keyPair.publicKey, secretKey: CryptoKey(keyPair.secretKey.extractBytes()));
    } finally {
      keyPair.secretKey.dispose();
    }
  }

  /// Identity key pair from a seed. Only for the test vectors.
  IdentityKeyPair identityKeyPairFromSeed(CryptoKey seed) {
    final secureSeed = SecureKey.fromList(sodium, seed.bytes);
    final keyPair = sodium.crypto.box.seedKeyPair(secureSeed);
    try {
      return IdentityKeyPair(publicKey: keyPair.publicKey, secretKey: CryptoKey(keyPair.secretKey.extractBytes()));
    } finally {
      secureSeed.dispose();
      keyPair.secretKey.dispose();
    }
  }

  // ==================== DUPLICATES AND METADATA ====================

  @override
  Future<Uint8List> contentSha256(File file) async {
    final digest = await dart_crypto.sha256.bind(file.openRead()).first;
    return Uint8List.fromList(digest.bytes);
  }

  @override
  String dedupHash(CryptoKey dedupKey, Uint8List contentSha256) {
    final key = SecureKey.fromList(sodium, dedupKey.bytes);
    try {
      final hash = sodium.crypto.genericHash(message: contentSha256, outLen: 32, key: key);
      return hash.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    } finally {
      key.dispose();
    }
  }

  @override
  Uint8List encryptMetadata(CryptoKey fileKey, Map<String, Object?> metadata) {
    return encryptMetadataWithNonce(fileKey, metadata, randomBytes(_nonceLength));
  }

  /// Same as [encryptMetadata] with a fixed nonce. Only for the test vectors.
  Uint8List encryptMetadataWithNonce(CryptoKey fileKey, Map<String, Object?> metadata, Uint8List nonce) {
    return _seal(fileKey, Uint8List.fromList(utf8.encode(jsonEncode(metadata))), _ascii(_metadataAad), nonce);
  }

  @override
  Map<String, Object?> decryptMetadata(CryptoKey fileKey, Uint8List encrypted) {
    final plain = _open(fileKey, encrypted, _ascii(_metadataAad));
    return Map<String, Object?>.from(jsonDecode(utf8.decode(plain)) as Map);
  }

  // ==================== PMEF ====================

  @override
  Uint8List encryptBytes(CryptoKey key, Uint8List plain) => encryptBytesWithNoncePrefix(key, plain, null);

  /// Same as [encryptBytes]; a fixed nonce prefix is only for the test vectors.
  Uint8List encryptBytesWithNoncePrefix(CryptoKey key, Uint8List plain, Uint8List? noncePrefix) {
    final header = _header(noncePrefix ?? randomBytes(PmefLayout.noncePrefixLength));
    final secureKey = SecureKey.fromList(sodium, key.bytes);
    try {
      final out = BytesBuilder(copy: false)..add(header);
      final chunks = layout.chunkCount(plain.length);
      for (var i = 0; i < chunks; i++) {
        final start = i * layout.chunkLength;
        final end = start + layout.chunkLength < plain.length ? start + layout.chunkLength : plain.length;
        out.add(_encryptChunk(secureKey, header, i, Uint8List.sublistView(plain, start, end), i == chunks - 1));
      }
      return out.toBytes();
    } finally {
      secureKey.dispose();
    }
  }

  @override
  Uint8List decryptBytes(CryptoKey key, Uint8List encrypted) {
    final header = _readHeader(encrypted);
    final chunks = layout.chunkCount(_plainLength(encrypted.length));
    final secureKey = SecureKey.fromList(sodium, key.bytes);
    try {
      final out = BytesBuilder(copy: false);
      for (var i = 0; i < chunks; i++) {
        final start = layout.chunkOffset(i);
        final end = start + layout.encryptedChunkLength < encrypted.length
            ? start + layout.encryptedChunkLength
            : encrypted.length;
        out.add(_decryptChunk(secureKey, header, i, Uint8List.sublistView(encrypted, start, end), i == chunks - 1));
      }
      return out.toBytes();
    } finally {
      secureKey.dispose();
    }
  }

  @override
  Future<void> encryptFile(CryptoKey key, File input, File output) async {
    final length = await input.length();
    final chunks = layout.chunkCount(length);
    final header = _header(randomBytes(PmefLayout.noncePrefixLength));
    final secureKey = SecureKey.fromList(sodium, key.bytes);
    final reader = await input.open();
    final writer = await output.open(mode: FileMode.write);
    try {
      await writer.writeFrom(header);
      for (var i = 0; i < chunks; i++) {
        final plain = await reader.read(layout.chunkLength);
        await writer.writeFrom(_encryptChunk(secureKey, header, i, plain, i == chunks - 1));
      }
    } finally {
      secureKey.dispose();
      await reader.close();
      await writer.close();
    }
  }

  @override
  Future<void> decryptFile(CryptoKey key, File input, File output) async {
    final length = await input.length();
    final chunks = layout.chunkCount(_plainLength(length));
    final secureKey = SecureKey.fromList(sodium, key.bytes);
    final reader = await input.open();
    final writer = await output.open(mode: FileMode.write);
    try {
      final header = _readHeader(await reader.read(PmefLayout.headerLength));
      for (var i = 0; i < chunks; i++) {
        final encrypted = await reader.read(layout.encryptedChunkLength);
        await writer.writeFrom(_decryptChunk(secureKey, header, i, encrypted, i == chunks - 1));
      }
    } finally {
      secureKey.dispose();
      await reader.close();
      await writer.close();
    }
  }

  @override
  Uint8List decryptChunk(CryptoKey key, Uint8List header, int index, Uint8List encryptedChunk,
      {required bool isFinal}) {
    final secureKey = SecureKey.fromList(sodium, key.bytes);
    try {
      return _decryptChunk(secureKey, _readHeader(header), index, encryptedChunk, isFinal);
    } finally {
      secureKey.dispose();
    }
  }

  // ==================== HELPERS ====================

  CryptoKey _deriveFrom(CryptoKey key, int id, String context) {
    final secureKey = SecureKey.fromList(sodium, key.bytes);
    try {
      return _derive(secureKey, id, context);
    } finally {
      secureKey.dispose();
    }
  }

  CryptoKey _derive(SecureKey key, int id, String context) {
    final subkey = sodium.crypto.kdf.deriveFromKey(
      masterKey: key,
      context: context,
      subkeyId: BigInt.from(id),
      subkeyLen: CryptoKey.length,
    );
    try {
      return CryptoKey(subkey.extractBytes());
    } finally {
      subkey.dispose();
    }
  }

  Uint8List _seal(CryptoKey key, Uint8List plain, Uint8List aad, Uint8List nonce) {
    final secureKey = SecureKey.fromList(sodium, key.bytes);
    try {
      final cipherText = sodium.crypto.aeadXChaCha20Poly1305IETF.encrypt(
        message: plain,
        nonce: nonce,
        key: secureKey,
        additionalData: aad,
      );
      return Uint8List.fromList([...nonce, ...cipherText]);
    } finally {
      secureKey.dispose();
    }
  }

  Uint8List _open(CryptoKey key, Uint8List sealed, Uint8List aad) {
    if (sealed.length < _nonceLength + PmefLayout.tagLength) {
      throw const DecryptionFailure('The encrypted value is too short');
    }
    final secureKey = SecureKey.fromList(sodium, key.bytes);
    try {
      return sodium.crypto.aeadXChaCha20Poly1305IETF.decrypt(
        cipherText: Uint8List.sublistView(sealed, _nonceLength),
        nonce: Uint8List.sublistView(sealed, 0, _nonceLength),
        key: secureKey,
        additionalData: aad,
      );
    } on SodiumException {
      throw const DecryptionFailure('Wrong key, or the data was modified');
    } finally {
      secureKey.dispose();
    }
  }

  Uint8List _aad(WrapPurpose purpose) => _ascii('$_wrapAadPrefix${purpose.label}');

  Uint8List _ascii(String value) => Uint8List.fromList(ascii.encode(value));

  Uint8List _header(Uint8List noncePrefix) {
    final header = Uint8List(PmefLayout.headerLength);
    header.setAll(0, PmefLayout.magic);
    header[4] = PmefLayout.version;
    header[5] = layout.chunkLog2;
    header.setAll(8, noncePrefix);
    return header;
  }

  Uint8List _readHeader(Uint8List bytes) {
    if (bytes.length < PmefLayout.headerLength) {
      throw const DecryptionFailure('The encrypted object is too short');
    }
    final header = Uint8List.fromList(Uint8List.sublistView(bytes, 0, PmefLayout.headerLength));
    for (var i = 0; i < PmefLayout.magic.length; i++) {
      if (header[i] != PmefLayout.magic[i]) {
        throw const DecryptionFailure('Not a PMEF object');
      }
    }
    if (header[4] != PmefLayout.version || header[5] != layout.chunkLog2) {
      throw const DecryptionFailure('Unsupported PMEF version or chunk size');
    }
    return header;
  }

  int _plainLength(int encryptedLength) {
    try {
      return layout.plainLength(encryptedLength);
    } on ArgumentError {
      throw const DecryptionFailure('The encrypted object is too short');
    }
  }

  Uint8List _nonce(Uint8List header, int index) {
    final nonce = Uint8List(_nonceLength);
    nonce.setAll(0, Uint8List.sublistView(header, 8, 8 + PmefLayout.noncePrefixLength));
    ByteData.sublistView(nonce).setUint64(16, index, Endian.big);
    return nonce;
  }

  Uint8List _chunkAad(Uint8List header, bool isFinal) => Uint8List.fromList([...header, isFinal ? 1 : 0]);

  Uint8List _encryptChunk(SecureKey key, Uint8List header, int index, Uint8List plain, bool isFinal) {
    return sodium.crypto.aeadXChaCha20Poly1305IETF.encrypt(
      message: plain,
      nonce: _nonce(header, index),
      key: key,
      additionalData: _chunkAad(header, isFinal),
    );
  }

  Uint8List _decryptChunk(SecureKey key, Uint8List header, int index, Uint8List encrypted, bool isFinal) {
    try {
      return sodium.crypto.aeadXChaCha20Poly1305IETF.decrypt(
        cipherText: encrypted,
        nonce: _nonce(header, index),
        key: key,
        additionalData: _chunkAad(header, isFinal),
      );
    } on SodiumException {
      throw DecryptionFailure('Chunk $index could not be decrypted: wrong key, or the data was modified or truncated');
    }
  }
}
