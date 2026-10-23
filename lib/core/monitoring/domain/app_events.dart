import 'package:photo_manager_app/core/monitoring/domain/app_log_entry.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_log_event.dart';

/// A backup that did not finish: manual or in the background.
class SyncFailed extends AppLogEvent {
  final bool background;

  /// The code of the failure, e.g. `NETWORK`, `DEVICE_LIMIT_REACHED`.
  final String reason;
  final int uploaded;
  final int failed;

  const SyncFailed({required this.background, required this.reason, this.uploaded = 0, this.failed = 0});

  @override
  String get name => 'SYNC_FAILED';

  @override
  AppLogLevel get level => AppLogLevel.warn;

  @override
  String get message => 'background=$background reason=$reason uploaded=$uploaded failed=$failed';
}

/// A backup that left files out because they did not fit in the free space of the plan.
/// A backup put photos in albums of Photo Manager made from albums of the gallery (ROADMAP-local-albums.md). Never
/// the names of the albums.
class SyncAlbumsCreated extends AppLogEvent {
  final bool background;
  final int albums;

  const SyncAlbumsCreated({required this.background, required this.albums});

  @override
  String get name => 'SYNC_ALBUMS_CREATED';

  @override
  String get message => 'background=$background albums=$albums';
}

class SyncStorageFull extends AppLogEvent {
  final bool background;
  final int files;
  final int bytes;

  const SyncStorageFull({required this.background, required this.files, required this.bytes});

  @override
  String get name => 'SYNC_STORAGE_FULL';

  @override
  AppLogLevel get level => AppLogLevel.warn;

  @override
  String get message => 'background=$background files=$files bytes=$bytes';
}
