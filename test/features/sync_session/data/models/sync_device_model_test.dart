import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_device_model.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_device.dart';

void main() {
  group('SyncDeviceModel', () {
    const id = 'device_123';
    const uuid = 'uuid_456';
    const name = 'Samsung Galaxy S21';
    const model = 'SM-G991B';
    const osType = 'ANDROID';
    const osVersion = '13';
    const appVersion = '1.0.0';
    const userId = 'user_789';
    const pushToken = 'push_token_abc';

    test('should be a subclass of SyncDevice entity', () {
      // Arrange
      final deviceModel = SyncDeviceModel(
        id: id,
        uuid: uuid,
        name: name,
        model: model,
        osType: osType,
        osVersion: osVersion,
        appVersion: appVersion,
        userId: userId,
      );

      // Assert
      expect(deviceModel, isA<SyncDevice>());
    });

    group('fromJson', () {
      test('should create model from JSON with all fields', () {
        // Arrange
        final json = {
          'id': id,
          'uuid': uuid,
          'name': name,
          'model': model,
          'osType': osType,
          'osVersion': osVersion,
          'appVersion': appVersion,
          'userId': userId,
        };

        // Act
        final deviceModel = SyncDeviceModel.fromJson(json);

        // Assert
        expect(deviceModel.id, id);
        expect(deviceModel.uuid, uuid);
        expect(deviceModel.name, name);
        expect(deviceModel.model, model);
        expect(deviceModel.osType, osType);
        expect(deviceModel.osVersion, osVersion);
        expect(deviceModel.appVersion, appVersion);
        expect(deviceModel.userId, userId);
      });

      test('should convert id to string when it is an integer', () {
        // Arrange
        final json = {
          'id': 123,
          'uuid': uuid,
          'name': name,
          'model': model,
          'osType': osType,
          'osVersion': osVersion,
          'appVersion': appVersion,
          'userId': 789,
        };

        // Act
        final deviceModel = SyncDeviceModel.fromJson(json);

        // Assert
        expect(deviceModel.id, '123');
        expect(deviceModel.userId, '789');
      });
    });

    group('toJson', () {
      test('should convert model to JSON with all fields', () {
        // Arrange
        final deviceModel = SyncDeviceModel(
          id: id,
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
          userId: userId,
        );

        // Act
        final json = deviceModel.toJson();

        // Assert
        expect(json['id'], id);
        expect(json['uuid'], uuid);
        expect(json['name'], name);
        expect(json['model'], model);
        expect(json['osType'], osType);
        expect(json['osVersion'], osVersion);
        expect(json['appVersion'], appVersion);
        expect(json['userId'], userId);
      });
    });

    group('fromRegistrationResponse', () {
      test('should create model from registration response parameters', () {
        // Act
        final deviceModel = SyncDeviceModel.fromRegistrationResponse(
          id: id,
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
          userId: userId,
        );

        // Assert
        expect(deviceModel.id, id);
        expect(deviceModel.uuid, uuid);
        expect(deviceModel.name, name);
        expect(deviceModel.model, model);
        expect(deviceModel.osType, osType);
        expect(deviceModel.osVersion, osVersion);
        expect(deviceModel.appVersion, appVersion);
        expect(deviceModel.userId, userId);
      });
    });

    group('parseDeviceIdFromJson', () {
      test('should extract device ID from JSON', () {
        // Arrange
        final json = {'deviceId': 'device_999'};

        // Act
        final deviceId = SyncDeviceModel.parseDeviceIdFromJson(json);

        // Assert
        expect(deviceId, 'device_999');
      });

      test('should convert device ID to string when it is an integer', () {
        // Arrange
        final json = {'deviceId': 999};

        // Act
        final deviceId = SyncDeviceModel.parseDeviceIdFromJson(json);

        // Assert
        expect(deviceId, '999');
      });
    });

    group('toRequestJson', () {
      test('should convert model to request JSON without push token', () {
        // Arrange
        final deviceModel = SyncDeviceModel(
          id: id,
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
          userId: userId,
        );

        // Act
        final json = deviceModel.toRequestJson();

        // Assert
        expect(json['uuid'], uuid);
        expect(json['name'], name);
        expect(json['model'], model);
        expect(json['osType'], osType);
        expect(json['osVersion'], osVersion);
        expect(json['appVersion'], appVersion);
        expect(json.containsKey('pushToken'), false);
        expect(json.containsKey('id'), false);
        expect(json.containsKey('userId'), false);
      });

      test('should include push token when provided and not empty', () {
        // Arrange
        final deviceModel = SyncDeviceModel(
          id: id,
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
          userId: userId,
        );

        // Act
        final json = deviceModel.toRequestJson(pushToken: pushToken);

        // Assert
        expect(json['pushToken'], pushToken);
      });

      test('should not include push token when null', () {
        // Arrange
        final deviceModel = SyncDeviceModel(
          id: id,
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
          userId: userId,
        );

        // Act
        final json = deviceModel.toRequestJson(pushToken: null);

        // Assert
        expect(json.containsKey('pushToken'), false);
      });

      test('should not include push token when empty string', () {
        // Arrange
        final deviceModel = SyncDeviceModel(
          id: id,
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
          userId: userId,
        );

        // Act
        final json = deviceModel.toRequestJson(pushToken: '');

        // Assert
        expect(json.containsKey('pushToken'), false);
      });
    });

    group('fromEntity', () {
      test('should create model from SyncDevice entity', () {
        // Arrange
        final entity = SyncDevice(
          id: id,
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
          userId: userId,
        );

        // Act
        final deviceModel = SyncDeviceModel.fromEntity(entity);

        // Assert
        expect(deviceModel.id, entity.id);
        expect(deviceModel.uuid, entity.uuid);
        expect(deviceModel.name, entity.name);
        expect(deviceModel.model, entity.model);
        expect(deviceModel.osType, entity.osType);
        expect(deviceModel.osVersion, entity.osVersion);
        expect(deviceModel.appVersion, entity.appVersion);
        expect(deviceModel.userId, entity.userId);
        expect(deviceModel, isA<SyncDeviceModel>());
      });
    });

    group('JSON round-trip', () {
      test('should maintain data integrity through serialization cycle', () {
        // Arrange
        final originalModel = SyncDeviceModel(
          id: id,
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
          userId: userId,
        );

        // Act
        final json = originalModel.toJson();
        final deserializedModel = SyncDeviceModel.fromJson(json);

        // Assert
        expect(deserializedModel.id, originalModel.id);
        expect(deserializedModel.uuid, originalModel.uuid);
        expect(deserializedModel.name, originalModel.name);
        expect(deserializedModel.model, originalModel.model);
        expect(deserializedModel.osType, originalModel.osType);
        expect(deserializedModel.osVersion, originalModel.osVersion);
        expect(deserializedModel.appVersion, originalModel.appVersion);
        expect(deserializedModel.userId, originalModel.userId);
      });
    });
  });
}