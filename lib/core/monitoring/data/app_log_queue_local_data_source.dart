import 'dart:convert';

import 'package:photo_manager_app/core/monitoring/data/app_log_entry_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The lines waiting to be sent, in SharedPreferences: they survive a restart and the background isolate shares
/// them. At most [maxEntries]: the oldest go first.
class AppLogQueueLocalDataSource {
  static const String key = 'APP_LOG_QUEUE';
  static const int maxEntries = 200;

  final SharedPreferences sharedPreferences;

  AppLogQueueLocalDataSource({required this.sharedPreferences});

  Future<List<AppLogEntryModel>> getAll() async {
    await sharedPreferences.reload();
    final raw = sharedPreferences.getString(key);
    if (raw == null) {
      return [];
    }
    try {
      return (jsonDecode(raw) as List)
          .map((json) => AppLogEntryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // A broken queue is dropped: it only held logs
      await sharedPreferences.remove(key);
      return [];
    }
  }

  Future<void> add(AppLogEntryModel entry) async {
    final entries = [...await getAll(), entry];
    await _save(entries.length > maxEntries ? entries.sublist(entries.length - maxEntries) : entries);
  }

  /// Removes the first [count] lines (the ones just sent).
  Future<void> removeFirst(int count) async {
    final entries = await getAll();
    await _save(count >= entries.length ? [] : entries.sublist(count));
  }

  Future<void> _save(List<AppLogEntryModel> entries) =>
      sharedPreferences.setString(key, jsonEncode(entries.map((entry) => entry.toJson()).toList()));
}
