import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/sync_config/data/data_sources/sync_config_local_data_source.dart';
import 'package:photo_manager_app/features/sync_config/data/models/sync_config_model.dart';
import 'package:photo_manager_app/features/sync_config/data/repositories/sync_config_data_repository.dart';

import '../../../../fixtures/test_data.dart';

class MockSyncConfigLocalDataSource extends Mock
    implements SyncConfigLocalDataSource {}

void main() {
  late SyncConfigDataRepository repository;
  late MockSyncConfigLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(
      SyncConfigModel.fromEntity(TestSyncConfigs.dailySync),
    );
  });

  setUp(() {
    mockLocalDataSource = MockSyncConfigLocalDataSource();
    repository = SyncConfigDataRepository(
      localDataSource: mockLocalDataSource,
    );
  });

  group('SyncConfigDataRepository', () {
    final testConfig = TestSyncConfigs.dailySync;
    final testConfigModel = SyncConfigModel.fromEntity(testConfig);

    group('getSyncConfig', () {
      test('should return sync config from local data source when it exists',
          () async {
        // Arrange
        when(() => mockLocalDataSource.getSyncConfig())
            .thenAnswer((_) async => testConfigModel);

        // Act
        final result = await repository.getSyncConfig();

        // Assert
        expect(result, isNotNull);
        expect(result!.autoSyncEnabled, testConfig.autoSyncEnabled);
        expect(result.syncFrequency, testConfig.syncFrequency);
        expect(result.syncHour, testConfig.syncHour);
        verify(() => mockLocalDataSource.getSyncConfig()).called(1);
      });

      test('should return null when no config exists', () async {
        // Arrange
        when(() => mockLocalDataSource.getSyncConfig())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getSyncConfig();

        // Assert
        expect(result, isNull);
        verify(() => mockLocalDataSource.getSyncConfig()).called(1);
      });

      test('should return weekly sync config correctly', () async {
        // Arrange
        final weeklyConfig = TestSyncConfigs.weeklySync;
        final weeklyConfigModel = SyncConfigModel.fromEntity(weeklyConfig);
        when(() => mockLocalDataSource.getSyncConfig())
            .thenAnswer((_) async => weeklyConfigModel);

        // Act
        final result = await repository.getSyncConfig();

        // Assert
        expect(result!.syncFrequency.isWeekly, true);
        expect(result.syncDayOfWeek, 1);
      });
    });

    group('saveSyncConfig', () {
      test('should save sync config to local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.cacheSyncConfig(any()))
            .thenAnswer((_) async => Future.value());

        // Act
        await repository.saveSyncConfig(testConfig);

        // Assert
        verify(() => mockLocalDataSource.cacheSyncConfig(any())).called(1);
      });

      test('should convert entity to model before saving', () async {
        // Arrange
        SyncConfigModel? capturedModel;
        when(() => mockLocalDataSource.cacheSyncConfig(any()))
            .thenAnswer((invocation) async {
          capturedModel =
              invocation.positionalArguments[0] as SyncConfigModel;
        });

        // Act
        await repository.saveSyncConfig(testConfig);

        // Assert
        expect(capturedModel, isNotNull);
        expect(capturedModel!.autoSyncEnabled, testConfig.autoSyncEnabled);
        expect(capturedModel!.syncFrequency, testConfig.syncFrequency);
        expect(capturedModel!.syncHour, testConfig.syncHour);
      });

      test('should save disabled config correctly', () async {
        // Arrange
        final disabledConfig = TestSyncConfigs.disabled;
        SyncConfigModel? capturedModel;
        when(() => mockLocalDataSource.cacheSyncConfig(any()))
            .thenAnswer((invocation) async {
          capturedModel =
              invocation.positionalArguments[0] as SyncConfigModel;
        });

        // Act
        await repository.saveSyncConfig(disabledConfig);

        // Assert
        expect(capturedModel!.autoSyncEnabled, false);
      });
    });

    group('clearSyncConfig', () {
      test('should call clearSyncConfig on local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.clearSyncConfig())
            .thenAnswer((_) async => Future.value());

        // Act
        await repository.clearSyncConfig();

        // Assert
        verify(() => mockLocalDataSource.clearSyncConfig()).called(1);
      });
    });

    group('hasSyncConfig', () {
      test('should return true when config exists', () async {
        // Arrange
        when(() => mockLocalDataSource.hasSyncConfig())
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.hasSyncConfig();

        // Assert
        expect(result, isTrue);
        verify(() => mockLocalDataSource.hasSyncConfig()).called(1);
      });

      test('should return false when config does not exist', () async {
        // Arrange
        when(() => mockLocalDataSource.hasSyncConfig())
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.hasSyncConfig();

        // Assert
        expect(result, isFalse);
        verify(() => mockLocalDataSource.hasSyncConfig()).called(1);
      });
    });

    group('repository flow', () {
      test('should save and retrieve config correctly', () async {
        // Arrange
        SyncConfigModel? savedModel;
        when(() => mockLocalDataSource.cacheSyncConfig(any()))
            .thenAnswer((invocation) async {
          savedModel =
              invocation.positionalArguments[0] as SyncConfigModel;
        });
        when(() => mockLocalDataSource.getSyncConfig())
            .thenAnswer((_) async => savedModel);

        // Act
        await repository.saveSyncConfig(testConfig);
        final result = await repository.getSyncConfig();

        // Assert
        expect(result, isNotNull);
        expect(result!.autoSyncEnabled, testConfig.autoSyncEnabled);
        expect(result.syncHour, testConfig.syncHour);
      });

      test('should return null after clearing config', () async {
        // Arrange
        when(() => mockLocalDataSource.cacheSyncConfig(any()))
            .thenAnswer((_) async => Future.value());
        when(() => mockLocalDataSource.clearSyncConfig())
            .thenAnswer((_) async => Future.value());
        when(() => mockLocalDataSource.getSyncConfig())
            .thenAnswer((_) async => null);

        // Act
        await repository.saveSyncConfig(testConfig);
        await repository.clearSyncConfig();
        final result = await repository.getSyncConfig();

        // Assert
        expect(result, isNull);
      });
    });
  });
}
