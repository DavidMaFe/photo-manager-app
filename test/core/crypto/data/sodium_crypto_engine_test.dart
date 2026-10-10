import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as dart_crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/crypto/data/sodium_crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/decryption_failure.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/pmef_layout.dart';
import 'package:photo_manager_app/core/crypto/domain/wrap_purpose.dart';

import '../../../fixtures/json_reader.dart';
import '../../../helpers/sodium_test_helper.dart';

Uint8List seq(int start, int length) => Uint8List.fromList(List.generate(length, (i) => (start + i) & 0xff));

Uint8List pattern(int length) => Uint8List.fromList(List.generate(length, (i) => i % 251));

Uint8List fromHex(String hex) =>
    Uint8List.fromList(List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));

String toHex(Uint8List bytes) => bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

String sha256Hex(List<int> bytes) => dart_crypto.sha256.convert(bytes).toString();

void main() {
  late SodiumCryptoEngine engine;
  late Map<String, dynamic> vectors;

  setUpAll(() async {
    engine = SodiumCryptoEngine(await loadTestSodium());
    vectors = jsonDecode(readJson('e2ee_test_vectors.json')) as Map<String, dynamic>;
  });

  group('SodiumCryptoEngine', () {
    group('test vectors (docs/e2ee-test-vectors.json)', () {
      test('should derive authKey and KEK from the password like the specification', () async {
        // Arrange
        final kdf = vectors['kdf'] as Map<String, dynamic>;
        final params = KdfParams(salt: fromHex(kdf['saltHex'] as String), ops: kdf['ops'] as int,
            memBytes: kdf['memBytes'] as int);

        // Act
        final keys = await engine.deriveFromPassword(kdf['password'] as String, params);

        // Assert
        expect(toHex(keys.authKey.bytes), kdf['authKeyHex']);
        expect(toHex(keys.kek.bytes), kdf['kekHex']);
      });

      test('should derive the recovery, dedup and master key proof subkeys like the specification', () {
        final subkeys = vectors['subkeys'] as Map<String, dynamic>;
        final masterKey = CryptoKey(fromHex(subkeys['masterKeyHex'] as String));
        final recoveryKey = CryptoKey(fromHex(subkeys['recoveryKeyHex'] as String));

        expect(toHex(engine.recoveryWrapKey(recoveryKey).bytes), subkeys['recoveryWrapKeyHex']);
        expect(toHex(engine.recoveryAuthKey(recoveryKey).bytes), subkeys['recoveryAuthKeyHex']);
        expect(toHex(engine.dedupKey(masterKey).bytes), subkeys['dedupKeyHex']);
        expect(toHex(engine.masterKeyAuth(masterKey).bytes), subkeys['masterKeyAuthHex']);
      });

      test('should wrap keys like the specification', () async {
        final kdf = vectors['kdf'] as Map<String, dynamic>;
        final subkeys = vectors['subkeys'] as Map<String, dynamic>;
        final wrap = vectors['wrap'] as Map<String, dynamic>;
        final kek = CryptoKey(fromHex(kdf['kekHex'] as String));
        final masterKey = fromHex(subkeys['masterKeyHex'] as String);
        final recoveryWrapKey = CryptoKey(fromHex(subkeys['recoveryWrapKeyHex'] as String));
        final identity = engine.identityKeyPairFromSeed(CryptoKey(seq(0xd0, 32)));

        expect(toHex(engine.wrapKeyWithNonce(kek, masterKey, WrapPurpose.masterKeyByPassword, seq(0xa0, 24))),
            wrap['mkByPasswordHex']);
        expect(toHex(engine.wrapKeyWithNonce(recoveryWrapKey, masterKey, WrapPurpose.masterKeyByRecovery, seq(0xa1, 24))),
            wrap['mkByRecoveryHex']);
        expect(toHex(engine.wrapKeyWithNonce(CryptoKey(masterKey), identity.secretKey.bytes,
            WrapPurpose.identitySecretKey, seq(0xa2, 24))), wrap['identitySkHex']);
        expect(toHex(engine.wrapKeyWithNonce(CryptoKey(masterKey), seq(0x60, 32), WrapPurpose.fileKey, seq(0xa3, 24))),
            wrap['fileKeyHex']);
        expect(toHex(identity.publicKey), (vectors['identity'] as Map)['publicKeyHex']);
      });

      test('should encrypt metadata like the specification', () {
        final metadata = vectors['metadata'] as Map<String, dynamic>;
        final fileKey = CryptoKey(seq(0x60, 32));

        final encrypted = engine.encryptMetadataWithNonce(
            fileKey, jsonDecode(metadata['json'] as String) as Map<String, Object?>, seq(0xc0, 24));

        expect(toHex(encrypted), metadata['encryptedHex']);
      });

      test('should compute the dedup hash like the specification', () {
        final dedup = vectors['dedup'] as Map<String, dynamic>;
        final masterKey = CryptoKey(fromHex((vectors['subkeys'] as Map)['masterKeyHex'] as String));

        final hash = engine.dedupHash(engine.dedupKey(masterKey), fromHex(dedup['contentSha256Hex'] as String));

        expect(hash, dedup['dedupHex']);
      });

      test('should produce the PMEF objects of the specification', () {
        final fileKey = CryptoKey(seq(0x60, 32));
        final plains = {
          'empty': Uint8List(0),
          'one-byte': Uint8List.fromList([0x61]),
          'exactly-one-chunk': pattern(1 << 20),
          'one-chunk-plus-one-byte': pattern((1 << 20) + 1),
        };

        for (final vector in (vectors['pmef'] as List).cast<Map<String, dynamic>>()) {
          final encrypted = engine.encryptBytesWithNoncePrefix(fileKey, plains[vector['name']]!, seq(0xb0, 16));
          expect(encrypted.length, vector['encryptedLength'], reason: vector['name'] as String);
          expect(sha256Hex(encrypted), vector['encryptedSha256'], reason: vector['name'] as String);
          expect(engine.decryptBytes(fileKey, encrypted), plains[vector['name']], reason: vector['name'] as String);
        }
      });
    });

    group('deriveFromPassword', () {
      test('should give the same keys for the composed and decomposed forms of an accent', () async {
        // Arrange: "café" typed with "é" as one character (NFC) or as "e" + accent (NFD)
        final params = KdfParams(salt: seq(0x10, 16), ops: 2, memBytes: 32 * 1024 * 1024);

        // Act
        final composed = await engine.deriveFromPassword('café secreto', params);
        final decomposed = await engine.deriveFromPassword('café secreto', params);

        // Assert
        expect(composed.authKey.bytes, decomposed.authKey.bytes);
        expect(composed.kek.bytes, decomposed.kek.bytes);
      });

      test('should give different authKey and KEK', () async {
        final keys = await engine.deriveFromPassword('password', KdfParams(salt: seq(0, 16), ops: 2, memBytes: 32 << 20));

        expect(keys.authKey.bytes, isNot(keys.kek.bytes));
      });

      test('should give different keys with another salt', () async {
        final first = await engine.deriveFromPassword('password', KdfParams(salt: seq(0, 16), ops: 2, memBytes: 32 << 20));
        final second = await engine.deriveFromPassword('password', KdfParams(salt: seq(1, 16), ops: 2, memBytes: 32 << 20));

        expect(first.authKey.bytes, isNot(second.authKey.bytes));
      });
    });

    group('masterKeyAuth', () {
      test('should be deterministic and different from the other subkeys', () {
        final masterKey = CryptoKey(seq(0x20, 32));

        final proof = engine.masterKeyAuth(masterKey);

        expect(proof.bytes, engine.masterKeyAuth(CryptoKey(seq(0x20, 32))).bytes);
        expect(proof.bytes, isNot(engine.dedupKey(masterKey).bytes));
        expect(proof.bytes, isNot(masterKey.bytes));
      });
    });

    group('wrapKey / unwrapKey', () {
      test('should unwrap what was wrapped', () {
        final kek = engine.generateKey();
        final masterKey = engine.generateKey();

        final wrapped = engine.wrapKey(kek, masterKey.bytes, WrapPurpose.masterKeyByPassword);

        expect(wrapped.length, 72);
        expect(engine.unwrapKey(kek, wrapped, WrapPurpose.masterKeyByPassword), masterKey.bytes);
      });

      test('should use a new nonce each time', () {
        final kek = engine.generateKey();
        final secret = engine.generateKey().bytes;

        expect(engine.wrapKey(kek, secret, WrapPurpose.fileKey), isNot(engine.wrapKey(kek, secret, WrapPurpose.fileKey)));
      });

      test('should throw DecryptionFailure with the wrong key (wrong password)', () {
        final wrapped = engine.wrapKey(engine.generateKey(), engine.generateKey().bytes, WrapPurpose.masterKeyByPassword);

        expect(() => engine.unwrapKey(engine.generateKey(), wrapped, WrapPurpose.masterKeyByPassword),
            throwsA(isA<DecryptionFailure>()));
      });

      test('should throw DecryptionFailure when unwrapped for another purpose', () {
        final key = engine.generateKey();
        final wrapped = engine.wrapKey(key, engine.generateKey().bytes, WrapPurpose.fileKey);

        expect(() => engine.unwrapKey(key, wrapped, WrapPurpose.masterKeyByPassword), throwsA(isA<DecryptionFailure>()));
      });

      test('should throw DecryptionFailure when the wrapped key was modified or is too short', () {
        final key = engine.generateKey();
        final wrapped = engine.wrapKey(key, engine.generateKey().bytes, WrapPurpose.fileKey);
        wrapped[30] ^= 0x01;

        expect(() => engine.unwrapKey(key, wrapped, WrapPurpose.fileKey), throwsA(isA<DecryptionFailure>()));
        expect(() => engine.unwrapKey(key, Uint8List(10), WrapPurpose.fileKey), throwsA(isA<DecryptionFailure>()));
      });
    });

    group('metadata', () {
      test('should decrypt what was encrypted, with non-ASCII names', () {
        final fileKey = engine.generateKey();
        final metadata = {'v': 1, 'name': 'Playa de Málaga 🌊.HEIC', 'mime': 'image/heic'};

        final encrypted = engine.encryptMetadata(fileKey, metadata);

        expect(engine.decryptMetadata(fileKey, encrypted), metadata);
      });

      test('should throw DecryptionFailure with another file key', () {
        final encrypted = engine.encryptMetadata(engine.generateKey(), {'v': 1});

        expect(() => engine.decryptMetadata(engine.generateKey(), encrypted), throwsA(isA<DecryptionFailure>()));
      });
    });

    group('identity key pair', () {
      test('should generate a 32-byte public key and a different key pair each time', () {
        final first = engine.generateIdentityKeyPair();
        final second = engine.generateIdentityKeyPair();

        expect(first.publicKey.length, 32);
        expect(first.publicKey, isNot(second.publicKey));
      });
    });

    group('PMEF', () {
      late SodiumCryptoEngine smallChunks;
      late Directory tempDir;

      setUpAll(() async {
        // 1 KiB chunks so the file tests have many chunks without big files
        smallChunks = SodiumCryptoEngine(engine.sodium, layout: const PmefLayout(chunkLog2: 10));
        tempDir = await Directory.systemTemp.createTemp('pmef_test');
      });

      tearDownAll(() => tempDir.delete(recursive: true));

      test('should encrypt and decrypt a file chunk by chunk', () async {
        // Arrange: 10 chunks and a partial one
        final key = smallChunks.generateKey();
        final plain = pattern(10 * 1024 + 300);
        final input = await File('${tempDir.path}/plain.bin').writeAsBytes(plain);
        final encrypted = File('${tempDir.path}/plain.pmef');
        final output = File('${tempDir.path}/decrypted.bin');

        // Act
        await smallChunks.encryptFile(key, input, encrypted);
        await smallChunks.decryptFile(key, encrypted, output);

        // Assert
        expect(await encrypted.length(), smallChunks.layout.encryptedLength(plain.length));
        expect(await output.readAsBytes(), plain);
      });

      test('should decrypt a middle chunk alone (random access)', () async {
        final key = smallChunks.generateKey();
        final plain = pattern(5 * 1024 + 7);
        final encrypted = smallChunks.encryptBytes(key, plain);
        final layout = smallChunks.layout;
        final header = Uint8List.sublistView(encrypted, 0, PmefLayout.headerLength);

        final chunk = smallChunks.decryptChunk(key, header, 3,
            Uint8List.sublistView(encrypted, layout.chunkOffset(3), layout.chunkOffset(4)), isFinal: false);
        final last = smallChunks.decryptChunk(key, header, 5,
            Uint8List.sublistView(encrypted, layout.chunkOffset(5)), isFinal: true);

        expect(chunk, Uint8List.sublistView(plain, 3 * 1024, 4 * 1024));
        expect(last, Uint8List.sublistView(plain, 5 * 1024));
      });

      test('should compute the SHA-256 of a file in chunks', () async {
        final file = await File('${tempDir.path}/hello.txt').writeAsString('hello');

        expect(toHex(await engine.contentSha256(file)),
            '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824');
      });

      group('tampering', () {
        late CryptoKey key;
        late Uint8List encrypted;

        setUp(() {
          key = smallChunks.generateKey();
          encrypted = smallChunks.encryptBytes(key, pattern(3 * 1024 + 10));
        });

        test('should fail when a byte of a chunk is changed', () {
          encrypted[PmefLayout.headerLength + 100] ^= 0x01;
          expect(() => smallChunks.decryptBytes(key, encrypted), throwsA(isA<DecryptionFailure>()));
        });

        test('should fail when the nonce prefix of the header is changed', () {
          encrypted[10] ^= 0x01;
          expect(() => smallChunks.decryptBytes(key, encrypted), throwsA(isA<DecryptionFailure>()));
        });

        test('should fail when the object is truncated at a chunk boundary', () {
          final truncated = Uint8List.sublistView(encrypted, 0, smallChunks.layout.chunkOffset(2));
          expect(() => smallChunks.decryptBytes(key, truncated), throwsA(isA<DecryptionFailure>()));
        });

        test('should fail when two chunks are swapped', () {
          final layout = smallChunks.layout;
          final first = Uint8List.fromList(Uint8List.sublistView(encrypted, layout.chunkOffset(0), layout.chunkOffset(1)));
          final second = Uint8List.fromList(Uint8List.sublistView(encrypted, layout.chunkOffset(1), layout.chunkOffset(2)));
          encrypted.setAll(layout.chunkOffset(0), second);
          encrypted.setAll(layout.chunkOffset(1), first);
          expect(() => smallChunks.decryptBytes(key, encrypted), throwsA(isA<DecryptionFailure>()));
        });

        test('should fail with another key', () {
          expect(() => smallChunks.decryptBytes(smallChunks.generateKey(), encrypted), throwsA(isA<DecryptionFailure>()));
        });

        test('should reject an object that is not PMEF or has another chunk size', () {
          final notPmef = Uint8List.fromList(encrypted)..[0] = 0x00;
          expect(() => smallChunks.decryptBytes(key, notPmef), throwsA(isA<DecryptionFailure>()));
          expect(() => engine.decryptBytes(key, encrypted), throwsA(isA<DecryptionFailure>()));
        });

        test('should reject an object shorter than the header', () {
          expect(() => smallChunks.decryptBytes(key, Uint8List(20)), throwsA(isA<DecryptionFailure>()));
        });
      });
    });
  });
}
