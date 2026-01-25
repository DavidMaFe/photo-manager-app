import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';

void main() {
  group('UserProfile Entity', () {
    test('should create profile with all required fields', () {
      // Act
      final profile = UserProfile(
        id: '1',
        email: 'test@example.com',
        name: 'John',
        surname: 'Doe',
        hasProfileImage: true,
        storageUsedMb: 500,
        storageTotalMb: 1024,
        fileCount: 100,
        folderCount: 10,
        deviceCount: 2,
      );

      // Assert
      expect(profile.id, '1');
      expect(profile.email, 'test@example.com');
      expect(profile.name, 'John');
      expect(profile.surname, 'Doe');
      expect(profile.hasProfileImage, true);
      expect(profile.storageUsedMb, 500);
      expect(profile.storageTotalMb, 1024);
      expect(profile.fileCount, 100);
      expect(profile.folderCount, 10);
      expect(profile.deviceCount, 2);
    });

    test('should create profile without optional fields', () {
      // Act
      final profile = UserProfile(
        id: '1',
        email: 'test@example.com',
        name: 'John',
        hasProfileImage: false,
        storageUsedMb: 500,
        storageTotalMb: 1024,
        fileCount: 100,
        folderCount: 10,
        deviceCount: 2,
      );

      // Assert
      expect(profile.surname, isNull);
    });

    group('fullName getter', () {
      test('should return full name when surname exists', () {
        // Arrange
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          surname: 'Doe',
          hasProfileImage: false,
          storageUsedMb: 500,
          storageTotalMb: 1024,
          fileCount: 100,
          folderCount: 10,
          deviceCount: 2,
        );

        // Assert
        expect(profile.fullName, 'John Doe');
      });

      test('should return name with null when surname is null', () {
        // Arrange
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          hasProfileImage: false,
          storageUsedMb: 500,
          storageTotalMb: 1024,
          fileCount: 100,
          folderCount: 10,
          deviceCount: 2,
        );

        // Assert
        expect(profile.fullName, 'John');
      });
    });

    group('storage GB conversions', () {
      test('should convert storageUsedMb to GB correctly', () {
        // Arrange
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          hasProfileImage: false,
          storageUsedMb: 2048,
          storageTotalMb: 10240,
          fileCount: 100,
          folderCount: 10,
          deviceCount: 2,
        );

        // Assert
        expect(profile.storageUsedGb, 2.0);
      });

      test('should convert storageTotalMb to GB correctly', () {
        // Arrange
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          hasProfileImage: false,
          storageUsedMb: 2048,
          storageTotalMb: 10240,
          fileCount: 100,
          folderCount: 10,
          deviceCount: 2,
        );

        // Assert
        expect(profile.storageTotalGb, 10.0);
      });

      test('should handle fractional GB values', () {
        // Arrange
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          hasProfileImage: false,
          storageUsedMb: 1536,
          storageTotalMb: 5120,
          fileCount: 100,
          folderCount: 10,
          deviceCount: 2,
        );

        // Assert
        expect(profile.storageUsedGb, 1.5);
        expect(profile.storageTotalGb, 5.0);
      });

      test('should handle zero storage values', () {
        // Arrange
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          hasProfileImage: false,
          storageUsedMb: 0,
          storageTotalMb: 1024,
          fileCount: 0,
          folderCount: 0,
          deviceCount: 0,
        );

        // Assert
        expect(profile.storageUsedGb, 0.0);
      });
    });

    group('storageUsedPercentage getter', () {
      test('should calculate percentage correctly', () {
        // Arrange
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          hasProfileImage: false,
          storageUsedMb: 512,
          storageTotalMb: 1024,
          fileCount: 100,
          folderCount: 10,
          deviceCount: 2,
        );

        // Assert
        expect(profile.storageUsedPercentage, 0.5);
      });

      test('should return 0.0 when total storage is 0', () {
        // Arrange
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          hasProfileImage: false,
          storageUsedMb: 100,
          storageTotalMb: 0,
          fileCount: 100,
          folderCount: 10,
          deviceCount: 2,
        );

        // Assert
        expect(profile.storageUsedPercentage, 0.0);
      });

      test('should calculate 100% usage correctly', () {
        // Arrange
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          hasProfileImage: false,
          storageUsedMb: 1024,
          storageTotalMb: 1024,
          fileCount: 100,
          folderCount: 10,
          deviceCount: 2,
        );

        // Assert
        expect(profile.storageUsedPercentage, 1.0);
      });

      test('should calculate 25% usage correctly', () {
        // Arrange
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          hasProfileImage: false,
          storageUsedMb: 256,
          storageTotalMb: 1024,
          fileCount: 100,
          folderCount: 10,
          deviceCount: 2,
        );

        // Assert
        expect(profile.storageUsedPercentage, 0.25);
      });

      test('should handle very small percentages', () {
        // Arrange
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          hasProfileImage: false,
          storageUsedMb: 1,
          storageTotalMb: 10240,
          fileCount: 1,
          folderCount: 1,
          deviceCount: 1,
        );

        // Assert
        expect(profile.storageUsedPercentage, closeTo(0.0001, 0.0001));
      });

      test('should return 0 when both storage values are 0', () {
        // Arrange
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          hasProfileImage: false,
          storageUsedMb: 0,
          storageTotalMb: 0,
          fileCount: 0,
          folderCount: 0,
          deviceCount: 0,
        );

        // Assert
        expect(profile.storageUsedPercentage, 0.0);
      });
    });

    group('hasProfileImage getter', () {
      test('should return true when profile image exists', () {
        // Arrange
        final profile = UserProfile(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          hasProfileImage: true,
          storageUsedMb: 500,
          storageTotalMb: 1024,
          fileCount: 100,
          folderCount: 10,
          deviceCount: 2,
        );

        // Assert
        expect(profile.hasProfileImage, isTrue);
      });
    });
  });
}
