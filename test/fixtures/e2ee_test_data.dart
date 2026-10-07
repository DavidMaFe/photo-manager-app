import 'dart:convert';
import 'dart:typed_data';

import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';

/// Shared data of the end-to-end encryption tests. Bytes are deterministic so expectations can compare Base64.
class E2eeTestData {
  const E2eeTestData._();

  static Uint8List bytes(int length, int seed) => Uint8List.fromList(List.generate(length, (i) => (seed + i) & 0xff));

  static CryptoKey key(int seed) => CryptoKey(bytes(32, seed));

  /// Cheap Argon2id parameters (the minimum the server accepts) so the tests run fast.
  static KdfParams kdfParams({int seed = 1}) => KdfParams(salt: bytes(16, seed), ops: 2, memBytes: 32 * 1024 * 1024);

  static Map<String, dynamic> kdfParamsJson({int seed = 1}) => {
        'kdfSalt': base64Encode(bytes(16, seed)),
        'algorithm': 'argon2id13',
        'ops': 2,
        'memBytes': 32 * 1024 * 1024,
      };

  static NewKeyMaterial newKeyMaterial() => NewKeyMaterial(
        masterKey: key(10),
        recoveryKey: key(20),
        encryptedMasterKey: bytes(72, 30),
        masterKeyByRecovery: bytes(72, 40),
        recoveryAuthKey: bytes(32, 50),
        masterKeyAuth: bytes(32, 60),
        publicKey: bytes(32, 70),
        encryptedPrivateKey: bytes(72, 80),
      );

  static KeyVersion keyVersion({int version = 1, KeyState state = KeyState.current}) => KeyVersion(
        version: version,
        state: state,
        encryptedMasterKey: bytes(72, version),
        masterKeyByRecovery: bytes(72, version + 100),
        publicKey: bytes(32, version + 50),
        encryptedPrivateKey: bytes(72, version + 150),
      );

  static Map<String, dynamic> keyVersionJson({int version = 1, String state = 'CURRENT'}) => {
        'version': version,
        'state': state,
        'encryptedMasterKey': base64Encode(bytes(72, version)),
        'masterKeyByRecovery': base64Encode(bytes(72, version + 100)),
        'publicKey': base64Encode(bytes(32, version + 50)),
        'encryptedPrivateKey': base64Encode(bytes(72, version + 150)),
      };

  static Map<String, dynamic> accountKeysJson({bool accountLocked = false, List<Map<String, dynamic>>? keys}) => {
        'accountLocked': accountLocked,
        'keys': keys ?? [keyVersionJson()],
      };

  static Map<String, dynamic> authResponseJson({bool accountLocked = false}) => {
        'token': 'access_token',
        'refreshToken': 'refresh_token',
        'id': 1,
        'email': 'test@example.com',
        'name': 'John',
        'surname': 'Doe',
        'keys': accountKeysJson(accountLocked: accountLocked,
            keys: [keyVersionJson(state: accountLocked ? 'LOCKED' : 'CURRENT')]),
      };
}
