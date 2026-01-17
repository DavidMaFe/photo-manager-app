import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/sync_device_local_data_source.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockDeviceInfoPlugin extends Mock implements DeviceInfoPlugin {}
class MockAndroidDeviceInfo extends Mock implements AndroidDeviceInfo {}
class MockIosDeviceInfo extends Mock implements IosDeviceInfo {}
class MockAndroidBuildVersion extends Mock implements AndroidBuildVersion {}

void main() {
  late SyncDeviceLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;
  late MockDeviceInfoPlugin mockDeviceInfo;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockDeviceInfo = MockDeviceInfoPlugin();
    dataSource = SyncDeviceLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
      deviceInfo: mockDeviceInfo,
    );
  });

  group('getDeviceUuid', () {
    test('should return saved UUID when exists', () async {
      // Arrange
      const savedUuid = 'existing-uuid-123';
      when(() => mockSharedPreferences.getString('DEVICE_UUID'))
          .thenReturn(savedUuid);

      // Act
      final result = await dataSource.getDeviceUuid();

      // Assert
      expect(result, savedUuid);
      verify(() => mockSharedPreferences.getString('DEVICE_UUID')).called(1);
      verifyNever(() => mockSharedPreferences.setString(any(), any()));
    });

    test('should generate and save new UUID when not exists', () async {
      // Arrange
      when(() => mockSharedPreferences.getString('DEVICE_UUID'))
          .thenReturn(null);
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      final result = await dataSource.getDeviceUuid();

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, 36); // UUID v4 format length
      verify(() => mockSharedPreferences.getString('DEVICE_UUID')).called(1);
      verify(() => mockSharedPreferences.setString('DEVICE_UUID', result)).called(1);
    });

    test('should generate and save new UUID when saved UUID is empty', () async {
      // Arrange
      when(() => mockSharedPreferences.getString('DEVICE_UUID'))
          .thenReturn('');
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      final result = await dataSource.getDeviceUuid();

      // Assert
      expect(result, isNotEmpty);
      verify(() => mockSharedPreferences.setString('DEVICE_UUID', result)).called(1);
    });
  });

  group('saveDeviceUuid', () {
    test('should save UUID to SharedPreferences', () async {
      // Arrange
      const uuid = 'test-uuid-456';
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.saveDeviceUuid(uuid);

      // Assert
      verify(() => mockSharedPreferences.setString('DEVICE_UUID', uuid)).called(1);
    });
  });
}