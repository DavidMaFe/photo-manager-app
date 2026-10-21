import 'package:photo_manager_app/core/monitoring/domain/app_log_entry.dart';

/// Something of the app worth seeing in the monitoring. Features only build events and give them to
/// [AppEventLog]; how they are queued and sent is not their concern.
abstract class AppLogEvent {
  const AppLogEvent();

  /// UPPER_SNAKE_CASE, prefixed by its area (`SYNC_`, `DOWNLOAD_`…).
  String get name;

  AppLogLevel get level => AppLogLevel.info;

  /// A short description without personal data: counts, codes and states only.
  String? get message => null;
}
