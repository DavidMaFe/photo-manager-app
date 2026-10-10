import 'package:photo_manager_app/features/account_security/domain/repositories/recovery_reminder_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reminder dates in SharedPreferences: they are not secrets.
class RecoveryReminderDataRepository implements RecoveryReminderRepository {
  static const String _nextKey = 'E2EE_RECOVERY_REMINDER_NEXT';
  static const String _completedKey = 'E2EE_RECOVERY_REMINDER_COMPLETED';

  final SharedPreferences sharedPreferences;

  RecoveryReminderDataRepository({required this.sharedPreferences});

  @override
  Future<DateTime?> getNextReminder() async {
    final stored = sharedPreferences.getString(_nextKey);
    return stored == null ? null : DateTime.tryParse(stored);
  }

  @override
  Future<int> getCompletedVerifications() async => sharedPreferences.getInt(_completedKey) ?? 0;

  @override
  Future<void> save({required DateTime nextReminder, required int completedVerifications}) async {
    await sharedPreferences.setString(_nextKey, nextReminder.toIso8601String());
    await sharedPreferences.setInt(_completedKey, completedVerifications);
  }

  @override
  Future<void> clear() async {
    await sharedPreferences.remove(_nextKey);
    await sharedPreferences.remove(_completedKey);
  }
}
