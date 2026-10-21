/// Level of a line of the app. The backend accepts these three.
enum AppLogLevel { info, warn, error }

/// One line the app records for the monitoring, kept in a queue until it reaches the backend
/// (POST /api/client-logs/). The device and the version are added when it is sent.
///
/// Never personal data: no emails, names of files, paths or content ([LogSanitizer] cleans the texts).
class AppLogEntry {
  final AppLogLevel level;

  /// UPPER_SNAKE_CASE, e.g. `UNCAUGHT_ERROR`, `SERVER_ERROR`, `SYNC_FAILED`.
  final String event;
  final String? message;
  final String? errorType;
  final String? stackTrace;
  final String? screen;

  /// The `X-Request-Id` of the request that failed, to join this line with the ones of the backend.
  final String? requestId;
  final DateTime occurredAt;

  const AppLogEntry({
    required this.level,
    required this.event,
    required this.occurredAt,
    this.message,
    this.errorType,
    this.stackTrace,
    this.screen,
    this.requestId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLogEntry &&
          other.level == level &&
          other.event == event &&
          other.message == message &&
          other.errorType == errorType &&
          other.stackTrace == stackTrace &&
          other.screen == screen &&
          other.requestId == requestId &&
          other.occurredAt == occurredAt;

  @override
  int get hashCode => Object.hash(level, event, message, errorType, stackTrace, screen, requestId, occurredAt);
}
