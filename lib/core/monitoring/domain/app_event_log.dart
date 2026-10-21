import 'package:photo_manager_app/core/monitoring/domain/app_log_event.dart';

/// The only way the app writes to the monitoring (CLAUDE.md, «Logs and metrics»). The lines reach the log of the
/// backend, next to its own.
abstract class AppEventLog {
  void record(AppLogEvent event);

  /// An error nobody handled (Flutter, a zone, the background isolate).
  void recordError(Object error, StackTrace? stackTrace, {String event = 'UNCAUGHT_ERROR'});
}
