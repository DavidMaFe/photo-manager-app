import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/crypto/domain/pmef_layout.dart';

void main() {
  const layout = PmefLayout();
  const mib = 1 << 20;

  group('PmefLayout', () {
    group('chunkCount', () {
      test('should use one chunk for an empty file and for up to 1 MiB', () {
        expect(layout.chunkCount(0), 1);
        expect(layout.chunkCount(1), 1);
        expect(layout.chunkCount(mib), 1);
      });

      test('should add a chunk for each started MiB', () {
        expect(layout.chunkCount(mib + 1), 2);
        expect(layout.chunkCount(100 * mib), 100);
      });
    });

    group('encryptedLength / plainLength', () {
      test('should match the sizes of the test vectors', () {
        expect(layout.encryptedLength(0), 48);
        expect(layout.encryptedLength(1), 49);
        expect(layout.encryptedLength(mib), 1048624);
        expect(layout.encryptedLength(mib + 1), 1048641);
      });

      test('should give back the plain length from the encrypted length', () {
        for (final plain in [0, 1, 1000, mib - 1, mib, mib + 1, 7 * mib + 12345]) {
          expect(layout.plainLength(layout.encryptedLength(plain)), plain, reason: '$plain');
        }
      });

      test('should reject a length shorter than header and tag', () {
        expect(() => layout.plainLength(40), throwsArgumentError);
      });
    });

    group('chunk positions', () {
      test('should place each chunk after the header and the previous chunks', () {
        expect(layout.chunkOffset(0), 32);
        expect(layout.chunkOffset(2), 32 + 2 * (mib + 16));
      });

      test('should give the encrypted length of the last, partial chunk', () {
        expect(layout.encryptedChunkLengthAt(0, mib + 10), mib + 16);
        expect(layout.encryptedChunkLengthAt(1, mib + 10), 10 + 16);
      });

      test('should give the chunks of a plaintext range', () {
        expect(layout.chunksForRange(0, 99), (first: 0, last: 0));
        expect(layout.chunksForRange(mib - 1, mib), (first: 0, last: 1));
        expect(layout.chunksForRange(5 * mib + 3, 7 * mib), (first: 5, last: 7));
      });
    });
  });
}
