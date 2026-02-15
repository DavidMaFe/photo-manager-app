import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/battery_preference.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/network_preference.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/sync_frequency.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';
import 'package:photo_manager_app/features/sync_config/domain/use_cases/save_sync_config_use_case.dart';

import '../../../../fixtures/test_data.dart';

class MockSyncConfigRepository extends Mock implements SyncConfigRepository {}

void main() {
  late SaveSyncConfigUseCase useCase;
  late MockSyncConfigRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(TestSyncConfigs.dailySync);
  });

  setUp(() {
    mockRepository = MockSyncConfigRepository();
    useCase = SaveSyncConfigUseCase(mockRepository);
  });

  group('SaveSyncConfigUseCase', () {
    final testConfig = TestSyncConfigs.dailySync;

    group('valid configs', () {
      test('should save valid daily sync config', () async {
        // Arrange
        when(() => mockRepository.saveSyncConfig(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        await useCase(testConfig);

        // Assert
        verify(() => mockRepository.saveSyncConfig(testConfig)).called(1);
      });

      test('should save valid weekly sync config', () async {
        // Arrange
        final weeklyConfig = TestSyncConfigs.weeklySync;
        when(() => mockRepository.saveSyncConfig(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        await useCase(weeklyConfig);

        // Assert
        verify(() => mockRepository.saveSyncConfig(weeklyConfig)).called(1);
      });

      test('should save disabled config', () async {
        // Arrange
        final disabledConfig = TestSyncConfigs.disabled;
        when(() => mockRepository.saveSyncConfig(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        await useCase(disabledConfig);

        // Assert
        verify(() => mockRepository.saveSyncConfig(disabledConfig)).called(1);
      });

      test('should save config with any network preference', () async {
        // Arrange
        final anyNetworkConfig = TestSyncConfigs.dailySyncAnyConditions;
        when(() => mockRepository.saveSyncConfig(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        await useCase(anyNetworkConfig);

        // Assert
        verify(() => mockRepository.saveSyncConfig(anyNetworkConfig)).called(1);
      });
    });

    group('validation - sync hour', () {
      test('should throw exception when sync hour is less than 0', () async {
        // Arrange
        const invalidConfig = SyncConfig(
          autoSyncEnabled: true,
          syncFrequency: SyncFrequency.daily,
          syncHour: -1,
          syncMinute: 0,
          networkPreference: NetworkPreference.wifiOnly,
          batteryPreference: BatteryPreference.chargingOrAbove15Percent,
          notifyOnSuccess: false,
          notifyOnFailure: true,
        );

        // Act & Assert
        expect(
          () => useCase(invalidConfig),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Sync hour must be between 0 and 23'),
            ),
          ),
        );
        verifyNever(() => mockRepository.saveSyncConfig(any()));
      });

      test('should throw exception when sync hour is greater than 23',
          () async {
        // Arrange
        const invalidConfig = SyncConfig(
          autoSyncEnabled: true,
          syncFrequency: SyncFrequency.daily,
          syncHour: 24,
          syncMinute: 0,
          networkPreference: NetworkPreference.wifiOnly,
          batteryPreference: BatteryPreference.chargingOrAbove15Percent,
          notifyOnSuccess: false,
          notifyOnFailure: true,
        );

        // Act & Assert
        expect(
          () => useCase(invalidConfig),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Sync hour must be between 0 and 23'),
            ),
          ),
        );
      });

      test('should accept sync hour at 0 (midnight)', () async {
        // Arrange
        const midnightConfig = SyncConfig(
          autoSyncEnabled: true,
          syncFrequency: SyncFrequency.daily,
          syncHour: 0,
          syncMinute: 0,
          networkPreference: NetworkPreference.wifiOnly,
          batteryPreference: BatteryPreference.chargingOrAbove15Percent,
          notifyOnSuccess: false,
          notifyOnFailure: true,
        );
        when(() => mockRepository.saveSyncConfig(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        await useCase(midnightConfig);

        // Assert - should not throw
        verify(() => mockRepository.saveSyncConfig(midnightConfig)).called(1);
      });

      test('should accept sync hour at 23', () async {
        // Arrange
        const lateConfig = SyncConfig(
          autoSyncEnabled: true,
          syncFrequency: SyncFrequency.daily,
          syncHour: 23,
          syncMinute: 0,
          networkPreference: NetworkPreference.wifiOnly,
          batteryPreference: BatteryPreference.chargingOrAbove15Percent,
          notifyOnSuccess: false,
          notifyOnFailure: true,
        );
        when(() => mockRepository.saveSyncConfig(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        await useCase(lateConfig);

        // Assert - should not throw
        verify(() => mockRepository.saveSyncConfig(lateConfig)).called(1);
      });
    });

    group('validation - sync minute', () {
      test('should throw exception when sync minute is less than 0', () async {
        // Arrange
        const invalidConfig = SyncConfig(
          autoSyncEnabled: true,
          syncFrequency: SyncFrequency.daily,
          syncHour: 2,
          syncMinute: -1,
          networkPreference: NetworkPreference.wifiOnly,
          batteryPreference: BatteryPreference.chargingOrAbove15Percent,
          notifyOnSuccess: false,
          notifyOnFailure: true,
        );

        // Act & Assert
        expect(
          () => useCase(invalidConfig),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Sync minute must be between 0 and 59'),
            ),
          ),
        );
      });

      test('should throw exception when sync minute is greater than 59',
          () async {
        // Arrange
        const invalidConfig = SyncConfig(
          autoSyncEnabled: true,
          syncFrequency: SyncFrequency.daily,
          syncHour: 2,
          syncMinute: 60,
          networkPreference: NetworkPreference.wifiOnly,
          batteryPreference: BatteryPreference.chargingOrAbove15Percent,
          notifyOnSuccess: false,
          notifyOnFailure: true,
        );

        // Act & Assert
        expect(
          () => useCase(invalidConfig),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Sync minute must be between 0 and 59'),
            ),
          ),
        );
      });

      test('should accept sync minute at 0', () async {
        // Arrange
        when(() => mockRepository.saveSyncConfig(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        await useCase(testConfig); // Has minute = 0

        // Assert - should not throw
        verify(() => mockRepository.saveSyncConfig(testConfig)).called(1);
      });

      test('should accept sync minute at 59', () async {
        // Arrange
        const config59 = SyncConfig(
          autoSyncEnabled: true,
          syncFrequency: SyncFrequency.daily,
          syncHour: 2,
          syncMinute: 59,
          networkPreference: NetworkPreference.wifiOnly,
          batteryPreference: BatteryPreference.chargingOrAbove15Percent,
          notifyOnSuccess: false,
          notifyOnFailure: true,
        );
        when(() => mockRepository.saveSyncConfig(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        await useCase(config59);

        // Assert - should not throw
        verify(() => mockRepository.saveSyncConfig(config59)).called(1);
      });
    });

    group('validation - weekly sync day of week', () {
      test('should throw exception when weekly sync has null day of week',
          () async {
        // Arrange
        const invalidWeeklyConfig = SyncConfig(
          autoSyncEnabled: true,
          syncFrequency: SyncFrequency.weekly,
          syncHour: 2,
          syncMinute: 0,
          syncDayOfWeek: null, // Invalid for weekly
          networkPreference: NetworkPreference.wifiOnly,
          batteryPreference: BatteryPreference.chargingOrAbove15Percent,
          notifyOnSuccess: false,
          notifyOnFailure: true,
        );

        // Act & Assert
        expect(
          () => useCase(invalidWeeklyConfig),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Day of week is required for weekly sync'),
            ),
          ),
        );
      });

      test('should throw exception when day of week is less than 1', () async {
        // Arrange
        const invalidConfig = SyncConfig(
          autoSyncEnabled: true,
          syncFrequency: SyncFrequency.weekly,
          syncHour: 2,
          syncMinute: 0,
          syncDayOfWeek: 0,
          networkPreference: NetworkPreference.wifiOnly,
          batteryPreference: BatteryPreference.chargingOrAbove15Percent,
          notifyOnSuccess: false,
          notifyOnFailure: true,
        );

        // Act & Assert
        expect(
          () => useCase(invalidConfig),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Day of week must be between 1 (Monday) and 7 (Sunday)'),
            ),
          ),
        );
      });

      test('should throw exception when day of week is greater than 7',
          () async {
        // Arrange
        const invalidConfig = SyncConfig(
          autoSyncEnabled: true,
          syncFrequency: SyncFrequency.weekly,
          syncHour: 2,
          syncMinute: 0,
          syncDayOfWeek: 8,
          networkPreference: NetworkPreference.wifiOnly,
          batteryPreference: BatteryPreference.chargingOrAbove15Percent,
          notifyOnSuccess: false,
          notifyOnFailure: true,
        );

        // Act & Assert
        expect(
          () => useCase(invalidConfig),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Day of week must be between 1 (Monday) and 7 (Sunday)'),
            ),
          ),
        );
      });

      test('should accept day of week at 1 (Monday)', () async {
        // Arrange
        final mondayConfig = TestSyncConfigs.weeklySync; // Has day = 1
        when(() => mockRepository.saveSyncConfig(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        await useCase(mondayConfig);

        // Assert - should not throw
        verify(() => mockRepository.saveSyncConfig(mondayConfig)).called(1);
      });

      test('should accept day of week at 7 (Sunday)', () async {
        // Arrange
        final sundayConfig = TestSyncConfigs.weeklySyncSunday; // Has day = 7
        when(() => mockRepository.saveSyncConfig(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        await useCase(sundayConfig);

        // Assert - should not throw
        verify(() => mockRepository.saveSyncConfig(sundayConfig)).called(1);
      });

      test('should allow null day of week for daily sync', () async {
        // Arrange
        when(() => mockRepository.saveSyncConfig(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        await useCase(testConfig); // Daily with null day

        // Assert - should not throw
        verify(() => mockRepository.saveSyncConfig(testConfig)).called(1);
      });
    });

    group('repository errors', () {
      test('should propagate repository errors', () async {
        // Arrange
        when(() => mockRepository.saveSyncConfig(any()))
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => useCase(testConfig),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
