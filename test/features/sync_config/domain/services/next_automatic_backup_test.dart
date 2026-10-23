import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/services/next_automatic_backup.dart';

import '../../../../fixtures/test_data.dart';

void main() {
  // 2026-10-19 is a Monday
  final mondayBackup = DateTime(2026, 10, 19, 12, 5);
  SyncConfig weeklyOn(int day, {int hour = 12, int minute = 0}) =>
      TestSyncConfigs.weeklySync.copyWith(syncDayOfWeek: day, syncHour: hour, syncMinute: minute);

  group('NextAutomaticBackup', () {
    group('of', () {
      test('should move a day changed to later in the week to the week after, once the week had its backup', () {
        // The free plan backed up on Monday at 12:00 and the user chooses Tuesday right after
        final next = NextAutomaticBackup.of(weeklyOn(DateTime.tuesday), DateTime(2026, 10, 19, 12, 10),
            lastCompleted: mondayBackup);

        expect(next, DateTime(2026, 10, 27, 12, 0));
      });

      test('should move Sunday of the same week to the next Sunday', () {
        final next = NextAutomaticBackup.of(weeklyOn(DateTime.sunday), DateTime(2026, 10, 19, 13),
            lastCompleted: mondayBackup);

        expect(next, DateTime(2026, 11, 1, 12, 0));
      });

      test('should move a later hour of the same Monday to the next Monday', () {
        final next = NextAutomaticBackup.of(weeklyOn(DateTime.monday, hour: 20), DateTime(2026, 10, 19, 13),
            lastCompleted: mondayBackup);

        expect(next, DateTime(2026, 10, 26, 20, 0));
      });

      test('should keep the next Monday after a Monday backup', () {
        final next = NextAutomaticBackup.of(weeklyOn(DateTime.monday), DateTime(2026, 10, 19, 12, 10),
            lastCompleted: mondayBackup);

        expect(next, DateTime(2026, 10, 26, 12, 0));
      });

      test('should allow the Monday after a Sunday backup: it is another week', () {
        final sundayBackup = DateTime(2026, 10, 25, 12, 5);

        final next = NextAutomaticBackup.of(weeklyOn(DateTime.monday), DateTime(2026, 10, 25, 13),
            lastCompleted: sundayBackup);

        expect(next, DateTime(2026, 10, 26, 12, 0));
      });

      test('should take the next chosen day without a backup before, or with one of another week', () {
        expect(NextAutomaticBackup.of(weeklyOn(DateTime.tuesday), DateTime(2026, 10, 19, 13)),
            DateTime(2026, 10, 20, 12, 0));
        expect(
            NextAutomaticBackup.of(weeklyOn(DateTime.tuesday), DateTime(2026, 10, 19, 13),
                lastCompleted: DateTime(2026, 10, 12, 12, 5)),
            DateTime(2026, 10, 20, 12, 0));
      });

      test('should not limit the daily backup of the paid plans', () {
        final next = NextAutomaticBackup.of(TestSyncConfigs.dailySync.copyWith(syncHour: 12, syncMinute: 0),
            DateTime(2026, 10, 19, 13), lastCompleted: mondayBackup);

        expect(next, DateTime(2026, 10, 20, 12, 0));
      });

      test('should answer nothing when the automatic backup is off', () {
        expect(NextAutomaticBackup.of(TestSyncConfigs.disabled, DateTime(2026, 10, 19)), isNull);
      });
    });

    group('alreadyDoneThisWeek', () {
      test('should say a weekly backup of this week already completed', () {
        expect(NextAutomaticBackup.alreadyDoneThisWeek(weeklyOn(DateTime.tuesday), DateTime(2026, 10, 20, 12),
            mondayBackup), isTrue);
      });

      test('should let the backup of the next week run', () {
        expect(NextAutomaticBackup.alreadyDoneThisWeek(weeklyOn(DateTime.monday), DateTime(2026, 10, 26, 12),
            mondayBackup), isFalse);
      });

      test('should let the first backup and the daily backups run', () {
        expect(NextAutomaticBackup.alreadyDoneThisWeek(weeklyOn(DateTime.monday), DateTime(2026, 10, 19), null),
            isFalse);
        expect(NextAutomaticBackup.alreadyDoneThisWeek(TestSyncConfigs.dailySync, DateTime(2026, 10, 20),
            mondayBackup), isFalse);
      });
    });
  });
}
