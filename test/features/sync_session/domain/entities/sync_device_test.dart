import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_device.dart';

void main() {
  group('SyncDevice Entity', () {
    test('should create sync device with all fields', () {
      // Arrange & Act
      final syncDevice = SyncDevice(
        id: 'device_123',
        uuid: 'uuid_456',
        name: 'Samsung Galaxy S21',
        model: 'SM-G991B',
        osType: 'Android',
        osVersion: '13',
        appVersion: '1.0.0',
        userId: 'user_789',
      );

      // Assert
      expect(syncDevice.id, 'device_123');
      expect(syncDevice.uuid, 'uuid_456');
      expect(syncDevice.name, 'Samsung Galaxy S21');
      expect(syncDevice.model, 'SM-G991B');
      expect(syncDevice.osType, 'Android');
      expect(syncDevice.osVersion, '13');
      expect(syncDevice.appVersion, '1.0.0');
      expect(syncDevice.userId, 'user_789');
    });

    test('should create empty sync device', () {
      // Act
      final syncDevice = SyncDevice.empty();

      // Assert
      expect(syncDevice.id, '');
      expect(syncDevice.uuid, '');
      expect(syncDevice.name, '');
      expect(syncDevice.model, '');
      expect(syncDevice.osType, '');
      expect(syncDevice.osVersion, '');
      expect(syncDevice.appVersion, '');
      expect(syncDevice.userId, '');
    });

    test('isAndroid should return true for Android device', () {
      // Arrange
      final syncDevice = SyncDevice(
        id: 'device_123',
        uuid: 'uuid_456',
        name: 'Samsung Galaxy S21',
        model: 'SM-G991B',
        osType: 'Android',
        osVersion: '13',
        appVersion: '1.0.0',
        userId: 'user_789',
      );

      // Act & Assert
      expect(syncDevice.isAndroid, true);
      expect(syncDevice.isIOS, false);
    });

    test('isAndroid should return true for lowercase android', () {
      // Arrange
      final syncDevice = SyncDevice(
        id: 'device_123',
        uuid: 'uuid_456',
        name: 'Device',
        model: 'Model',
        osType: 'android',
        osVersion: '13',
        appVersion: '1.0.0',
        userId: 'user_789',
      );

      // Act & Assert
      expect(syncDevice.isAndroid, true);
    });

    test('isIOS should return true for iOS device', () {
      // Arrange
      final syncDevice = SyncDevice(
        id: 'device_123',
        uuid: 'uuid_456',
        name: 'iPhone 13 Pro',
        model: 'iPhone14,3',
        osType: 'iOS',
        osVersion: '16.0',
        appVersion: '1.0.0',
        userId: 'user_789',
      );

      // Act & Assert
      expect(syncDevice.isIOS, true);
      expect(syncDevice.isAndroid, false);
    });

    test('isIOS should return true for lowercase ios', () {
      // Arrange
      final syncDevice = SyncDevice(
        id: 'device_123',
        uuid: 'uuid_456',
        name: 'iPhone',
        model: 'Model',
        osType: 'ios',
        osVersion: '16.0',
        appVersion: '1.0.0',
        userId: 'user_789',
      );

      // Act & Assert
      expect(syncDevice.isIOS, true);
    });

    test('copyWith should create new instance with updated fields', () {
      // Arrange
      final syncDevice = SyncDevice(
        id: 'device_123',
        uuid: 'uuid_456',
        name: 'Samsung Galaxy S21',
        model: 'SM-G991B',
        osType: 'Android',
        osVersion: '13',
        appVersion: '1.0.0',
        userId: 'user_789',
      );

      // Act
      final updated = syncDevice.copyWith(
        name: 'Updated Name',
        appVersion: '2.0.0',
      );

      // Assert
      expect(updated.id, syncDevice.id);
      expect(updated.uuid, syncDevice.uuid);
      expect(updated.name, 'Updated Name');
      expect(updated.model, syncDevice.model);
      expect(updated.osType, syncDevice.osType);
      expect(updated.osVersion, syncDevice.osVersion);
      expect(updated.appVersion, '2.0.0');
      expect(updated.userId, syncDevice.userId);
      expect(updated, isNot(same(syncDevice)));
    });

    test('copyWith should keep original values when no parameters provided', () {
      // Arrange
      final syncDevice = SyncDevice(
        id: 'device_123',
        uuid: 'uuid_456',
        name: 'Samsung Galaxy S21',
        model: 'SM-G991B',
        osType: 'Android',
        osVersion: '13',
        appVersion: '1.0.0',
        userId: 'user_789',
      );

      // Act
      final updated = syncDevice.copyWith();

      // Assert
      expect(updated.id, syncDevice.id);
      expect(updated.uuid, syncDevice.uuid);
      expect(updated.name, syncDevice.name);
      expect(updated.model, syncDevice.model);
      expect(updated.osType, syncDevice.osType);
      expect(updated.osVersion, syncDevice.osVersion);
      expect(updated.appVersion, syncDevice.appVersion);
      expect(updated.userId, syncDevice.userId);
      expect(updated, isNot(same(syncDevice)));
    });

    test('equality should be true for same id', () {
      // Arrange
      final syncDevice1 = SyncDevice(
        id: 'device_123',
        uuid: 'uuid_456',
        name: 'Device 1',
        model: 'Model 1',
        osType: 'Android',
        osVersion: '13',
        appVersion: '1.0.0',
        userId: 'user_789',
      );
      final syncDevice2 = SyncDevice(
        id: 'device_123',
        uuid: 'uuid_different',
        name: 'Device 2',
        model: 'Model 2',
        osType: 'iOS',
        osVersion: '16.0',
        appVersion: '2.0.0',
        userId: 'user_different',
      );

      // Act & Assert
      expect(syncDevice1 == syncDevice2, true);
      expect(syncDevice1.hashCode, syncDevice2.hashCode);
    });

    test('equality should be false for different ids', () {
      // Arrange
      final syncDevice1 = SyncDevice(
        id: 'device_123',
        uuid: 'uuid_456',
        name: 'Device',
        model: 'Model',
        osType: 'Android',
        osVersion: '13',
        appVersion: '1.0.0',
        userId: 'user_789',
      );
      final syncDevice2 = SyncDevice(
        id: 'device_456',
        uuid: 'uuid_456',
        name: 'Device',
        model: 'Model',
        osType: 'Android',
        osVersion: '13',
        appVersion: '1.0.0',
        userId: 'user_789',
      );

      // Act & Assert
      expect(syncDevice1 == syncDevice2, false);
      expect(syncDevice1.hashCode, isNot(syncDevice2.hashCode));
    });

    test('equality should be true for identical instances', () {
      // Arrange
      final syncDevice = SyncDevice(
        id: 'device_123',
        uuid: 'uuid_456',
        name: 'Device',
        model: 'Model',
        osType: 'Android',
        osVersion: '13',
        appVersion: '1.0.0',
        userId: 'user_789',
      );

      // Act & Assert
      expect(syncDevice == syncDevice, true);
    });
  });
}