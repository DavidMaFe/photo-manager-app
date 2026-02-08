import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/devices/data/data_sources/device_remote_data_source.dart';
import 'package:photo_manager_app/features/devices/data/models/device_model.dart';
import 'package:photo_manager_app/features/devices/data/repositories/device_data_repository.dart';
import 'package:photo_manager_app/features/devices/domain/entities/device.dart';
import '../../../../fixtures/test_data.dart';

class MockDeviceRemoteDataSource extends Mock
    implements DeviceRemoteDataSource {}

void main() {
  late DeviceDataRepository repository;
  late MockDeviceRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockDeviceRemoteDataSource();
    repository = DeviceDataRepository(remoteDataSource: mockRemoteDataSource);
  });

  group('DeviceDataRepository', () {
    group('getUserDevices', () {
      test('should delegate to remote data source', () async {
        // Arrange
        final testDevices = TestDeviceEntities.deviceList
            .map((device) => DeviceModel.fromEntity(device))
            .toList();

        when(() => mockRemoteDataSource.getUserDevices())
            .thenAnswer((_) async => testDevices);

        // Act
        final result = await repository.getUserDevices();

        // Assert
        expect(result.length, testDevices.length);
        verify(() => mockRemoteDataSource.getUserDevices()).called(1);
      });

      test('should return entities from data source', () async {
        // Arrange
        final testDevices = TestDeviceEntities.deviceList
            .map((device) => DeviceModel.fromEntity(device))
            .toList();

        when(() => mockRemoteDataSource.getUserDevices())
            .thenAnswer((_) async => testDevices);

        // Act
        final result = await repository.getUserDevices();

        // Assert
        expect(result, isA<List<Device>>());
        expect(result.length, testDevices.length);
        expect(result[0].id, testDevices[0].id);
        expect(result[0].name, testDevices[0].name);
      });

      test('should return empty list when no devices exist', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserDevices())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getUserDevices();

        // Assert
        expect(result, isEmpty);
      });

      test('should propagate exception from data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserDevices())
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getUserDevices(),
          throwsException,
        );
      });
    });

    group('renameDevice', () {
      const testDeviceId = '1';
      const testNewName = 'My New Device';

      test('should delegate to remote data source with correct parameters',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.renameDevice(
              deviceId: any(named: 'deviceId'),
              newName: any(named: 'newName'),
            )).thenAnswer((_) async => Future.value());

        // Act
        await repository.renameDevice(
          deviceId: testDeviceId,
          newName: testNewName,
        );

        // Assert
        verify(() => mockRemoteDataSource.renameDevice(
              deviceId: testDeviceId,
              newName: testNewName,
            )).called(1);
      });

      test('should complete successfully when data source succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.renameDevice(
              deviceId: any(named: 'deviceId'),
              newName: any(named: 'newName'),
            )).thenAnswer((_) async => Future.value());

        // Act & Assert
        await expectLater(
          repository.renameDevice(
            deviceId: testDeviceId,
            newName: testNewName,
          ),
          completes,
        );
      });

      test('should propagate exception from data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.renameDevice(
              deviceId: any(named: 'deviceId'),
              newName: any(named: 'newName'),
            )).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.renameDevice(
            deviceId: testDeviceId,
            newName: testNewName,
          ),
          throwsException,
        );
      });
    });

    group('toggleAutoSync', () {
      const testDeviceId = '1';

      test('should delegate to remote data source when enabling', () async {
        // Arrange
        when(() => mockRemoteDataSource.toggleAutoSync(
              deviceId: any(named: 'deviceId'),
              enabled: any(named: 'enabled'),
            )).thenAnswer((_) async => Future.value());

        // Act
        await repository.toggleAutoSync(
          deviceId: testDeviceId,
          enabled: true,
        );

        // Assert
        verify(() => mockRemoteDataSource.toggleAutoSync(
              deviceId: testDeviceId,
              enabled: true,
            )).called(1);
      });

      test('should delegate to remote data source when disabling', () async {
        // Arrange
        when(() => mockRemoteDataSource.toggleAutoSync(
              deviceId: any(named: 'deviceId'),
              enabled: any(named: 'enabled'),
            )).thenAnswer((_) async => Future.value());

        // Act
        await repository.toggleAutoSync(
          deviceId: testDeviceId,
          enabled: false,
        );

        // Assert
        verify(() => mockRemoteDataSource.toggleAutoSync(
              deviceId: testDeviceId,
              enabled: false,
            )).called(1);
      });

      test('should complete successfully when data source succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.toggleAutoSync(
              deviceId: any(named: 'deviceId'),
              enabled: any(named: 'enabled'),
            )).thenAnswer((_) async => Future.value());

        // Act & Assert
        await expectLater(
          repository.toggleAutoSync(
            deviceId: testDeviceId,
            enabled: true,
          ),
          completes,
        );
      });

      test('should propagate exception from data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.toggleAutoSync(
              deviceId: any(named: 'deviceId'),
              enabled: any(named: 'enabled'),
            )).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.toggleAutoSync(
            deviceId: testDeviceId,
            enabled: true,
          ),
          throwsException,
        );
      });
    });

    group('unlinkDevice', () {
      const testDeviceId = '1';

      test('should delegate to remote data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.unlinkDevice(
              deviceId: any(named: 'deviceId'),
            )).thenAnswer((_) async => Future.value());

        // Act
        await repository.unlinkDevice(deviceId: testDeviceId);

        // Assert
        verify(() => mockRemoteDataSource.unlinkDevice(
              deviceId: testDeviceId,
            )).called(1);
      });

      test('should complete successfully when data source succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.unlinkDevice(
              deviceId: any(named: 'deviceId'),
            )).thenAnswer((_) async => Future.value());

        // Act & Assert
        await expectLater(
          repository.unlinkDevice(deviceId: testDeviceId),
          completes,
        );
      });

      test('should propagate exception from data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.unlinkDevice(
              deviceId: any(named: 'deviceId'),
            )).thenThrow(Exception('Device not found'));

        // Act & Assert
        expect(
          () => repository.unlinkDevice(deviceId: testDeviceId),
          throwsException,
        );
      });
    });
  });
}
