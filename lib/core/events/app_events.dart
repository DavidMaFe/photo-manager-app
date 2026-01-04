/// Base class for all app-wide events
abstract class AppEvent {
  const AppEvent();
}

/// Event broadcasted when files are updated (moved, deleted, modified)
class FileUpdatedEvent extends AppEvent {
  final List<String> affectedFileIds;
  final List<String>? affectedFolderIds;
  final FileUpdateType updateType;

  const FileUpdatedEvent({
    required this.affectedFileIds,
    this.affectedFolderIds,
    required this.updateType,
  });
}

enum FileUpdateType {
  moved,
  deleted,
  updated,
  created,
}

/// Event broadcasted when folders are created, deleted, or renamed
class FolderUpdatedEvent extends AppEvent {
  final List<String>? affectedFolderIds;
  final FolderUpdateType updateType;

  const FolderUpdatedEvent({
    this.affectedFolderIds,
    required this.updateType,
  });
}

enum FolderUpdateType {
  created,
  deleted,
  renamed,
  updated,
}

/// Event broadcasted when a sync session completes
class SyncCompletedEvent extends AppEvent {
  final String syncSessionId;
  final int newFilesCount;
  final DateTime completedAt;

  const SyncCompletedEvent({
    required this.syncSessionId,
    required this.newFilesCount,
    required this.completedAt,
  });
}

/// Event to trigger cache invalidation across the app
class CacheInvalidationEvent extends AppEvent {
  final CacheInvalidationType type;
  final List<String>? specificIds;

  const CacheInvalidationEvent({
    required this.type,
    this.specificIds,
  });
}

enum CacheInvalidationType {
  files,
  folders,
  gallery,
  profile,
  syncHistory,
  all,
}