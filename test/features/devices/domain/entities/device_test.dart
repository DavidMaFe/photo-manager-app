import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/devices/domain/entities/device.dart';
import '../../../../fixtures/test_data.dart';

void main() {
  group('Device', () {
    group('isAndroid', () {
      test('should return true when osType is "Android"', () {
        // Arrange
        final device = TestDeviceEntities.androidDevice;

        // Act
        final result = device.isAndroid;

        // Assert
        expect(result, true);
      });

      test('should return true when osType is "android" (lowercase)', () {
        // Arrange
        final device = TestDeviceEntities.deviceWithLowercaseOs;

        // Act
        final result = device.isAndroid;

        // Assert
        expect(result, true);
      });

      test('should return false when osType is not Android', () {
        // Arrange
        final device = TestDeviceEntities.iosDevice;

        // Act
        final result = device.isAndroid;

        // Assert
        expect(result, false);
      });
    });

    group('isIOS', () {
      test('should return true when osType is "iOS"', () {
        // Arrange
        final device = TestDeviceEntities.iosDevice;

        // Act
        final result = device.isIOS;

        // Assert
        expect(result, true);
      });

      test('should return true when osType is "ios" (lowercase)', () {
        // Arrange
        const device = Device(
          id: '1',
          uuid: 'test-uuid',
          name: 'Test iPhone',
          model: 'iPhone14,3',
          osType: 'ios',
          osVersion: '16.0',
          appVersion: '1.0.0',
          autoSync: false,
        );

        // Act
        final result = device.isIOS;

        // Assert
        expect(result, true);
      });

      test('should return false when osType is not iOS', () {
        // Arrange
        final device = TestDeviceEntities.androidDevice;

        // Act
        final result = device.isIOS;

        // Assert
        expect(result, false);
      });
    });

    group('copyWith', () {
      test('should return a new device with updated name', () {
        // Arrange
        final device = TestDeviceEntities.androidDevice;
        const newName = 'My New Phone';

        // Act
        final result = device.copyWith(name: newName);

        // Assert
        expect(result.name, newName);
        expect(result.id, device.id);
        expect(result.uuid, device.uuid);
        expect(result.model, device.model);
        expect(result.osType, device.osType);
        expect(result.osVersion, device.osVersion);
        expect(result.appVersion, device.appVersion);
        expect(result.autoSync, device.autoSync);
      });

      test('should return a new device with updated autoSync', () {
        // Arrange
        final device = TestDeviceEntities.androidDevice;
        const newAutoSync = false;

        // Act
        final result = device.copyWith(autoSync: newAutoSync);

        // Assert
        expect(result.autoSync, newAutoSync);
        expect(result.name, device.name);
      });

      test('should return a new device with all fields updated', () {
        // Arrange
        final device = TestDeviceEntities.androidDevice;

        // Act
        final result = device.copyWith(
          id: '999',
          uuid: 'new-uuid',
          name: 'New Name',
          model: 'New Model',
          osType: 'New OS',
          osVersion: 'New Version',
          appVersion: 'New App Version',
          autoSync: false,
        );

        // Assert
        expect(result.id, '999');
        expect(result.uuid, 'new-uuid');
        expect(result.name, 'New Name');
        expect(result.model, 'New Model');
        expect(result.osType, 'New OS');
        expect(result.osVersion, 'New Version');
        expect(result.appVersion, 'New App Version');
        expect(result.autoSync, false);
      });

      test('should return a new device with no changes when no parameters provided', () {
        // Arrange
        final device = TestDeviceEntities.androidDevice;

        // Act
        final result = device.copyWith();

        // Assert
        expect(result.id, device.id);
        expect(result.uuid, device.uuid);
        expect(result.name, device.name);
        expect(result.model, device.model);
        expect(result.osType, device.osType);
        expect(result.osVersion, device.osVersion);
        expect(result.appVersion, device.appVersion);
        expect(result.autoSync, device.autoSync);
      });
    });

    group('equality', () {
      test('should be equal when devices have the same id', () {
        // Arrange
        final device1 = TestDeviceEntities.androidDevice;
        final device2 = TestDeviceEntities.androidDevice;

        // Act & Assert
        expect(device1, equals(device2));
        expect(device1.hashCode, equals(device2.hashCode));
      });

      test('should be equal when devices have the same id but different properties', () {
        // Arrange
        final device1 = TestDeviceEntities.androidDevice;
        final device2 = device1.copyWith(name: 'Different Name');

        // Act & Assert
        expect(device1, equals(device2));
        expect(device1.hashCode, equals(device2.hashCode));
      });

      test('should not be equal when devices have different ids', () {
        // Arrange
        final device1 = TestDeviceEntities.androidDevice;
        final device2 = TestDeviceEntities.iosDevice;

        // Act & Assert
        expect(device1, isNot(equals(device2)));
        expect(device1.hashCode, isNot(equals(device2.hashCode)));
      });

      test('should be equal to itself (identity)', () {
        // Arrange
        final device = TestDeviceEntities.androidDevice;

        // Act & Assert
        expect(device, equals(device));
      });
    });

    group('toString', () {
      test('should return a string representation of the device', () {
        // Arrange
        final device = TestDeviceEntities.androidDevice;

        // Act
        final result = device.toString();

        // Assert
        expect(result, contains('Device{'));
        expect(result, contains('id: ${device.id}'));
        expect(result, contains('name: ${device.name}'));
        expect(result, contains('osType: ${device.osType}'));
        expect(result, contains('osVersion: ${device.osVersion}'));
        expect(result, contains('autoSync: ${device.autoSync}'));
      });
    });
  });
}
