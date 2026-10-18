import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/sync_frequency.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';
import 'package:photo_manager_app/features/sync_config/domain/use_cases/apply_plan_to_sync_config_use_case.dart';

import '../../../../fixtures/test_data.dart';

class MockSyncConfigRepository extends Mock implements SyncConfigRepository {}

void main() {
  late MockSyncConfigRepository repository;
  late List<SyncConfig> rescheduled;
  late ApplyPlanToSyncConfigUseCase applyPlan;

  setUpAll(() => registerFallbackValue(TestSyncConfigs.dailySync));

  setUp(() {
    repository = MockSyncConfigRepository();
    rescheduled = [];
    applyPlan = ApplyPlanToSyncConfigUseCase(repository, reschedule: (config) async => rescheduled.add(config));
    when(() => repository.saveSyncConfig(any())).thenAnswer((_) async {});
  });

  group('ApplyPlanToSyncConfigUseCase', () {
    test('should turn a daily backup into a weekly one on the free plan, at the same time', () async {
      when(() => repository.getSyncConfig()).thenAnswer((_) async => TestSyncConfigs.dailySync);

      final changed = await applyPlan(dailyBackup: false);

      expect(changed, isTrue);
      final saved = verify(() => repository.saveSyncConfig(captureAny())).captured.single as SyncConfig;
      expect(saved.syncFrequency, SyncFrequency.weekly);
      expect(saved.syncDayOfWeek, DateTime.monday);
      expect(saved.syncHour, TestSyncConfigs.dailySync.syncHour);
      expect(rescheduled, [saved]);
    });

    test('should keep a daily backup when the plan includes it', () async {
      final changed = await applyPlan(dailyBackup: true);

      expect(changed, isFalse);
      verifyNever(() => repository.getSyncConfig());
    });

    test('should keep a weekly backup as it is', () async {
      when(() => repository.getSyncConfig()).thenAnswer((_) async => TestSyncConfigs.weeklySync);

      expect(await applyPlan(dailyBackup: false), isFalse);
      verifyNever(() => repository.saveSyncConfig(any()));
    });

    test('should do nothing without a backup configuration', () async {
      when(() => repository.getSyncConfig()).thenAnswer((_) async => null);

      expect(await applyPlan(dailyBackup: false), isFalse);
    });

    test('should not schedule a disabled automatic backup', () async {
      when(() => repository.getSyncConfig())
          .thenAnswer((_) async => TestSyncConfigs.dailySync.copyWith(autoSyncEnabled: false));

      expect(await applyPlan(dailyBackup: false), isTrue);
      expect(rescheduled, isEmpty);
    });
  });
}
