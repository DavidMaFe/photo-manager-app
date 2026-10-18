import 'dart:typed_data';

import 'package:photo_manager_app/features/downloads/data/data_sources/device_media_data_source.dart';
import 'package:photo_manager_app/features/downloads/data/data_sources/share_local_data_source.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/share_repository.dart';

class ShareDataRepository implements ShareRepository {
  final ShareLocalDataSource localDataSource;
  final DeviceMediaDataSource deviceMediaDataSource;

  ShareDataRepository({required this.localDataSource, required this.deviceMediaDataSource});

  @override
  Future<String> galleryFilePath(String localId) => localDataSource.galleryFilePath(localId);

  @override
  Future<String> writeTemporary(String fileName, Stream<Uint8List> bytes) =>
      localDataSource.writeTemporary(fileName, bytes);

  /// The private storage and the gallery share the same partition on the phones the app supports. Where the plugin
  /// is not available the space is not checked.
  @override
  Future<int> temporaryFreeBytes() async {
    try {
      if (await deviceMediaDataSource.isSupported()) {
        return (await deviceMediaDataSource.storage()).free;
      }
    } catch (_) {
      // Falls through: not checked
    }
    return 1 << 62;
  }

  @override
  Future<void> share(List<String> paths) => localDataSource.share(paths);

  @override
  Future<void> clearTemporary() => localDataSource.clearTemporary();
}
