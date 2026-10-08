import 'dart:typed_data';

import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/current_master_key.dart';
import 'package:photo_manager_app/core/crypto/domain/master_key_store.dart';

/// Turns the SHA-256 of the content of a file into the keyed hash the server compares to find duplicates
/// (docs/e2ee-spec.md, section 7.2). Without the DedupKey the server cannot tell whether a user has a known photo.
class DedupHasher {
  final CryptoEngine _cryptoEngine;
  final MasterKeyStore _store;

  DedupHasher(this._cryptoEngine, this._store);

  /// Content hash (64 hex characters) → keyed hash, with the current master key.
  /// Throws MissingCurrentKeyFailure if this device has no current key.
  Future<Map<String, String>> hashes(Iterable<String> contentHashes) async {
    final masterKey = await CurrentMasterKey.of(_store);
    final dedupKey = _cryptoEngine.dedupKey(masterKey.key);
    try {
      return {for (final hash in contentHashes) hash: _cryptoEngine.dedupHash(dedupKey, hexToBytes(hash))};
    } finally {
      dedupKey.dispose();
    }
  }

  static Uint8List hexToBytes(String hex) {
    if (hex.length.isOdd) {
      throw FormatException('Invalid hex value', hex);
    }
    return Uint8List.fromList(
        List.generate(hex.length ~/ 2, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));
  }
}
