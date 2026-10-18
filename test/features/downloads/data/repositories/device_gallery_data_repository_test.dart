import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/data/data_sources/device_media_data_source.dart';
import 'package:photo_manager_app/features/downloads/data/repositories/device_gallery_data_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/device_storage.dart';

class MockDeviceMediaDataSource extends Mock implements DeviceMediaDataSource {}

void main() {
  late MockDeviceMediaDataSource dataSource;
  late DeviceGalleryDataRepository repository;

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    dataSource = MockDeviceMediaDataSource();
    repository = DeviceGalleryDataRepository(dataSource: dataSource);
    when(() => dataSource.beginSave(
          relativePath: any(named: 'relativePath'),
          displayName: any(named: 'displayName'),
          mimeType: any(named: 'mimeType'),
          dateTakenMs: any(named: 'dateTakenMs'),
        )).thenAnswer((_) async => 'token');
    when(() => dataSource.write(any(), any())).thenAnswer((_) async {});
    when(() => dataSource.commit(any())).thenAnswer((_) async => '777');
    when(() => dataSource.abort(any())).thenAnswer((_) async {});
  });

  group('DeviceGalleryDataRepository', () {
    test('should ask the plugin only once whether it is supported', () async {
      when(() => dataSource.isSupported()).thenAnswer((_) async => true);

      expect(await repository.isSupported(), isTrue);
      expect(await repository.isSupported(), isTrue);
      verify(() => dataSource.isSupported()).called(1);
    });

    test('should give the gallery ids as strings', () async {
      when(() => dataSource.galleryIds()).thenAnswer((_) async => Int64List.fromList([5, 6]));

      expect(await repository.galleryIds(), {'5', '6'});
    });

    test('should give the storage', () async {
      when(() => dataSource.storage()).thenAnswer((_) async => (free: 10, total: 20));

      expect(await repository.storage(), const DeviceStorage(freeBytes: 10, totalBytes: 20));
    });

    test('should write every chunk in order and publish the file dated when it was taken', () async {
      final takenAt = DateTime(2024, 8, 3, 10, 42);

      final id = await repository.save(
        relativePath: 'Pictures/PhotoManager',
        fileName: 'IMG.jpg',
        mimeType: 'image/jpeg',
        takenAt: takenAt,
        bytes: Stream.fromIterable([Uint8List.fromList([1]), Uint8List.fromList([2])]),
      );

      expect(id, '777');
      verifyInOrder([
        () => dataSource.beginSave(relativePath: 'Pictures/PhotoManager', displayName: 'IMG.jpg',
            mimeType: 'image/jpeg', dateTakenMs: takenAt.millisecondsSinceEpoch),
        () => dataSource.write('token', Uint8List.fromList([1])),
        () => dataSource.write('token', Uint8List.fromList([2])),
        () => dataSource.commit('token'),
      ]);
    });

    test('should remove the pending file when the content fails half-way', () async {
      final call = repository.save(
        relativePath: 'Movies/PhotoManager',
        fileName: 'VID.mp4',
        mimeType: 'video/mp4',
        bytes: Stream.error(Exception('offline')),
      );

      await expectLater(call, throwsA(isA<Exception>()));
      verify(() => dataSource.abort('token')).called(1);
      verifyNever(() => dataSource.commit(any()));
    });
  });
}
