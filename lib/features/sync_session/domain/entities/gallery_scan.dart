import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';

/// Files read from the gallery.
class GalleryScan {
  final List<SyncFile> files;

  /// Files of the gallery that could not be read (no file, not an image nor a video, an error): they are tried again
  /// by the next backup.
  final Set<String> unreadableIds;

  /// Ids asked for that are no longer in the gallery.
  final Set<String> missingIds;

  const GalleryScan({required this.files, this.unreadableIds = const {}, this.missingIds = const {}});

  static const empty = GalleryScan(files: []);
}
