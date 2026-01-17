import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/sync_device_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/remote/sync_device_remote_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_device_model.dart';
import 'package:photo_manager_app/features/sync_session/data/repositories/sync_device_repository_impl.dart';

class MockSyncDeviceRemoteDataSource extends Mock implements SyncDeviceRemoteDataSource {}
class MockSyncDeviceLocalDataSource extends Mock implements SyncDeviceLocalDataSource {}

void main() {
  late SyncDeviceRepositoryImpl repository;
  late MockSyncDeviceRemoteDataSource mockRemoteDataSource;
  late MockSyncDeviceLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockSyncDeviceRemoteDataSource();
    mockLocalDataSource = MockSyncDeviceLocalDataSource();
    repository = SyncDeviceRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('registerDevice', () {
    const uuid = 'device-uuid-123';
    const name = 'Samsung Galaxy S21';
    const model = 'SM-G991B';
    const osType = 'ANDROID';
    const osVersion = '13';
    const appVersion = '1.0.0';
    const pushToken = 'push-token-456';

    final syncDeviceModel = SyncDeviceModel(
      id: 'device-123',
      uuid: uuid,
      name: name,
      model: model,
      osType: osType,
      osVersion: osVersion,
      appVersion: appVersion,
      userId: 'user-789',
    );

    test('should call remote data source with all parameters', () async {
      // Arrange
      when(() => mockRemoteDataSource.registerDevice(
            uuid: any(named: 'uuid'),
            name: any(named: 'name'),
            model: any(named: 'model'),
            osType: any(named: 'osType'),
            osVersion: any(named: 'osVersion'),
            appVersion: any(named: 'appVersion'),
            pushToken: any(named: 'pushToken'),
          )).thenAnswer((_) async => syncDeviceModel);

      // Act
      await repository.registerDevice(
        uuid: uuid,
        name: name,
        model: model,
        osType: osType,
        osVersion: osVersion,
        appVersion: appVersion,
        pushToken: pushToken,
      );

      // Assert
      verify(() => mockRemoteDataSource.registerDevice(
            uuid: uuid,
            name: name,
            model: model,
            osType: osType,
            osVersion: osVersion,
            appVersion: appVersion,
            pushToken: pushToken,
          )).called(1);
    });

    test('should return SyncDevice entity from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.registerDevice(
            uuid: any(named: 'uuid'),
            name: any(named: 'name'),
            model: any(named: 'model'),
            osType: any(named: 'osType'),
            osVersion: any(named: 'osVersion'),
            appVersion: any(named: 'appVersion'),
            pushToken: any(named: 'pushToken'),
          )).thenAnswer((_) async => syncDeviceModel);

      // Act
      final result = await repository.registerDevice(
        uuid: uuid,
        name: name,
        model: model,
        osType: osType,
        osVersion: osVersion,
        appVersion: appVersion,
        pushToken: pushToken,
      );

      // Assert
      expect(result.id, syncDeviceModel.id);
      expect(result.uuid, syncDeviceModel.uuid);
      expect(result.name, syncDeviceModel.name);
      expect(result.model, syncDeviceModel.model);
    });

    test('should handle null push token', () async {
      // Arrange
      when(() => mockRemoteDataSource.registerDevice(
            uuid: any(named: 'uuid'),
            name: any(named: 'name'),
            model: any(named: 'model'),
            osType: any(named: 'osType'),
            osVersion: any(named: 'osVersion'),
            appVersion: any(named: 'appVersion'),
            pushToken: any(named: 'pushToken'),
          )).thenAnswer((_) async => syncDeviceModel);

      // Act
      await repository.registerDevice(
        uuid: uuid,
        name: name,
        model: model,
        osType: osType,
        osVersion: osVersion,
        appVersion: appVersion,
        pushToken: null,
      );

      // Assert
      verify(() => mockRemoteDataSource.registerDevice(
            uuid: uuid,
            name: name,
            model: model,
            osType: osType,
            osVersion: osVersion,
            appVersion: appVersion,
            pushToken: null,
          )).called(1);
    });

    test('should propagate exception from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.registerDevice(
            uuid: any(named: 'uuid'),
            name: any(named: 'name'),
            model: any(named: 'model'),
            osType: any(named: 'osType'),
            osVersion: any(named: 'osVersion'),
            appVersion: any(named: 'appVersion'),
            pushToken: any(named: 'pushToken'),
          )).thenThrow(Exception('Registration failed'));

      // Act & Assert
      expect(
        () => repository.registerDevice(
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getCurrentDeviceInfo', () {
    final deviceInfo = SyncDeviceModel(
      id: '',
      uuid: 'device-uuid-123',
      name: 'Samsung Galaxy S21',
      model: 'SM-G991B',
      osType: 'ANDROID',
      osVersion: '13',
      appVersion: '1.0.0',
      userId: '',
    );

    test('should call local data source', () async {
      // Arrange
      when(() => mockLocalDataSource.getCurrentDeviceInfo())
          .thenAnswer((_) async => deviceInfo);

      // Act
      await repository.getCurrentDeviceInfo();

      // Assert
      verify(() => mockLocalDataSource.getCurrentDeviceInfo()).called(1);
    });

    test('should return device info from local data source', () async {
      // Arrange
      when(() => mockLocalDataSource.getCurrentDeviceInfo())
          .thenAnswer((_) async => deviceInfo);

      // Act
      final result = await repository.getCurrentDeviceInfo();

      // Assert
      expect(result.uuid, deviceInfo.uuid);
      expect(result.name, deviceInfo.name);
      expect(result.model, deviceInfo.model);
      expect(result.osType, deviceInfo.osType);
    });

    test('should propagate exception from local data source', () async {
      // Arrange
      when(() => mockLocalDataSource.getCurrentDeviceInfo())
          .thenThrow(Exception('Failed to get device info'));

      // Act & Assert
      expect(
        () => repository.getCurrentDeviceInfo(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getDeviceUuid', () {
    const deviceUuid = 'device-uuid-123';

    test('should call local data source', () async {
      // Arrange
      when(() => mockLocalDataSource.getDeviceUuid())
          .thenAnswer((_) async => deviceUuid);

      // Act
      await repository.getDeviceUuid();

      // Assert
      verify(() => mockLocalDataSource.getDeviceUuid()).called(1);
    });

    test('should return device UUID from local data source', () async {
      // Arrange
      when(() => mockLocalDataSource.getDeviceUuid())
          .thenAnswer((_) async => deviceUuid);

      // Act
      final result = await repository.getDeviceUuid();

      // Assert
      expect(result, deviceUuid);
    });

    test('should propagate exception from local data source', () async {
      // Arrange
      when(() => mockLocalDataSource.getDeviceUuid())
          .thenThrow(Exception('Failed to get UUID'));

      // Act & Assert
      expect(
        () => repository.getDeviceUuid(),
        throwsA(isA<Exception>()),
      );
    });
  });
}