import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/dedup_hasher.dart';

import '../../../../helpers/e2ee_test_kit.dart';

void main() {
  late E2eeTestKit kit;
  final contentHash = 'ab' * 32;

  setUp(() async {
    kit = await E2eeTestKit.create();
  });

  group('DedupHasher', () {
    test('should give the keyed hash of the content with the DedupKey of the current master key', () async {
      final material = await kit.material('the password', E2eeTestKit.cheapParams());
      await kit.keyring.storeNewKey(1, material);

      final hashes = await DedupHasher(kit.engine, kit.store).hashes([contentHash]);

      final expected = kit.engine.dedupHash(kit.engine.dedupKey(material.masterKey), DedupHasher.hexToBytes(contentHash));
      expect(hashes, {contentHash: expected});
      expect(hashes[contentHash], hasLength(64));
      expect(hashes[contentHash], isNot(contentHash));
    });

    test('should give other values with another master key, so the server cannot link accounts', () async {
      final store1 = await E2eeTestKit.create();
      final store2 = await E2eeTestKit.create();
      await store1.keyring.storeNewKey(1, await store1.material('one', E2eeTestKit.cheapParams()));
      await store2.keyring.storeNewKey(1, await store2.material('two', E2eeTestKit.cheapParams()));

      final first = await DedupHasher(store1.engine, store1.store).hashes([contentHash]);
      final second = await DedupHasher(store2.engine, store2.store).hashes([contentHash]);

      expect(first[contentHash], isNot(second[contentHash]));
    });

    test('should throw MissingCurrentKeyFailure without a current key', () async {
      await expectLater(DedupHasher(kit.engine, kit.store).hashes([contentHash]),
          throwsA(isA<MissingCurrentKeyFailure>()));
    });

    test('should turn hexadecimal into bytes', () {
      expect(DedupHasher.hexToBytes('00ff10'), Uint8List.fromList([0, 255, 16]));
      expect(() => DedupHasher.hexToBytes('abc'), throwsFormatException);
    });
  });
}
