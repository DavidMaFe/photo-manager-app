import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

/// Trace of the background sync and download runs, readable in logcat (`SyncLog`).
///
/// Used from the main isolate and from the WorkManager background isolate. It is no longer stored on the device:
/// the sync diagnostics panel that showed it was removed, and [clear] deletes what older versions stored.
class SyncLogService {
  final SharedPreferences _prefs;

  // Stored by older versions for the removed diagnostics panel
  static const _legacyKeys = ['SYNC_EVENT_LOG', 'SYNC_LAST_RESULT', 'SYNC_LAST_RESULT_TIME'];

  SyncLogService(this._prefs);

  void write(String message) => developer.log(message, name: 'SyncLog');

  /// Final result of a sync run.
  void writeResult({required bool success, String? detail}) {
    final label = success ? 'Completed' : 'Failed';
    write(detail == null ? label : '$label: $detail');
  }

  /// Deletes what older versions stored on the device (called when the session ends).
  Future<void> clear() async {
    for (final key in _legacyKeys) {
      await _prefs.remove(key);
    }
  }
}
