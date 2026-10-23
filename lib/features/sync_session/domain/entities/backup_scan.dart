import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';

/// The files a backup looks at: the ones that arrived since the last completed backup and the ones the previous
/// backups skipped, each with its album of the gallery (ROADMAP-local-albums.md).
class BackupScan {
  final List<SyncFile> files;

  /// When this backup started to look at the gallery: the next one looks from here.
  final DateTime startedAt;

  /// The account of the backup, or null if it is not known (then nothing is remembered).
  final String? userId;

  /// Files that could not be read: they are tried again by the next backup.
  final Set<String> unreadableIds;

  const BackupScan({required this.files, required this.startedAt, this.userId, this.unreadableIds = const {}});

  bool get isEmpty => files.isEmpty;
}
