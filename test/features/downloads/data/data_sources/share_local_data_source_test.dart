import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/downloads/data/data_sources/share_local_data_source.dart';

void main() {
  late Directory cache;
  late List<List<String>> shared;
  late ShareLocalDataSourceImpl dataSource;

  setUp(() async {
    cache = await Directory.systemTemp.createTemp('share_test');
    shared = [];
    dataSource = ShareLocalDataSourceImpl(
      cacheDirectory: () async => cache,
      galleryFile: (localId) async => localId == '100' ? File('/storage/DCIM/IMG_1.jpg') : null,
      openShareSheet: (paths) async => shared.add(paths),
    );
  });

  tearDown(() async {
    if (await cache.exists()) await cache.delete(recursive: true);
  });

  group('ShareLocalDataSource', () {
    test('should write each temporary file with its name in its own folder of share_tmp', () async {
      final first = await dataSource.writeTemporary('IMG_1.jpg',
          Stream.fromIterable([Uint8List.fromList([1, 2]), Uint8List.fromList([3])]));
      final second = await dataSource.writeTemporary('IMG_1.jpg', Stream.value(Uint8List.fromList([4])));

      expect(first, isNot(second));
      expect(first, startsWith('${cache.path}/share_tmp/'));
      expect(first, endsWith('/IMG_1.jpg'));
      expect(await File(first).readAsBytes(), [1, 2, 3]);
      expect(await File(second).readAsBytes(), [4]);
    });

    test('should not let a name leave its folder', () async {
      final path = await dataSource.writeTemporary('../../evil.jpg', Stream.value(Uint8List.fromList([1])));

      expect(path, startsWith('${cache.path}/share_tmp/'));
      expect(path.split('/').last, '.._.._evil.jpg');
    });

    test('should remove every temporary file', () async {
      await dataSource.writeTemporary('IMG_1.jpg', Stream.value(Uint8List.fromList([1])));

      await dataSource.clearTemporary();

      expect(await Directory('${cache.path}/share_tmp').exists(), isFalse);
      await dataSource.clearTemporary();
    });

    test('should give the path of a gallery file or fail when it is gone', () async {
      expect(await dataSource.galleryFilePath('100'), '/storage/DCIM/IMG_1.jpg');
      await expectLater(dataSource.galleryFilePath('200'), throwsA(isA<FileSystemException>()));
    });

    test('should open the share sheet with the paths', () async {
      await dataSource.share(['/a.jpg', '/b.mp4']);

      expect(shared, [
        ['/a.jpg', '/b.mp4'],
      ]);
    });
  });
}
