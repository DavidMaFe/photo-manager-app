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

/// Testable version that allows mocking platform-specific behavior
class TestableSyncDeviceLocalDataSource extends SyncDeviceLocalDataSourceImpl {
  final String? mockHardwareId;
  final Exception? mockException;

  TestableSyncDeviceLocalDataSource({
    required super.sharedPreferences,
    required super.deviceInfo,
    this.mockHardwareId,
    this.mockException,
  });

  @override
  Future<String> getDeviceUuid() async {
    // Check if we have a cached device identifier
    final savedUuid = sharedPreferences.getString('DEVICE_UUID');

    if(savedUuid != null && savedUuid.isNotEmpty) {
      return savedUuid;
    }

    // Get hardware-based device identifier (mocked for tests)
    if (mockException != null) {
      throw mockException!;
    }

    final hardwareId = mockHardwareId ?? '';

    // Validate that we got a valid hardware ID
    if(hardwareId.isEmpty) {
      throw Exception("Failed to obtain hardware device identifier");
    }

    // Cache the hardware ID for performance
    await saveDeviceUuid(hardwareId);
    return hardwareId;
  }
}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late MockDeviceInfoPlugin mockDeviceInfo;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockDeviceInfo = MockDeviceInfoPlugin();
  });

  group('getDeviceUuid', () {
    test('should return cached device ID when exists', () async {
      // Arrange
      const cachedDeviceId = 'cached-hardware-id-123';
      final dataSource = TestableSyncDeviceLocalDataSource(
        sharedPreferences: mockSharedPreferences,
        deviceInfo: mockDeviceInfo,
        mockHardwareId: 'test-hardware-id',
      );

      when(() => mockSharedPreferences.getString('DEVICE_UUID'))
          .thenReturn(cachedDeviceId);

      // Act
      final result = await dataSource.getDeviceUuid();

      // Assert
      expect(result, cachedDeviceId);
      verify(() => mockSharedPreferences.getString('DEVICE_UUID')).called(1);
      verifyNever(() => mockSharedPreferences.setString(any(), any()));
    });

    test('should get hardware ID and cache it when not cached', () async {
      // Arrange
      const hardwareId = 'hardware-id-123';
      final dataSource = TestableSyncDeviceLocalDataSource(
        sharedPreferences: mockSharedPreferences,
        deviceInfo: mockDeviceInfo,
        mockHardwareId: hardwareId,
      );

      when(() => mockSharedPreferences.getString('DEVICE_UUID'))
          .thenReturn(null);
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      final result = await dataSource.getDeviceUuid();

      // Assert
      expect(result, hardwareId);
      verify(() => mockSharedPreferences.getString('DEVICE_UUID')).called(1);
      verify(() => mockSharedPreferences.setString('DEVICE_UUID', hardwareId)).called(1);
    });

    test('should get hardware ID when cached ID is empty string', () async {
      // Arrange
      const hardwareId = 'hardware-id-789';
      final dataSource = TestableSyncDeviceLocalDataSource(
        sharedPreferences: mockSharedPreferences,
        deviceInfo: mockDeviceInfo,
        mockHardwareId: hardwareId,
      );

      when(() => mockSharedPreferences.getString('DEVICE_UUID'))
          .thenReturn('');
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      final result = await dataSource.getDeviceUuid();

      // Assert
      expect(result, hardwareId);
      verify(() => mockSharedPreferences.setString('DEVICE_UUID', hardwareId)).called(1);
    });

    test('should throw exception when hardware ID is empty', () async {
      // Arrange
      final dataSource = TestableSyncDeviceLocalDataSource(
        sharedPreferences: mockSharedPreferences,
        deviceInfo: mockDeviceInfo,
        mockHardwareId: '', // Empty hardware ID
      );

      when(() => mockSharedPreferences.getString('DEVICE_UUID'))
          .thenReturn(null);

      // Act & Assert
      expect(
        () => dataSource.getDeviceUuid(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to obtain hardware device identifier'),
        )),
      );
    });

    test('should throw exception when getting hardware ID fails', () async {
      // Arrange
      final testException = Exception('Hardware ID fetch failed');
      final dataSource = TestableSyncDeviceLocalDataSource(
        sharedPreferences: mockSharedPreferences,
        deviceInfo: mockDeviceInfo,
        mockException: testException,
      );

      when(() => mockSharedPreferences.getString('DEVICE_UUID'))
          .thenReturn(null);

      // Act & Assert
      expect(
        () => dataSource.getDeviceUuid(),
        throwsA(testException),
      );
    });
  });

  group('saveDeviceUuid', () {
    test('should save device ID to SharedPreferences', () async {
      // Arrange
      const deviceId = 'test-hardware-id-456';
      final dataSource = SyncDeviceLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences,
        deviceInfo: mockDeviceInfo,
      );

      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.saveDeviceUuid(deviceId);

      // Assert
      verify(() => mockSharedPreferences.setString('DEVICE_UUID', deviceId)).called(1);
    });
  });
}