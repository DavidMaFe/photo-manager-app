import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/sync_config/data/data_sources/sync_config_local_data_source.dart';
import 'package:photo_manager_app/features/sync_config/data/models/sync_config_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/test_data.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late SyncConfigLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = SyncConfigLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('SyncConfigLocalDataSource', () {
    final testConfig = SyncConfigModel.fromEntity(TestSyncConfigs.dailySync);
    const syncConfigKey = 'SYNC_CONFIG';

    group('cacheSyncConfig', () {
      test('should cache sync config as JSON string in SharedPreferences',
          () async {
        // Arrange
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheSyncConfig(testConfig);

        // Assert
        final expectedJson = jsonEncode(testConfig.toJson());
        verify(
          () => mockSharedPreferences.setString(syncConfigKey, expectedJson),
        ).called(1);
      });

      test('should convert SyncConfigModel to JSON correctly before caching',
          () async {
        // Arrange
        String? capturedJson;
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((invocation) async {
          capturedJson = invocation.positionalArguments[1] as String;
          return true;
        });

        // Act
        await dataSource.cacheSyncConfig(testConfig);

        // Assert
        expect(capturedJson, isNotNull);
        final decoded = jsonDecode(capturedJson!);
        expect(decoded['autoSyncEnabled'], testConfig.autoSyncEnabled);
        expect(decoded['syncFrequency'], testConfig.syncFrequency.toJson());
        expect(decoded['syncHour'], testConfig.syncHour);
        expect(decoded['syncMinute'], testConfig.syncMinute);
      });

      test('should cache weekly sync config with day of week', () async {
        // Arrange
        final weeklyConfig =
            SyncConfigModel.fromEntity(TestSyncConfigs.weeklySync);
        String? capturedJson;
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((invocation) async {
          capturedJson = invocation.positionalArguments[1] as String;
          return true;
        });

        // Act
        await dataSource.cacheSyncConfig(weeklyConfig);

        // Assert
        expect(capturedJson, isNotNull);
        final decoded = jsonDecode(capturedJson!);
        expect(decoded['syncFrequency'], 'weekly');
        expect(decoded['syncDayOfWeek'], 1); // Monday
      });
    });

    group('getSyncConfig', () {
      test('should return cached sync config when data exists', () async {
        // Arrange
        final configJson = jsonEncode(testConfig.toJson());
        when(() => mockSharedPreferences.getString(syncConfigKey))
            .thenReturn(configJson);

        // Act
        final result = await dataSource.getSyncConfig();

        // Assert
        expect(result, isNotNull);
        expect(result!.autoSyncEnabled, testConfig.autoSyncEnabled);
        expect(result.syncFrequency, testConfig.syncFrequency);
        expect(result.syncHour, testConfig.syncHour);
        expect(result.syncMinute, testConfig.syncMinute);
        expect(result.networkPreference, testConfig.networkPreference);
        expect(result.batteryPreference, testConfig.batteryPreference);
      });

      test('should return null when no cached config exists', () async {
        // Arrange
        when(() => mockSharedPreferences.getString(syncConfigKey))
            .thenReturn(null);

        // Act
        final result = await dataSource.getSyncConfig();

        // Assert
        expect(result, isNull);
      });

      test('should parse JSON correctly from cache', () async {
        // Arrange
        final configJson = jsonEncode(TestSyncConfigJsonData.dailySyncJson);
        when(() => mockSharedPreferences.getString(syncConfigKey))
            .thenReturn(configJson);

        // Act
        final result = await dataSource.getSyncConfig();

        // Assert
        expect(result!.autoSyncEnabled, true);
        expect(result.syncFrequency.isDaily, true);
        expect(result.syncHour, 2);
        expect(result.syncMinute, 0);
        expect(result.syncDayOfWeek, null);
      });

      test('should handle weekly sync config with day of week', () async {
        // Arrange
        final configJson = jsonEncode(TestSyncConfigJsonData.weeklySyncJson);
        when(() => mockSharedPreferences.getString(syncConfigKey))
            .thenReturn(configJson);

        // Act
        final result = await dataSource.getSyncConfig();

        // Assert
        expect(result!.syncFrequency.isWeekly, true);
        expect(result.syncDayOfWeek, 1);
      });

      test('should handle disabled sync config', () async {
        // Arrange
        final configJson = jsonEncode(TestSyncConfigJsonData.disabledSyncJson);
        when(() => mockSharedPreferences.getString(syncConfigKey))
            .thenReturn(configJson);

        // Act
        final result = await dataSource.getSyncConfig();

        // Assert
        expect(result!.autoSyncEnabled, false);
      });
    });

    group('clearSyncConfig', () {
      test('should remove sync config from SharedPreferences', () async {
        // Arrange
        when(() => mockSharedPreferences.remove(any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.clearSyncConfig();

        // Assert
        verify(() => mockSharedPreferences.remove(syncConfigKey)).called(1);
      });

      test('should complete even if key does not exist', () async {
        // Arrange
        when(() => mockSharedPreferences.remove(any()))
            .thenAnswer((_) async => false);

        // Act & Assert - should not throw
        await expectLater(dataSource.clearSyncConfig(), completes);
      });
    });

    group('hasSyncConfig', () {
      test('should return true when config exists', () async {
        // Arrange
        when(() => mockSharedPreferences.containsKey(syncConfigKey))
            .thenReturn(true);

        // Act
        final result = await dataSource.hasSyncConfig();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when config does not exist', () async {
        // Arrange
        when(() => mockSharedPreferences.containsKey(syncConfigKey))
            .thenReturn(false);

        // Act
        final result = await dataSource.hasSyncConfig();

        // Assert
        expect(result, isFalse);
      });
    });

    group('cache round-trip', () {
      test('should retrieve same config data after caching', () async {
        // Arrange
        String? cachedJson;
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((invocation) async {
          cachedJson = invocation.positionalArguments[1] as String;
          return true;
        });
        when(() => mockSharedPreferences.getString(syncConfigKey))
            .thenAnswer((_) => cachedJson);

        // Act
        await dataSource.cacheSyncConfig(testConfig);
        final result = await dataSource.getSyncConfig();

        // Assert
        expect(result, isNotNull);
        expect(result!.autoSyncEnabled, testConfig.autoSyncEnabled);
        expect(result.syncFrequency, testConfig.syncFrequency);
        expect(result.syncHour, testConfig.syncHour);
        expect(result.syncMinute, testConfig.syncMinute);
        expect(result.syncDayOfWeek, testConfig.syncDayOfWeek);
        expect(result.networkPreference, testConfig.networkPreference);
        expect(result.batteryPreference, testConfig.batteryPreference);
        expect(result.notifyOnSuccess, testConfig.notifyOnSuccess);
        expect(result.notifyOnFailure, testConfig.notifyOnFailure);
      });

      test('should handle different config types in round-trip', () async {
        // Arrange
        final weeklyConfig =
            SyncConfigModel.fromEntity(TestSyncConfigs.weeklySync);
        String? cachedJson;
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((invocation) async {
          cachedJson = invocation.positionalArguments[1] as String;
          return true;
        });
        when(() => mockSharedPreferences.getString(syncConfigKey))
            .thenAnswer((_) => cachedJson);

        // Act
        await dataSource.cacheSyncConfig(weeklyConfig);
        final result = await dataSource.getSyncConfig();

        // Assert
        expect(result!.syncFrequency.isWeekly, true);
        expect(result.syncDayOfWeek, 1);
      });
    });
  });
}
