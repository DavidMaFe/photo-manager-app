/// Sizes and offsets of the PMEF v1 format (docs/e2ee-spec.md, section 6). Pure arithmetic, shared by the encryption
/// engine and the video proxy, which reads only the chunks a byte range needs.
class PmefLayout {
  static const int headerLength = 32;
  static const int tagLength = 16;
  static const int noncePrefixLength = 16;
  static const int version = 1;
  static const List<int> magic = [0x50, 0x4D, 0x45, 0x46]; // "PMEF"

  final int chunkLog2;

  const PmefLayout({this.chunkLog2 = 20});

  int get chunkLength => 1 << chunkLog2;

  int get encryptedChunkLength => chunkLength + tagLength;

  /// Chunks of a plaintext of [plainLength] bytes. An empty plaintext is one empty final chunk.
  int chunkCount(int plainLength) => plainLength == 0 ? 1 : (plainLength + chunkLength - 1) ~/ chunkLength;

  int encryptedLength(int plainLength) => headerLength + chunkCount(plainLength) * tagLength + plainLength;

  int plainLength(int encryptedLength) {
    final body = encryptedLength - headerLength;
    if (body < tagLength) {
      throw ArgumentError.value(encryptedLength, 'encryptedLength', 'Too short for a PMEF object');
    }
    final chunks = (body + encryptedChunkLength - 1) ~/ encryptedChunkLength;
    return body - chunks * tagLength;
  }

  /// Offset of chunk [index] inside the encrypted object.
  int chunkOffset(int index) => headerLength + index * encryptedChunkLength;

  /// Encrypted length of chunk [index] of an object whose plaintext has [plainLength] bytes.
  int encryptedChunkLengthAt(int index, int plainLength) {
    final last = chunkCount(plainLength) - 1;
    if (index < last) {
      return encryptedChunkLength;
    }
    return plainLength - last * chunkLength + tagLength;
  }

  /// First and last chunk needed to serve the plaintext bytes [start]..[end] (both inclusive).
  ({int first, int last}) chunksForRange(int start, int end) =>
      (first: start ~/ chunkLength, last: end ~/ chunkLength);
}
