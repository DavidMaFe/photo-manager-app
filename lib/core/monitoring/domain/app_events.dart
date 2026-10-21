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
