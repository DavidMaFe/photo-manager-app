import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Channel of the native side (Android 10 and later). The calls run in order on one background thread of the plugin.
class DeviceMediaChannel {
  static const MethodChannel _channel = MethodChannel('com.photomanagerpro/device_media');

  const DeviceMediaChannel();

  /// Whether this device can save into its gallery with this plugin (false on other platforms).
  Future<bool> isSupported() async {
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  /// MediaStore ids of every photo and video of the gallery.
  Future<Int64List> galleryIds() async => (await _channel.invokeMethod<Int64List>('galleryIds'))!;

  /// Free and total bytes of the shared storage.
  Future<({int free, int total})> storage() async {
    final map = (await _channel.invokeMapMethod<String, int>('storage'))!;
    return (free: map['free']!, total: map['total']!);
  }

  /// Creates the pending row of a file in the gallery; returns the token of the save.
  Future<String> beginSave({
    required String relativePath,
    required String displayName,
    required String mimeType,
    int? dateTakenMs,
  }) async =>
      (await _channel.invokeMethod<String>('beginSave', {
        'relativePath': relativePath,
        'displayName': displayName,
        'mimeType': mimeType,
        'dateTakenMs': dateTakenMs,
      }))!;

  Future<void> write(String token, Uint8List bytes) =>
      _channel.invokeMethod<void>('write', {'token': token, 'bytes': bytes});

  /// Publishes the file in the gallery; returns its MediaStore id.
  Future<String> commit(String token) async =>
      (await _channel.invokeMethod<String>('commit', {'token': token}))!;

  /// Removes the pending row of a save that will not finish.
  Future<void> abort(String token) => _channel.invokeMethod<void>('abort', {'token': token});
}
