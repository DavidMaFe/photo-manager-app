import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';
import 'package:photo_manager_app/features/sync_config/domain/use_cases/get_sync_config_use_case.dart';

import '../../../../fixtures/test_data.dart';

class MockSyncConfigRepository extends Mock implements SyncConfigRepository {}

void main() {
  late GetSyncConfigUseCase useCase;
  late MockSyncConfigRepository mockRepository;

  setUp(() {
    mockRepository = MockSyncConfigRepository();
    useCase = GetSyncConfigUseCase(mockRepository);
  });

  group('GetSyncConfigUseCase', () {
    final testConfig = TestSyncConfigs.dailySync;

    test('should return sync config from repository when it exists', () async {
      // Arrange
      when(() => mockRepository.getSyncConfig())
          .thenAnswer((_) async => testConfig);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(testConfig));
      expect(result.autoSyncEnabled, testConfig.autoSyncEnabled);
      expect(result.syncHour, testConfig.syncHour);
      verify(() => mockRepository.getSyncConfig()).called(1);
    });

    test('should return disabled config when no config exists', () async {
      // Arrange
      when(() => mockRepository.getSyncConfig()).thenAnswer((_) async => null);

      // Act
      final result = await useCase();

      // Assert
      expect(result.autoSyncEnabled, false);
      expect(result.syncFrequency.isDaily, true);
      expect(result.syncHour, 2); // Default hour
      expect(result.syncMinute, 0); // Default minute
      expect(result.networkPreference.isWifiOnly, true);
      expect(result.batteryPreference.isChargingOrAbove15Percent, true);
      verify(() => mockRepository.getSyncConfig()).called(1);
    });

    test('should return weekly config correctly', () async {
      // Arrange
      final weeklyConfig = TestSyncConfigs.weeklySync;
      when(() => mockRepository.getSyncConfig())
          .thenAnswer((_) async => weeklyConfig);

      // Act
      final result = await useCase();

      // Assert
      expect(result.syncFrequency.isWeekly, true);
      expect(result.syncDayOfWeek, 1); // Monday
    });

    test('should return config with any network preference', () async {
      // Arrange
      final anyNetworkConfig = TestSyncConfigs.dailySyncAnyConditions;
      when(() => mockRepository.getSyncConfig())
          .thenAnswer((_) async => anyNetworkConfig);

      // Act
      final result = await useCase();

      // Assert
      expect(result.networkPreference.isAnyNetwork, true);
      expect(result.batteryPreference.isAny, true);
    });

    test('should handle repository errors', () async {
      // Arrange
      when(() => mockRepository.getSyncConfig())
          .thenThrow(Exception('Repository error'));

      // Act & Assert
      expect(() => useCase(), throwsA(isA<Exception>()));
    });
  });
}
