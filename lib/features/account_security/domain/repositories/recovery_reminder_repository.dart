/// When to ask the user to check that they still have the 24 words.
abstract class RecoveryReminderRepository {
  Future<DateTime?> getNextReminder();

  Future<int> getCompletedVerifications();

  Future<void> save({required DateTime nextReminder, required int completedVerifications});

  Future<void> clear();
}
