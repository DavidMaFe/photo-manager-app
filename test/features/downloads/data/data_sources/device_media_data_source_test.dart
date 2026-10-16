import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/downloads/data/data_sources/device_media_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.photomanagerpro/device_media');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<MethodCall> calls;
  const dataSource = DeviceMediaDataSourceImpl();

  setUp(() {
    calls = [];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'isSupported' => true,
        'galleryIds' => Int64List.fromList([1, 2]),
        'storage' => {'free': 10, 'total': 20},
        'beginSave' => 'token',
        'commit' => '99',
        _ => null,
      };
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('DeviceMediaDataSource', () {
    test('should read the gallery and the storage', () async {
      expect(await dataSource.isSupported(), isTrue);
      expect(await dataSource.galleryIds(), [1, 2]);
      expect(await dataSource.storage(), (free: 10, total: 20));
    });

    test('should send what a save needs', () async {
      final token = await dataSource.beginSave(
          relativePath: 'Pictures/PhotoManager', displayName: 'IMG.jpg', mimeType: 'image/jpeg', dateTakenMs: 5);
      await dataSource.write(token, Uint8List.fromList([1]));
      final id = await dataSource.commit(token);
      await dataSource.abort(token);

      expect(id, '99');
      expect(calls.map((c) => c.method), ['beginSave', 'write', 'commit', 'abort']);
      expect(calls[0].arguments, {
        'relativePath': 'Pictures/PhotoManager',
        'displayName': 'IMG.jpg',
        'mimeType': 'image/jpeg',
        'dateTakenMs': 5,
      });
      expect(calls[1].arguments, {'token': 'token', 'bytes': Uint8List.fromList([1])});
    });

    test('should not be supported without the plugin', () async {
      messenger.setMockMethodCallHandler(channel, null);

      expect(await dataSource.isSupported(), isFalse);
    });
  });
}
