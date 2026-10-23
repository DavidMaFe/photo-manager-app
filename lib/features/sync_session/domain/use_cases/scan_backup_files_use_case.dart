import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/backup_scan.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/backup_progress_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/gallery_media_source.dart';

/// The files a backup looks at (ROADMAP-local-albums.md):
/// - the ones that arrived on the device since the last completed backup started (by their date of addition: a photo
///   of 2019 copied today is new). Before the first one that this version remembers, since [lastCompletedAt] of the
///   server; without it, every file;
/// - the ones the previous backups skipped (did not fit, too big for the plan, failed), still in the gallery.
///
/// Each one with its album of the gallery. Files already on the server are left out later by the duplicate check.
class ScanBackupFilesUseCase {
  /// Files added while the previous backup was looking are not lost: the server leaves out the repeated ones.
  static const Duration margin = Duration(minutes: 10);

  final GalleryMediaSource _gallery;
  final BackupProgressRepository _progress;
  final AuthRepository _authRepository;
  final DateTime Function() _now;

  ScanBackupFilesUseCase(this._gallery, this._progress, this._authRepository, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  Future<BackupScan> call({DateTime? lastCompletedAt, bool checkPermission = true}) async {
    final startedAt = _now();
    final userId = await _userId();

    final watermark = userId == null ? null : await _progress.watermark(userId);
    final since = (watermark ?? lastCompletedAt)?.subtract(margin);
    final added = await _gallery.addedSince(since, checkPermission: checkPermission);

    final files = <String, SyncFile>{for (final file in added.files) file.localId: file};
    final unreadable = {...added.unreadableIds};

    if (userId != null) {
      final pending = (await _progress.pending(userId)).difference(files.keys.toSet()).difference(unreadable);
      if (pending.isNotEmpty) {
        final retried = await _gallery.withIds(pending);
        for (final file in retried.files) {
          files[file.localId] = file;
        }
        unreadable.addAll(retried.unreadableIds);
      }
    }

    final albums = files.isEmpty ? const <String, String>{} : await _gallery.albumsOf(files.keys.toSet());
    return BackupScan(
      files: [for (final file in files.values) file.inAlbum(albums[file.localId])],
      startedAt: startedAt,
      userId: userId,
      unreadableIds: unreadable,
    );
  }

  Future<String?> _userId() async {
    try {
      final user = await _authRepository.getCurrentUser();
      return user == null || user.id.isEmpty ? null : user.id;
    } catch (_) {
      return null;
    }
  }
}
