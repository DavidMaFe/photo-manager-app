import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/profile/data/models/user_profile_model.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';

void main() {
  group('UserProfileModel', () {
    const testId = '1';
    const testEmail = 'test@example.com';
    const testName = 'John';
    const testSurname = 'Doe';
    const double testStorageUsedMb = 500;
    const testStorageTotalMb = 1024;
    const testFileCount = 100;
    const testFolderCount = 10;
    const testDeviceCount = 2;

    group('fromJson', () {
      test('should create UserProfileModel from JSON with all fields', () {
        // Arrange
        final json = {
          'id': testId,
          'email': testEmail,
          'name': testName,
          'surname': testSurname,
          'hasProfileImage': true,
          'storageUsedMb': testStorageUsedMb,
          'storageTotalMb': testStorageTotalMb,
          'stats': {
            'fileCount': testFileCount,
            'folderCount': testFolderCount,
            'deviceCount': testDeviceCount,
          }
        };

        // Act
        final result = UserProfileModel.fromJson(json);

        // Assert
        expect(result.id, testId);
        expect(result.email, testEmail);
        expect(result.name, testName);
        expect(result.surname, testSurname);
        expect(result.hasProfileImage, true);
        expect(result.storageUsedMb, testStorageUsedMb);
        expect(result.storageTotalMb, testStorageTotalMb);
        expect(result.fileCount, testFileCount);
        expect(result.folderCount, testFolderCount);
        expect(result.deviceCount, testDeviceCount);
      });

      test('should create UserProfileModel from JSON without optional fields',
          () {
        // Arrange
        final json = {
          'id': testId,
          'email': testEmail,
          'name': testName,
          'surname': null,
          'hasProfileImage': false,
          'storageUsedMb': testStorageUsedMb,
          'storageTotalMb': testStorageTotalMb,
          'stats': {
            'fileCount': testFileCount,
            'folderCount': testFolderCount,
            'deviceCount': testDeviceCount,
          }
        };

        // Act
        final result = UserProfileModel.fromJson(json);

        // Assert
        expect(result.surname, isNull);
        expect(result.hasProfileImage, false);
      });

      test('should convert integer id to string', () {
        // Arrange
        final json = {
          'id': 123,
          'email': testEmail,
          'name': testName,
          'hasProfileImage': false,
          'storageUsedMb': testStorageUsedMb,
          'storageTotalMb': testStorageTotalMb,
          'stats': {
            'fileCount': testFileCount,
            'folderCount': testFolderCount,
            'deviceCount': testDeviceCount,
          }
        };

        // Act
        final result = UserProfileModel.fromJson(json);

        // Assert
        expect(result.id, '123');
        expect(result.id, isA<String>());
      });

      test('should handle missing stats object with defaults', () {
        // Arrange
        final json = {
          'id': testId,
          'email': testEmail,
          'name': testName,
          'hasProfileImage': false,
          'storageUsedMb': testStorageUsedMb,
          'storageTotalMb': testStorageTotalMb,
        };

        // Act
        final result = UserProfileModel.fromJson(json);

        // Assert
        expect(result.fileCount, 0);
        expect(result.folderCount, 0);
        expect(result.deviceCount, 0);
      });

      test('should handle empty stats object with defaults', () {
        // Arrange
        final json = {
          'id': testId,
          'email': testEmail,
          'name': testName,
          'hasProfileImage': false,
          'storageUsedMb': testStorageUsedMb,
          'storageTotalMb': testStorageTotalMb,
          'stats': <String, dynamic>{},
        };

        // Act
        final result = UserProfileModel.fromJson(json);

        // Assert
        expect(result.fileCount, 0);
        expect(result.folderCount, 0);
        expect(result.deviceCount, 0);
      });

      test('should handle partial stats object', () {
        // Arrange
        final json = {
          'id': testId,
          'email': testEmail,
          'name': testName,
          'hasProfileImage': false,
          'storageUsedMb': testStorageUsedMb,
          'storageTotalMb': testStorageTotalMb,
          'stats': {
            'fileCount': testFileCount,
          }
        };

        // Act
        final result = UserProfileModel.fromJson(json);

        // Assert
        expect(result.fileCount, testFileCount);
        expect(result.folderCount, 0);
        expect(result.deviceCount, 0);
      });

      test('should be instance of UserProfile entity', () {
        // Arrange
        final json = {
          'id': testId,
          'email': testEmail,
          'name': testName,
          'hasProfileImage': false,
          'storageUsedMb': testStorageUsedMb,
          'storageTotalMb': testStorageTotalMb,
          'stats': <String, dynamic>{}
        };

        // Act
        final result = UserProfileModel.fromJson(json);

        // Assert
        expect(result, isA<UserProfile>());
      });
    });

    group('toJson', () {
      test('should convert UserProfileModel to JSON with all fields', () {
        // Arrange
        final model = UserProfileModel(
          id: testId,
          email: testEmail,
          name: testName,
          surname: testSurname,
          hasProfileImage: true,
          storageUsedMb: testStorageUsedMb,
          storageTotalMb: testStorageTotalMb,
          fileCount: testFileCount,
          folderCount: testFolderCount,
          deviceCount: testDeviceCount,
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['id'], testId);
        expect(result['email'], testEmail);
        expect(result['name'], testName);
        expect(result['surname'], testSurname);
        expect(result['hasProfileImage'], true);
        expect(result['storageUsedMb'], testStorageUsedMb);
        expect(result['storageTotalMb'], testStorageTotalMb);
        expect(result['stats']['fileCount'], testFileCount);
        expect(result['stats']['folderCount'], testFolderCount);
        expect(result['stats']['deviceCount'], testDeviceCount);
      });

      test('should include null values for optional fields', () {
        // Arrange
        final model = UserProfileModel(
          id: testId,
          email: testEmail,
          name: testName,
          hasProfileImage: false,
          storageUsedMb: testStorageUsedMb,
          storageTotalMb: testStorageTotalMb,
          fileCount: testFileCount,
          folderCount: testFolderCount,
          deviceCount: testDeviceCount,
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['surname'], isNull);
        expect(result['profileImage'], isNull);
      });

      test('should nest stats in correct structure', () {
        // Arrange
        final model = UserProfileModel(
          id: testId,
          email: testEmail,
          name: testName,
          hasProfileImage: false,
          storageUsedMb: testStorageUsedMb,
          storageTotalMb: testStorageTotalMb,
          fileCount: testFileCount,
          folderCount: testFolderCount,
          deviceCount: testDeviceCount,
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['stats'], isA<Map<String, dynamic>>());
        expect(result['stats'], containsPair('fileCount', testFileCount));
        expect(result['stats'], containsPair('folderCount', testFolderCount));
        expect(result['stats'], containsPair('deviceCount', testDeviceCount));
      });
    });

    group('fromEntity', () {
      test('should create UserProfileModel from UserProfile entity', () {
        // Arrange
        final entity = UserProfile(
          id: testId,
          email: testEmail,
          name: testName,
          surname: testSurname,
          hasProfileImage: true,
          storageUsedMb: testStorageUsedMb,
          storageTotalMb: testStorageTotalMb,
          fileCount: testFileCount,
          folderCount: testFolderCount,
          deviceCount: testDeviceCount,
        );

        // Act
        final result = UserProfileModel.fromEntity(entity);

        // Assert
        expect(result.id, entity.id);
        expect(result.email, entity.email);
        expect(result.name, entity.name);
        expect(result.surname, entity.surname);
        expect(result.hasProfileImage, entity.hasProfileImage);
        expect(result.storageUsedMb, entity.storageUsedMb);
        expect(result.storageTotalMb, entity.storageTotalMb);
        expect(result.fileCount, entity.fileCount);
        expect(result.folderCount, entity.folderCount);
        expect(result.deviceCount, entity.deviceCount);
        expect(result, isA<UserProfileModel>());
      });

      test('should preserve all entity properties', () {
        // Arrange
        final entity = UserProfile(
          id: '999',
          email: 'different@example.com',
          name: 'Jane',
          surname: 'Smith',
          hasProfileImage: true,
          storageUsedMb: 1000,
          storageTotalMb: 2048,
          fileCount: 200,
          folderCount: 20,
          deviceCount: 3,
        );

        // Act
        final result = UserProfileModel.fromEntity(entity);

        // Assert
        expect(result.id, '999');
        expect(result.email, 'different@example.com');
        expect(result.storageUsedMb, 1000);
        expect(result.fileCount, 200);
      });
    });

    group('JSON serialization round-trip', () {
      test('should maintain data integrity through fromJson and toJson', () {
        // Arrange
        final originalJson = {
          'id': testId,
          'email': testEmail,
          'name': testName,
          'surname': testSurname,
          'hasProfileImage': true,
          'storageUsedMb': testStorageUsedMb,
          'storageTotalMb': testStorageTotalMb,
          'stats': {
            'fileCount': testFileCount,
            'folderCount': testFolderCount,
            'deviceCount': testDeviceCount,
          }
        };

        // Act
        final model = UserProfileModel.fromJson(originalJson);
        final resultJson = model.toJson();

        // Assert
        expect(resultJson['id'], originalJson['id']);
        expect(resultJson['email'], originalJson['email']);
        expect(resultJson['name'], originalJson['name']);
        expect(resultJson['storageUsedMb'], originalJson['storageUsedMb']);
        final resultStats = resultJson['stats'] as Map<String, dynamic>;
        final originalStats = originalJson['stats'] as Map<String, dynamic>;
        expect(resultStats['fileCount'], originalStats['fileCount']);
      });
    });

    group('inheritance', () {
      test('should inherit UserProfile computed properties', () {
        // Arrange
        final model = UserProfileModel(
          id: testId,
          email: testEmail,
          name: testName,
          surname: testSurname,
          hasProfileImage: false,
          storageUsedMb: 512,
          storageTotalMb: 1024,
          fileCount: testFileCount,
          folderCount: testFolderCount,
          deviceCount: testDeviceCount,
        );

        // Assert
        expect(model.fullName, 'John Doe');
        expect(model.storageUsedGb, 0.5);
        expect(model.storageTotalGb, 1.0);
        expect(model.storageUsedPercentage, 0.5);
        expect(model, isA<UserProfile>());
      });
    });
  });
}
