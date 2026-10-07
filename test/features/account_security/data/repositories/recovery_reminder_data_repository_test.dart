import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/account_security/data/repositories/recovery_reminder_data_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late RecoveryReminderDataRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = RecoveryReminderDataRepository(sharedPreferences: await SharedPreferences.getInstance());
  });

  group('RecoveryReminderDataRepository', () {
    test('should have no reminder and no checks at first', () async {
      expect(await repository.getNextReminder(), isNull);
      expect(await repository.getCompletedVerifications(), 0);
    });

    test('should keep the next reminder and the completed checks', () async {
      final next = DateTime(2026, 10, 9, 12, 30);

      await repository.save(nextReminder: next, completedVerifications: 2);

      expect(await repository.getNextReminder(), next);
      expect(await repository.getCompletedVerifications(), 2);
    });

    test('should forget everything on clear (logout)', () async {
      await repository.save(nextReminder: DateTime(2026, 10, 9), completedVerifications: 1);

      await repository.clear();

      expect(await repository.getNextReminder(), isNull);
      expect(await repository.getCompletedVerifications(), 0);
    });

    test('should ignore a stored date it cannot read', () async {
      SharedPreferences.setMockInitialValues({'E2EE_RECOVERY_REMINDER_NEXT': 'not a date'});
      repository = RecoveryReminderDataRepository(sharedPreferences: await SharedPreferences.getInstance());

      expect(await repository.getNextReminder(), isNull);
    });
  });
}
