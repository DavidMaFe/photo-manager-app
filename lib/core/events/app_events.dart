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

/// Event broadcasted when the favorite mark of files changes.
///
/// Fired optimistically before the server answers, and fired again with the
/// previous value for the files that could not change.
class FavoritesChangedEvent extends AppEvent {
  final List<String> fileIds;
  final bool favorite;

  const FavoritesChangedEvent({required this.fileIds, required this.favorite});
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

/// Event broadcasted when devices are updated (renamed, unlinked, autosync toggled)
class DeviceUpdatedEvent extends AppEvent {
  final List<String>? affectedDeviceIds;
  final DeviceUpdateType updateType;

  const DeviceUpdatedEvent({
    this.affectedDeviceIds,
    required this.updateType,
  });
}

enum DeviceUpdateType {
  renamed,
  unlinked,
  autoSyncToggled,
  updated,
}

/// Event fired by [AuthenticatedHttpClient] when a token refresh attempt fails
/// (i.e. the refresh token is expired or revoked). Listeners should treat this
/// as a hard session expiry and force the user back to the login screen.
class AuthenticationFailedEvent extends AppEvent {
  const AuthenticationFailedEvent();
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