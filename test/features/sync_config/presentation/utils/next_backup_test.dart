import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_config/presentation/utils/next_backup.dart';

import '../../../../fixtures/test_data.dart';

void main() {
  group('nextBackupAt', () {
    // 2026-10-03 is a Saturday.
    final saturdayNoon = DateTime(2026, 10, 3, 12, 0);

    test('should return null when automatic backup is off', () {
      expect(nextBackupAt(TestSyncConfigs.disabled, saturdayNoon), isNull);
    });

    test('should schedule a daily backup for tomorrow once today\'s time passed', () {
      // dailySync runs at 02:00
      expect(nextBackupAt(TestSyncConfigs.dailySync, saturdayNoon), DateTime(2026, 10, 4, 2, 0));
    });

    test('should schedule a daily backup later today when the time is ahead', () {
      expect(nextBackupAt(TestSyncConfigs.dailySync, DateTime(2026, 10, 3, 1, 0)), DateTime(2026, 10, 3, 2, 0));
    });

    test('should schedule a weekly backup on the next matching weekday', () {
      // weeklySync runs on Monday at 01:00
      expect(nextBackupAt(TestSyncConfigs.weeklySync, saturdayNoon), DateTime(2026, 10, 5, 1, 0));
    });

    test('should move a weekly backup to next week once it passed today', () {
      final mondayMorning = DateTime(2026, 10, 5, 8, 0);
      expect(nextBackupAt(TestSyncConfigs.weeklySync, mondayMorning), DateTime(2026, 10, 12, 1, 0));
    });
  });
}
