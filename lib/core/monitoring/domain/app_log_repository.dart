import 'package:photo_manager_app/core/monitoring/domain/app_log_entry.dart';

/// Queue of the lines of the app until the backend has them.
abstract class AppLogRepository {
  /// Keeps the line, also across restarts. The oldest lines go when the queue is full.
  Future<void> enqueue(AppLogEntry entry);

  /// Sends the lines queued, in batches. Returns how many were sent; on a failure they stay for the next time.
  Future<int> flush();
}
