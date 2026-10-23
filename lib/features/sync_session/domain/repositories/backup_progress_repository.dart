/// What the backups of each account have seen of the gallery of this device (ROADMAP-local-albums.md).
abstract class BackupProgressRepository {
  /// When the last completed backup of the account started to look at the gallery, or null.
  Future<DateTime?> watermark(String userId);

  Future<void> saveWatermark(String userId, DateTime scanStartedAt);

  /// The files the backups of the account skipped, to try again.
  Future<Set<String>> pending(String userId);

  Future<void> replacePending(String userId, Set<String> localIds);

  /// Adds files for the next backup to try (an album that was not backed up and now is).
  Future<void> addPending(String userId, Set<String> localIds);
}
