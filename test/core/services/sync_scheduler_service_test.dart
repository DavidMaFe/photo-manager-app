import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/services/sync_scheduler_service.dart';

import '../../fixtures/test_data.dart';

void main() {
  group('SyncSchedulerService', () {
    group('getTimeUntilNextSync', () {
      // Monday 2026-10-19 at 13:00, after the weekly backup of the free plan at 12:00
      final now = DateTime(2026, 10, 19, 13);
      final config = TestSyncConfigs.weeklySync.copyWith(syncDayOfWeek: DateTime.tuesday, syncHour: 12, syncMinute: 0);

      test('should schedule a day changed after the backup of the week for the week after', () async {
        final scheduler = SyncSchedulerService(
            lastAutomaticBackupAt: () async => DateTime(2026, 10, 19, 12, 5), now: () => now);

        expect(await scheduler.getTimeUntilNextSync(config), DateTime(2026, 10, 27, 12).difference(now));
      });

      test('should schedule the next chosen day when the week had no automatic backup', () async {
        final scheduler = SyncSchedulerService(lastAutomaticBackupAt: () async => null, now: () => now);

        expect(await scheduler.getTimeUntilNextSync(config), DateTime(2026, 10, 20, 12).difference(now));
      });

      test('should schedule as without a backup when it cannot be read', () async {
        final scheduler = SyncSchedulerService(lastAutomaticBackupAt: () async => throw Exception('disk'), now: () => now);

        expect(await scheduler.getTimeUntilNextSync(config), DateTime(2026, 10, 20, 12).difference(now));
      });

      test('should not schedule anything when the automatic backup is off', () async {
        expect(await SyncSchedulerService(now: () => now).getTimeUntilNextSync(TestSyncConfigs.disabled), isNull);
      });
    });
  });
}
