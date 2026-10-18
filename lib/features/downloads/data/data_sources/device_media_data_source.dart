import 'dart:typed_data';

import 'package:device_media/device_media.dart';

/// The local plugin `device_media` (Android 10 and later).
abstract class DeviceMediaDataSource {
  Future<bool> isSupported();
  Future<Int64List> galleryIds();
  Future<({int free, int total})> storage();
  Future<String> beginSave({required String relativePath, required String displayName, required String mimeType,
      int? dateTakenMs});
  Future<void> write(String token, Uint8List bytes);
  Future<String> commit(String token);
  Future<void> abort(String token);
}

class DeviceMediaDataSourceImpl implements DeviceMediaDataSource {
  final DeviceMediaChannel channel;

  const DeviceMediaDataSourceImpl({this.channel = const DeviceMediaChannel()});

  @override
  Future<bool> isSupported() => channel.isSupported();

  @override
  Future<Int64List> galleryIds() => channel.galleryIds();

  @override
  Future<({int free, int total})> storage() => channel.storage();

  @override
  Future<String> beginSave({required String relativePath, required String displayName, required String mimeType,
          int? dateTakenMs}) =>
      channel.beginSave(
          relativePath: relativePath, displayName: displayName, mimeType: mimeType, dateTakenMs: dateTakenMs);

  @override
  Future<void> write(String token, Uint8List bytes) => channel.write(token, bytes);

  @override
  Future<String> commit(String token) => channel.commit(token);

  @override
  Future<void> abort(String token) => channel.abort(token);
}
