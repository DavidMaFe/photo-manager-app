import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/data/data_sources/device_media_data_source.dart';
import 'package:photo_manager_app/features/downloads/data/data_sources/share_local_data_source.dart';
import 'package:photo_manager_app/features/downloads/data/repositories/share_data_repository.dart';

class MockShareLocalDataSource extends Mock implements ShareLocalDataSource {}

class MockDeviceMediaDataSource extends Mock implements DeviceMediaDataSource {}

void main() {
  late MockShareLocalDataSource local;
  late MockDeviceMediaDataSource deviceMedia;
  late ShareDataRepository repository;

  setUp(() {
    local = MockShareLocalDataSource();
    deviceMedia = MockDeviceMediaDataSource();
    repository = ShareDataRepository(localDataSource: local, deviceMediaDataSource: deviceMedia);
  });

  group('ShareDataRepository', () {
    test('should give the free space of the device', () async {
      when(() => deviceMedia.isSupported()).thenAnswer((_) async => true);
      when(() => deviceMedia.storage()).thenAnswer((_) async => (free: 123, total: 456));

      expect(await repository.temporaryFreeBytes(), 123);
    });

    test('should not limit the space where the plugin is not available or fails', () async {
      when(() => deviceMedia.isSupported()).thenAnswer((_) async => false);
      expect(await repository.temporaryFreeBytes(), greaterThan(1 << 40));

      when(() => deviceMedia.isSupported()).thenAnswer((_) async => true);
      when(() => deviceMedia.storage()).thenThrow(Exception('failed'));
      expect(await repository.temporaryFreeBytes(), greaterThan(1 << 40));
    });

    test('should pass the files to the local data source', () async {
      final bytes = Stream.value(Uint8List(1));
      when(() => local.galleryFilePath('1')).thenAnswer((_) async => '/g');
      when(() => local.writeTemporary('a.jpg', bytes)).thenAnswer((_) async => '/t');
      when(() => local.share(['/g', '/t'])).thenAnswer((_) async {});
      when(() => local.clearTemporary()).thenAnswer((_) async {});

      expect(await repository.galleryFilePath('1'), '/g');
      expect(await repository.writeTemporary('a.jpg', bytes), '/t');
      await repository.share(['/g', '/t']);
      await repository.clearTemporary();

      verify(() => local.share(['/g', '/t'])).called(1);
      verify(() => local.clearTemporary()).called(1);
    });
  });
}
