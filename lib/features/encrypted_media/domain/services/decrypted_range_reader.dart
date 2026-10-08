import 'dart:typed_data';

import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/pmef_layout.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/repositories/encrypted_media_repository.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/file_key_unwrapper.dart';

/// Reads any byte range of the plaintext of an original without downloading it whole: it asks the backend only for
/// the encrypted chunks the range needs and decrypts them (docs/e2ee-spec.md, section 6). Used by the video proxy.
class DecryptedRangeReader {
  final EncryptedMediaRepository _repository;
  final FileKeyUnwrapper _keyUnwrapper;
  final CryptoEngine _cryptoEngine;
  final Map<String, ({Uint8List header, int plainLength})> _objects = {};

  DecryptedRangeReader(this._repository, this._keyUnwrapper, this._cryptoEngine);

  PmefLayout get _layout => _cryptoEngine.layout;

  /// Size of the plaintext of the original.
  Future<int> plainLength(String fileId) async => (await _describe(fileId)).plainLength;

  /// Plaintext bytes [start]..[end], both inclusive and inside the plaintext.
  Future<Uint8List> read(String fileId, int start, int end) async {
    final object = await _describe(fileId);
    if (start < 0 || end < start || end >= object.plainLength) {
      throw RangeError('Range $start-$end outside 0-${object.plainLength - 1}');
    }
    final key = await _keyUnwrapper.keyFor(fileId);
    final chunks = _layout.chunksForRange(start, end);
    final lastChunk = _layout.chunkCount(object.plainLength) - 1;
    final from = _layout.chunkOffset(chunks.first);
    final to = _layout.chunkOffset(chunks.last) + _layout.encryptedChunkLengthAt(chunks.last, object.plainLength) - 1;
    final encrypted = (await _repository.originalRange(fileId, from, to)).bytes;

    final plain = BytesBuilder(copy: false);
    var offset = 0;
    for (var index = chunks.first; index <= chunks.last; index++) {
      final length = _layout.encryptedChunkLengthAt(index, object.plainLength);
      plain.add(_cryptoEngine.decryptChunk(key, object.header, index,
          Uint8List.sublistView(encrypted, offset, offset + length), isFinal: index == lastChunk));
      offset += length;
    }
    final firstByte = start - chunks.first * _layout.chunkLength;
    return Uint8List.sublistView(plain.takeBytes(), firstByte, firstByte + end - start + 1);
  }

  Future<({Uint8List header, int plainLength})> _describe(String fileId) async {
    final known = _objects[fileId];
    if (known != null) {
      return known;
    }
    final header = await _repository.originalRange(fileId, 0, PmefLayout.headerLength - 1);
    return _objects[fileId] = (header: header.bytes, plainLength: _layout.plainLength(header.totalLength));
  }

  void clear() => _objects.clear();
}
