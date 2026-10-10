import 'dart:typed_data';

import 'package:photo_manager_app/core/crypto/data/master_key_local_data_source.dart';
import 'package:photo_manager_app/core/crypto/data/sodium_crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/core/crypto/domain/keyring_service.dart';
import 'package:photo_manager_app/core/crypto/domain/password_keys.dart';
import 'package:photo_manager_app/core/crypto/domain/wrap_purpose.dart';

import 'in_memory_secure_store.dart';
import 'sodium_test_helper.dart';

/// Real cryptography for the key tests: libsodium engine, keyring and an in-memory key store. Only the server is
/// simulated, with [serverVersion] building what the backend would keep from the material the device sends.
class E2eeTestKit {
  final SodiumCryptoEngine engine;
  final MasterKeyLocalDataSourceImpl store;
  final KeyringService keyring;

  E2eeTestKit._(this.engine, this.store) : keyring = KeyringService(engine: engine, store: store);

  static SodiumCryptoEngine? _engine;

  /// A kit with an empty key store (libsodium is loaded once per test file).
  static Future<E2eeTestKit> create() async {
    final engine = _engine ??= SodiumCryptoEngine(await loadTestSodium());
    return E2eeTestKit._(engine, MasterKeyLocalDataSourceImpl(secureStore: InMemorySecureStore()));
  }

  /// The cheapest Argon2id parameters libsodium accepts, for passwords the test derives itself.
  static KdfParams cheapParams({int seed = 1}) =>
      KdfParams(salt: Uint8List.fromList(List.generate(KdfParams.saltLength, (i) => seed + i)), ops: 1, memBytes: 8192);

  Future<PasswordKeys> passwordKeys(String password, KdfParams params) => engine.deriveFromPassword(password, params);

  /// New key material wrapped with the KEK of [password].
  Future<NewKeyMaterial> material(String password, KdfParams params) async {
    final keys = await passwordKeys(password, params);
    return keyring.createKeyMaterial(keys.kek);
  }

  static KeyVersion serverVersion(NewKeyMaterial material, {int version = 1, KeyState state = KeyState.current}) =>
      KeyVersion(
        version: version,
        state: state,
        encryptedMasterKey: material.encryptedMasterKey,
        masterKeyByRecovery: material.masterKeyByRecovery,
        publicKey: material.publicKey,
        encryptedPrivateKey: material.encryptedPrivateKey,
      );

  /// Opens a password wrap of the master key, as another device would.
  Uint8List unwrapWithPassword(CryptoKey kek, Uint8List encryptedMasterKey) =>
      engine.unwrapKey(kek, encryptedMasterKey, WrapPurpose.masterKeyByPassword);
}
