import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_device.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/register_sync_device_use_case.dart';

class MockSyncDeviceRepository extends Mock implements SyncDeviceRepository {}

void main() {
  late RegisterSyncDeviceUseCase useCase;
  late MockSyncDeviceRepository mockRepository;

  setUp(() {
    mockRepository = MockSyncDeviceRepository();
    useCase = RegisterSyncDeviceUseCase(mockRepository);
  });

  group('RegisterSyncDeviceUseCase', () {
    const uuid = 'device_uuid_123';
    const name = 'Samsung Galaxy S21';
    const model = 'SM-G991B';
    const osType = 'Android';
    const osVersion = '13';
    const appVersion = '1.0.0';
    const pushToken = 'push_token_456';

    final syncDevice = SyncDevice(
      id: 'device_123',
      uuid: uuid,
      name: name,
      model: model,
      osType: 'ANDROID',
      osVersion: osVersion,
      appVersion: appVersion,
      userId: 'user_789',
    );

    test('should call repository with correct parameters', () async {
      // Arrange
      when(() => mockRepository.registerDevice(
            uuid: any(named: 'uuid'),
            name: any(named: 'name'),
            model: any(named: 'model'),
            osType: any(named: 'osType'),
            osVersion: any(named: 'osVersion'),
            appVersion: any(named: 'appVersion'),
            pushToken: any(named: 'pushToken'),
          )).thenAnswer((_) async => syncDevice);

      // Act
      await useCase(
        uuid: uuid,
        name: name,
        model: model,
        osType: osType,
        osVersion: osVersion,
        appVersion: appVersion,
        pushToken: pushToken,
      );

      // Assert
      verify(() => mockRepository.registerDevice(
            uuid: uuid,
            name: name,
            model: model,
            osType: 'ANDROID',
            osVersion: osVersion,
            appVersion: appVersion,
            pushToken: pushToken,
          )).called(1);
    });

    test('should return sync device from repository', () async {
      // Arrange
      when(() => mockRepository.registerDevice(
            uuid: any(named: 'uuid'),
            name: any(named: 'name'),
            model: any(named: 'model'),
            osType: any(named: 'osType'),
            osVersion: any(named: 'osVersion'),
            appVersion: any(named: 'appVersion'),
            pushToken: any(named: 'pushToken'),
          )).thenAnswer((_) async => syncDevice);

      // Act
      final result = await useCase(
        uuid: uuid,
        name: name,
        model: model,
        osType: osType,
        osVersion: osVersion,
        appVersion: appVersion,
      );

      // Assert
      expect(result, syncDevice);
      expect(result.uuid, uuid);
      expect(result.name, name);
    });

    test('should normalize Android OS type to ANDROID', () async {
      // Arrange
      when(() => mockRepository.registerDevice(
            uuid: any(named: 'uuid'),
            name: any(named: 'name'),
            model: any(named: 'model'),
            osType: any(named: 'osType'),
            osVersion: any(named: 'osVersion'),
            appVersion: any(named: 'appVersion'),
            pushToken: any(named: 'pushToken'),
          )).thenAnswer((_) async => syncDevice);

      // Act
      await useCase(
        uuid: uuid,
        name: name,
        model: model,
        osType: 'android',
        osVersion: osVersion,
        appVersion: appVersion,
      );

      // Assert
      verify(() => mockRepository.registerDevice(
            uuid: uuid,
            name: name,
            model: model,
            osType: 'ANDROID',
            osVersion: osVersion,
            appVersion: appVersion,
            pushToken: null,
          )).called(1);
    });

    test('should normalize iOS OS type to IOS', () async {
      // Arrange
      final iosDevice = SyncDevice(
        id: 'device_456',
        uuid: uuid,
        name: 'iPhone 13',
        model: 'iPhone14,3',
        osType: 'IOS',
        osVersion: '16.0',
        appVersion: appVersion,
        userId: 'user_789',
      );
      when(() => mockRepository.registerDevice(
            uuid: any(named: 'uuid'),
            name: any(named: 'name'),
            model: any(named: 'model'),
            osType: any(named: 'osType'),
            osVersion: any(named: 'osVersion'),
            appVersion: any(named: 'appVersion'),
            pushToken: any(named: 'pushToken'),
          )).thenAnswer((_) async => iosDevice);

      // Act
      await useCase(
        uuid: uuid,
        name: 'iPhone 13',
        model: 'iPhone14,3',
        osType: 'iOS',
        osVersion: '16.0',
        appVersion: appVersion,
      );

      // Assert
      verify(() => mockRepository.registerDevice(
            uuid: uuid,
            name: 'iPhone 13',
            model: 'iPhone14,3',
            osType: 'IOS',
            osVersion: '16.0',
            appVersion: appVersion,
            pushToken: null,
          )).called(1);
    });

    test('should throw exception when uuid is empty', () async {
      // Act & Assert
      expect(
        () => useCase(
          uuid: '',
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid or empty device UUID'),
        )),
      );
    });

    test('should throw exception when name is empty', () async {
      // Act & Assert
      expect(
        () => useCase(
          uuid: uuid,
          name: '',
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid or empty device name'),
        )),
      );
    });

    test('should throw exception when model is empty', () async {
      // Act & Assert
      expect(
        () => useCase(
          uuid: uuid,
          name: name,
          model: '',
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid or empty device model'),
        )),
      );
    });

    test('should throw exception for invalid OS type', () async {
      // Act & Assert
      expect(
        () => useCase(
          uuid: uuid,
          name: name,
          model: model,
          osType: 'Windows',
          osVersion: osVersion,
          appVersion: appVersion,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid OS type'),
        )),
      );
    });

    test('should throw exception when OS version is empty', () async {
      // Act & Assert
      expect(
        () => useCase(
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: '',
          appVersion: appVersion,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid or empty OS version'),
        )),
      );
    });

    test('should throw exception when app version is empty', () async {
      // Act & Assert
      expect(
        () => useCase(
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: '',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid or empty APP version'),
        )),
      );
    });

    test('should trim all string parameters before calling repository', () async {
      // Arrange
      when(() => mockRepository.registerDevice(
            uuid: any(named: 'uuid'),
            name: any(named: 'name'),
            model: any(named: 'model'),
            osType: any(named: 'osType'),
            osVersion: any(named: 'osVersion'),
            appVersion: any(named: 'appVersion'),
            pushToken: any(named: 'pushToken'),
          )).thenAnswer((_) async => syncDevice);

      // Act
      await useCase(
        uuid: '  $uuid  ',
        name: '  $name  ',
        model: '  $model  ',
        osType: '  $osType  ',
        osVersion: '  $osVersion  ',
        appVersion: '  $appVersion  ',
        pushToken: '  $pushToken  ',
      );

      // Assert
      verify(() => mockRepository.registerDevice(
            uuid: uuid,
            name: name,
            model: model,
            osType: 'ANDROID',
            osVersion: osVersion,
            appVersion: appVersion,
            pushToken: pushToken,
          )).called(1);
    });

    test('should handle null push token', () async {
      // Arrange
      when(() => mockRepository.registerDevice(
            uuid: any(named: 'uuid'),
            name: any(named: 'name'),
            model: any(named: 'model'),
            osType: any(named: 'osType'),
            osVersion: any(named: 'osVersion'),
            appVersion: any(named: 'appVersion'),
            pushToken: any(named: 'pushToken'),
          )).thenAnswer((_) async => syncDevice);

      // Act
      await useCase(
        uuid: uuid,
        name: name,
        model: model,
        osType: osType,
        osVersion: osVersion,
        appVersion: appVersion,
        pushToken: null,
      );

      // Assert
      verify(() => mockRepository.registerDevice(
            uuid: uuid,
            name: name,
            model: model,
            osType: 'ANDROID',
            osVersion: osVersion,
            appVersion: appVersion,
            pushToken: null,
          )).called(1);
    });

    test('should propagate exception from repository', () async {
      // Arrange
      when(() => mockRepository.registerDevice(
            uuid: any(named: 'uuid'),
            name: any(named: 'name'),
            model: any(named: 'model'),
            osType: any(named: 'osType'),
            osVersion: any(named: 'osVersion'),
            appVersion: any(named: 'appVersion'),
            pushToken: any(named: 'pushToken'),
          )).thenThrow(Exception('Device already registered'));

      // Act & Assert
      expect(
        () => useCase(
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Device already registered'),
        )),
      );
    });
  });
}