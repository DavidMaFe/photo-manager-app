import 'package:photo_manager_app/features/sync_session/domain/entities/gallery_scan.dart';

/// The photos and videos of the gallery of the device.
abstract class GalleryMediaSource {
  /// The files that arrived on the device since [since] (its date of addition, not its capture date: a photo of 2019
  /// copied today is new), or every file without [since]. [checkPermission] is false in the background, where the
  /// permission cannot be asked for.
  Future<GalleryScan> addedSince(DateTime? since, {bool checkPermission = true});

  /// The files with these ids.
  Future<GalleryScan> withIds(Set<String> localIds);

  /// The album of the gallery of each of these files, by id; a file outside every album is left out.
  Future<Map<String, String>> albumsOf(Set<String> localIds);
}
