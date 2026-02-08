import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/devices/data/models/device_model.dart';
import 'package:photo_manager_app/features/devices/domain/entities/device.dart';
import '../../../../fixtures/test_data.dart';

void main() {
  group('DeviceModel', () {
    group('fromJson', () {
      test('should create DeviceModel from JSON with all fields', () {
        // Arrange
        final json = TestDeviceJsonData.androidDeviceJson;

        // Act
        final result = DeviceModel.fromJson(json);

        // Assert
        expect(result.id, '1');
        expect(result.uuid, 'android-uuid-001');
        expect(result.name, 'Samsung Galaxy S21');
        expect(result.model, 'SM-G991B');
        expect(result.osType, 'Android');
        expect(result.osVersion, '13');
        expect(result.appVersion, '1.0.0');
        expect(result.autoSync, true);
      });

      test('should convert integer deviceId to string', () {
        // Arrange
        final json = TestDeviceJsonData.deviceJsonWithIntegerId;

        // Act
        final result = DeviceModel.fromJson(json);

        // Assert
        expect(result.id, '123');
        expect(result.id, isA<String>());
      });

      test('should default autoSync to false when not provided', () {
        // Arrange
        final json = TestDeviceJsonData.deviceJsonWithoutAutoSync;

        // Act
        final result = DeviceModel.fromJson(json);

        // Assert
        expect(result.autoSync, false);
      });

      test('should handle autoSyncEnabled false', () {
        // Arrange
        final json = TestDeviceJsonData.iosDeviceJson;

        // Act
        final result = DeviceModel.fromJson(json);

        // Assert
        expect(result.autoSync, false);
      });

      test('should create iOS device from JSON', () {
        // Arrange
        final json = TestDeviceJsonData.iosDeviceJson;

        // Act
        final result = DeviceModel.fromJson(json);

        // Assert
        expect(result.id, '2');
        expect(result.osType, 'iOS');
        expect(result.name, 'iPhone 13 Pro');
        expect(result.autoSync, false);
      });
    });

    group('toJson', () {
      test('should convert DeviceModel to JSON', () {
        // Arrange
        final device = DeviceModel(
          id: '1',
          uuid: 'test-uuid',
          name: 'Test Device',
          model: 'TEST-001',
          osType: 'Android',
          osVersion: '13',
          appVersion: '1.0.0',
          autoSync: true,
        );

        // Act
        final result = device.toJson();

        // Assert
        expect(result['id'], '1');
        expect(result['uuid'], 'test-uuid');
        expect(result['name'], 'Test Device');
        expect(result['model'], 'TEST-001');
        expect(result['osType'], 'Android');
        expect(result['osVersion'], '13');
        expect(result['appVersion'], '1.0.0');
        expect(result['autoSync'], true);
      });

      test('should handle autoSync false', () {
        // Arrange
        final device = DeviceModel(
          id: '2',
          uuid: 'test-uuid-2',
          name: 'Test Device 2',
          model: 'TEST-002',
          osType: 'iOS',
          osVersion: '16.0',
          appVersion: '1.0.0',
          autoSync: false,
        );

        // Act
        final result = device.toJson();

        // Assert
        expect(result['autoSync'], false);
      });
    });

    group('fromEntity', () {
      test('should create DeviceModel from Device entity', () {
        // Arrange
        final device = TestDeviceEntities.androidDevice;

        // Act
        final result = DeviceModel.fromEntity(device);

        // Assert
        expect(result.id, device.id);
        expect(result.uuid, device.uuid);
        expect(result.name, device.name);
        expect(result.model, device.model);
        expect(result.osType, device.osType);
        expect(result.osVersion, device.osVersion);
        expect(result.appVersion, device.appVersion);
        expect(result.autoSync, device.autoSync);
        expect(result, isA<DeviceModel>());
        expect(result, isA<Device>());
      });

      test('should preserve all properties when converting from entity', () {
        // Arrange
        final device = TestDeviceEntities.iosDevice;

        // Act
        final result = DeviceModel.fromEntity(device);

        // Assert
        expect(result.id, device.id);
        expect(result.autoSync, device.autoSync);
        expect(result.isIOS, device.isIOS);
      });
    });

    group('inheritance', () {
      test('should extend Device entity', () {
        // Arrange
        final model = DeviceModel(
          id: '1',
          uuid: 'test-uuid',
          name: 'Test',
          model: 'TEST',
          osType: 'Android',
          osVersion: '13',
          appVersion: '1.0.0',
          autoSync: true,
        );

        // Act & Assert
        expect(model, isA<Device>());
      });

      test('should have access to Device getters', () {
        // Arrange
        final androidModel = DeviceModel(
          id: '1',
          uuid: 'test-uuid',
          name: 'Android Phone',
          model: 'TEST',
          osType: 'Android',
          osVersion: '13',
          appVersion: '1.0.0',
          autoSync: true,
        );

        final iosModel = DeviceModel(
          id: '2',
          uuid: 'test-uuid-2',
          name: 'iPhone',
          model: 'TEST',
          osType: 'iOS',
          osVersion: '16.0',
          appVersion: '1.0.0',
          autoSync: false,
        );

        // Act & Assert
        expect(androidModel.isAndroid, true);
        expect(androidModel.isIOS, false);
        expect(iosModel.isAndroid, false);
        expect(iosModel.isIOS, true);
      });
    });

    group('JSON serialization round trip', () {
      test('should maintain data integrity through fromJson -> toJson cycle',
          () {
        // Arrange
        final originalJson = TestDeviceJsonData.androidDeviceJson;

        // Act
        final model = DeviceModel.fromJson(originalJson);
        final resultJson = model.toJson();

        // Assert
        // Note: toJson uses 'id' while fromJson expects 'deviceId'
        // and toJson uses 'autoSync' while fromJson expects 'autoSyncEnabled'
        expect(resultJson['id'], originalJson['deviceId'].toString());
        expect(resultJson['uuid'], originalJson['uuid']);
        expect(resultJson['name'], originalJson['name']);
        expect(resultJson['model'], originalJson['model']);
        expect(resultJson['osType'], originalJson['osType']);
        expect(resultJson['osVersion'], originalJson['osVersion']);
        expect(resultJson['appVersion'], originalJson['appVersion']);
        expect(resultJson['autoSync'], originalJson['autoSyncEnabled']);
      });
    });
  });
}
