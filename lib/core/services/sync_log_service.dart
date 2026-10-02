import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

/// A single entry in the sync event log.
class SyncLogEntry {
  final DateTime timestamp;
  final String message;

  const SyncLogEntry({required this.timestamp, required this.message});

  Map<String, dynamic> toJson() => {
        'ts': timestamp.toIso8601String(),
        'msg': message,
      };

  factory SyncLogEntry.fromJson(Map<String, dynamic> json) => SyncLogEntry(
        timestamp: DateTime.parse(json['ts'] as String),
        message: json['msg'] as String,
      );

  /// Human-readable time label (e.g. "14:32:07").
  String get timeLabel {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  String toString() => '[$timeLabel] $message';
}

/// Persistent sync event log stored in SharedPreferences.
///
/// Survives background isolate restarts, process kills, and device reboots.
/// Acts as a ring buffer: when [maxEntries] is reached the oldest entry is
/// evicted. The log is readable from both the main isolate (UI) and the
/// WorkManager background isolate.
///
/// Usage:
/// ```dart
/// final log = sl<SyncLogService>();
/// log.write('▶ WorkManager fired task');
/// final entries = await log.readAll();
/// ```
class SyncLogService {
  final SharedPreferences _prefs;

  static const String _logKey = 'SYNC_EVENT_LOG';
  static const String _lastResultKey = 'SYNC_LAST_RESULT';
  static const String _lastResultTimeKey = 'SYNC_LAST_RESULT_TIME';
  static const int maxEntries = 50;

  SyncLogService(this._prefs);

  // ─── Write ──────────────────────────────────────────────────────────────

  /// Append a new event to the log. Thread-safe within a single isolate.
  void write(String message) {
    try {
      final entry = SyncLogEntry(timestamp: DateTime.now(), message: message);
      final raw = _prefs.getString(_logKey);
      final List<dynamic> list = raw != null ? jsonDecode(raw) as List<dynamic> : [];

      list.add(entry.toJson());

      // Evict oldest entries if over capacity.
      if (list.length > maxEntries) {
        list.removeRange(0, list.length - maxEntries);
      }

      _prefs.setString(_logKey, jsonEncode(list));

      // Also forward to dart:developer so it shows up in logcat.
      developer.log(message, name: 'SyncLog');
    } catch (e) {
      developer.log('SyncLogService.write error: $e', name: 'SyncLog');
    }
  }

  /// Record the final result of a sync run (persisted separately for quick
  /// display in the diagnostics card).
  void writeResult({required bool success, String? detail}) {
    final label = success
        ? '✅ Completado${detail != null ? ': $detail' : ''}'
        : '❌ Fallido${detail != null ? ': $detail' : ''}';
    write(label);
    try {
      _prefs.setString(_lastResultKey, label);
      _prefs.setString(_lastResultTimeKey, DateTime.now().toIso8601String());
    } catch (_) {}
  }

  // ─── Read ───────────────────────────────────────────────────────────────

  /// Return all entries, most-recent first.
  List<SyncLogEntry> readAll() {
    try {
      final raw = _prefs.getString(_logKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      final entries = list
          .map((e) => SyncLogEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      return entries.reversed.toList();
    } catch (e) {
      developer.log('SyncLogService.readAll error: $e', name: 'SyncLog');
      return [];
    }
  }

  /// Summary of the last sync result and when it ran, for the diagnostics
  /// card header.
  ({String? result, DateTime? time}) get lastResult {
    try {
      final result = _prefs.getString(_lastResultKey);
      final timeRaw = _prefs.getString(_lastResultTimeKey);
      final time = timeRaw != null ? DateTime.tryParse(timeRaw) : null;
      return (result: result, time: time);
    } catch (_) {
      return (result: null, time: null);
    }
  }

  // ─── Maintenance ────────────────────────────────────────────────────────

  /// Clear all log entries and the last-result cache.
  void clear() {
    try {
      _prefs.remove(_logKey);
      _prefs.remove(_lastResultKey);
      _prefs.remove(_lastResultTimeKey);
    } catch (_) {}
  }
}
