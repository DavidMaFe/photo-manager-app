import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/app_temporary_files.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/media_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/photo_manager_thumbnail_source.dart';

void main() {
  late Directory tempDir;

  setUp(() async => tempDir = await Directory.systemTemp.createTemp('upload_sources'));

  tearDown(() => tempDir.delete(recursive: true));

  group('PhotoManagerThumbnailSource.sizeFor', () {
    test('should fit the long side in 512 px keeping the proportion', () {
      expect(PhotoManagerThumbnailSource.sizeFor(4032, 3024), (512, 384));
      expect(PhotoManagerThumbnailSource.sizeFor(1080, 1920), (288, 512));
      expect(PhotoManagerThumbnailSource.sizeFor(3000, 3000), (512, 512));
    });

    test('should never make a thumbnail bigger than the original', () {
      expect(PhotoManagerThumbnailSource.sizeFor(400, 300), (400, 300));
    });

    test('should ask for a square without dimensions', () {
      expect(PhotoManagerThumbnailSource.sizeFor(0, 0), (512, 512));
    });

    test('should not give a side of 0 for very long panoramas', () {
      expect(PhotoManagerThumbnailSource.sizeFor(40000, 10), (512, 1));
    });
  });

  group('AppTemporaryFiles', () {
    test('should create new empty files in the uploads directory', () async {
      final files = AppTemporaryFiles(baseDirectory: () async => tempDir);

      final first = await files.create('.pmef');
      final second = await files.create('.pmef');

      expect(first.parent.path, '${tempDir.path}/uploads');
      expect(first.path, endsWith('.pmef'));
      expect(first.path, isNot(second.path));
      expect(await first.length(), 0);
    });
  });

  group('MediaLocalDataSource.contentHash', () {
    test('should give the SHA-256 of the content read in chunks', () async {
      final content = List.generate(5 * 1024 * 1024 + 3, (i) => i & 0xff);
      final file = File('${tempDir.path}/video.mp4')..writeAsBytesSync(content);

      expect(await MediaLocalDataSource.contentHash(file), sha256.convert(content).toString());
    });

    test('should throw for a file that cannot be read', () async {
      await expectLater(MediaLocalDataSource.contentHash(File('${tempDir.path}/missing.jpg')), throwsException);
    });
  });
}
