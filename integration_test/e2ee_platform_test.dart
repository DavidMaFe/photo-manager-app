// Checks on a real device or emulator what the unit tests cannot: libsodium loaded by the Flutter plugin and the
// platform secure storage (Android Keystore / iOS Keychain).
//
// Run: flutter test integration_test/e2ee_platform_test.dart -d <device-id>
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:photo_manager_app/core/crypto/data/master_key_local_data_source.dart';
import 'package:photo_manager_app/core/crypto/data/sodium_crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/wrap_purpose.dart';
import 'package:photo_manager_app/core/storage/flutter_secure_store.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';

Uint8List fromHex(String hex) =>
    Uint8List.fromList(List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));

String toHex(Uint8List bytes) => bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

// Same values as docs/e2ee-test-vectors.json (kdf section)
const vectorPassword = 'correct horse battery staple ñ';
const vectorSaltHex = '000102030405060708090a0b0c0d0e0f';
const vectorAuthKeyHex = '790576fd64a241e99c603556c2a86ab7e63e604ab4a85db762cd415904abcc99';
const vectorKekHex = 'b0a7eae7834bba2b9b32a3ae14d70c4e7fe4935487eba6f18ea4ddc9cda7aeb5';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2EE on the platform', () {
    late SodiumCryptoEngine engine;

    setUpAll(() async {
      engine = SodiumCryptoEngine(await SodiumSumoInit.init());
    });

    test('should derive the vector keys with the libsodium of the plugin', () async {
      final keys = await engine.deriveFromPassword(
          vectorPassword, KdfParams(salt: fromHex(vectorSaltHex), ops: 2, memBytes: 64 * 1024 * 1024));

      expect(toHex(keys.authKey.bytes), vectorAuthKeyHex);
      expect(toHex(keys.kek.bytes), vectorKekHex);
    });

    test('should derive with the default parameters in a reasonable time', () async {
      final stopwatch = Stopwatch()..start();
      await engine.deriveFromPassword('benchmark password', KdfParams(salt: engine.randomBytes(16)));
      stopwatch.stop();

      // ignore: avoid_print
      print('E2EE-PLATFORM argon2id default params: ${stopwatch.elapsedMilliseconds} ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('should keep master keys in the secure storage of the platform', () async {
      final dataSource = MasterKeyLocalDataSourceImpl(secureStore: const FlutterSecureStore());
      final masterKey = engine.generateKey();
      await dataSource.clear();

      await dataSource.saveMasterKey(1, masterKey);
      await dataSource.saveCurrentVersion(1);

      expect((await dataSource.getMasterKey(1))!.bytes, masterKey.bytes);
      expect(await dataSource.getVersions(), [1]);
      expect(await dataSource.getCurrentVersion(), 1);

      await dataSource.clear();
      expect(await dataSource.getMasterKey(1), isNull);
    });

    test('should wrap and unwrap a master key read back from the secure storage', () async {
      const store = FlutterSecureStore();
      final kek = engine.generateKey();
      final masterKey = engine.generateKey();
      await store.write('E2EE_PLATFORM_TEST', base64Encode(engine.wrapKey(kek, masterKey.bytes, WrapPurpose.masterKeyByPassword)));

      final wrapped = base64Decode((await store.read('E2EE_PLATFORM_TEST'))!);
      await store.delete('E2EE_PLATFORM_TEST');

      expect(CryptoKey(engine.unwrapKey(kek, wrapped, WrapPurpose.masterKeyByPassword)).bytes, masterKey.bytes);
    });
  });

}
