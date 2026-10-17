import 'dart:typed_data';

import 'package:photo_manager_app/features/downloads/domain/entities/device_storage.dart';

/// The gallery of this device.
abstract class DeviceGalleryRepository {
  /// Whether this device can save into its gallery (Android 10 and later).
  Future<bool> isSupported();

  /// Ids of every photo and video of the gallery.
  Future<Set<String>> galleryIds();

  Future<DeviceStorage> storage();

  /// Saves [bytes] as a new file of the gallery in [relativePath] (e.g. `Pictures/PhotoManager/Trip`), dated
  /// [takenAt]; returns its id. Nothing is left in the gallery if it fails half-way.
  Future<String> save({
    required String relativePath,
    required String fileName,
    required String mimeType,
    DateTime? takenAt,
    required Stream<Uint8List> bytes,
  });
}
