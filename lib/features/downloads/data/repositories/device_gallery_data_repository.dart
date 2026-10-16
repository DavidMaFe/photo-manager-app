import 'dart:typed_data';

import 'package:photo_manager_app/features/downloads/data/data_sources/device_media_data_source.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/device_storage.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/device_gallery_repository.dart';

class DeviceGalleryDataRepository implements DeviceGalleryRepository {
  final DeviceMediaDataSource dataSource;
  bool? _supported;

  DeviceGalleryDataRepository({required this.dataSource});

  @override
  Future<bool> isSupported() async => _supported ??= await dataSource.isSupported();

  @override
  Future<Set<String>> galleryIds() async => {for (final id in await dataSource.galleryIds()) '$id'};

  @override
  Future<DeviceStorage> storage() async {
    final storage = await dataSource.storage();
    return DeviceStorage(freeBytes: storage.free, totalBytes: storage.total);
  }

  @override
  Future<String> save({
    required String relativePath,
    required String fileName,
    required String mimeType,
    DateTime? takenAt,
    required Stream<Uint8List> bytes,
  }) async {
    final token = await dataSource.beginSave(
      relativePath: relativePath,
      displayName: fileName,
      mimeType: mimeType,
      dateTakenMs: takenAt?.millisecondsSinceEpoch,
    );
    try {
      await for (final chunk in bytes) {
        await dataSource.write(token, chunk);
      }
      return await dataSource.commit(token);
    } catch (_) {
      try {
        await dataSource.abort(token);
      } catch (_) {
        // The pending row is removed by Android after a while anyway
      }
      rethrow;
    }
  }
}
