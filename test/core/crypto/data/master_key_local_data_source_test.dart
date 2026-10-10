import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/crypto/data/master_key_local_data_source.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';

import '../../../helpers/in_memory_secure_store.dart';

CryptoKey key(int byte) => CryptoKey(Uint8List.fromList(List.filled(32, byte)));

void main() {
  late InMemorySecureStore secureStore;
  late MasterKeyLocalDataSourceImpl dataSource;

  setUp(() {
    secureStore = InMemorySecureStore();
    dataSource = MasterKeyLocalDataSourceImpl(secureStore: secureStore);
  });

  group('MasterKeyLocalDataSource', () {
    group('saveMasterKey / getMasterKey', () {
      test('should store each version in the secure storage and read it back', () async {
        await dataSource.saveMasterKey(1, key(1));
        await dataSource.saveMasterKey(2, key(2));

        expect((await dataSource.getMasterKey(1))!.bytes, key(1).bytes);
        expect((await dataSource.getMasterKey(2))!.bytes, key(2).bytes);
      });

      test('should return null for a version that is not stored', () async {
        expect(await dataSource.getMasterKey(3), isNull);
      });

      test('should not keep the key in plain bytes in the stored value', () async {
        await dataSource.saveMasterKey(1, key(7));

        expect(secureStore.values.values.single, isNot(String.fromCharCodes(key(7).bytes)));
      });
    });

    group('getVersions', () {
      test('should list the stored versions in order', () async {
        await dataSource.saveMasterKey(3, key(3));
        await dataSource.saveMasterKey(1, key(1));
        await secureStore.write('AUTH_TOKEN', 'not a key');

        expect(await dataSource.getVersions(), [1, 3]);
      });
    });

    group('current version', () {
      test('should save and read the current version', () async {
        await dataSource.saveCurrentVersion(2);

        expect(await dataSource.getCurrentVersion(), 2);
      });

      test('should return null when there is none', () async {
        expect(await dataSource.getCurrentVersion(), isNull);
      });
    });

    group('clear', () {
      test('should remove every master key and the current version, and nothing else', () async {
        await dataSource.saveMasterKey(1, key(1));
        await dataSource.saveMasterKey(2, key(2));
        await dataSource.saveCurrentVersion(2);
        await secureStore.write('AUTH_TOKEN', 'token');

        await dataSource.clear();

        expect(await dataSource.getVersions(), isEmpty);
        expect(await dataSource.getCurrentVersion(), isNull);
        expect(secureStore.values, {'AUTH_TOKEN': 'token'});
      });
    });
  });
}
