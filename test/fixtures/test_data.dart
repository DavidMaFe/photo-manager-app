import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';

/// Test Data Fixtures
///
/// This file provides predefined test data objects for use across all tests.
/// Using these fixtures ensures consistency and reduces duplication in test setup.
///
/// Usage Example:
/// ```dart
/// test('should process user correctly', () {
///   final user = TestUsers.johnDoe;
///   expect(user.email, 'john.doe@example.com');
/// });
/// ```

/// Sample User entities for testing
class TestUsers {
  /// Standard user - John Doe
  static User get johnDoe => User(
        id: '1',
        email: 'john.doe@example.com',
        name: 'John',
        surname: 'Doe',
      );

  /// User without surname - Jane Smith
  static User get janeSmith => User(
        id: '2',
        email: 'jane.smith@example.com',
        name: 'Jane',
      );

  /// User with Spanish name - María García
  static User get mariaGarcia => User(
        id: '3',
        email: 'maria.garcia@ejemplo.com',
        name: 'María',
        surname: 'García',
      );

  /// Empty user for testing invalid states
  static User get empty => User.empty();

  /// User with minimal valid data
  static User get minimal => User(
        id: '999',
        email: 'minimal@test.com',
        name: 'Test',
      );
}

/// Sample UserProfile entities for testing
class TestProfiles {
  /// Standard profile with moderate storage usage (50%)
  static UserProfile get johnDoeProfile => UserProfile(
        id: '1',
        email: 'john.doe@example.com',
        name: 'John',
        surname: 'Doe',
        hasProfileImage: true,
        storageUsedMb: 512.5,
        storageTotalMb: 1024,
        fileCount: 150,
        folderCount: 10,
        deviceCount: 2,
      );

  /// Profile with high storage usage (90%)
  static UserProfile get highStorageProfile => UserProfile(
        id: '2',
        email: 'jane.smith@example.com',
        name: 'Jane',
        hasProfileImage: false,
        storageUsedMb: 921.6,
        storageTotalMb: 1024,
        fileCount: 500,
        folderCount: 25,
        deviceCount: 3,
      );

  /// Profile with no storage used (0%)
  static UserProfile get emptyStorageProfile => UserProfile(
        id: '3',
        email: 'new.user@example.com',
        name: 'New',
        surname: 'User',
        hasProfileImage: false,
        storageUsedMb: 0,
        storageTotalMb: 1024,
        fileCount: 0,
        folderCount: 0,
        deviceCount: 1,
      );

  /// Profile at storage capacity (100%)
  static UserProfile get fullStorageProfile => UserProfile(
        id: '4',
        email: 'full.storage@example.com',
        name: 'Full',
        hasProfileImage: false,
        storageUsedMb: 2048,
        storageTotalMb: 2048,
        fileCount: 1000,
        folderCount: 50,
        deviceCount: 5,
      );

  /// Profile without profile image
  static UserProfile get noImageProfile => UserProfile(
        id: '5',
        email: 'no.image@example.com',
        name: 'NoImage',
        hasProfileImage: false,
        storageUsedMb: 256,
        storageTotalMb: 1024,
        fileCount: 75,
        folderCount: 5,
        deviceCount: 1,
      );

  /// Profile with large storage capacity (premium user)
  static UserProfile get premiumProfile => UserProfile(
        id: '6',
        email: 'premium@example.com',
        name: 'Premium',
        surname: 'User',
        hasProfileImage: true,
        storageUsedMb: 5120,
        storageTotalMb: 10240,
        fileCount: 2500,
        folderCount: 100,
        deviceCount: 10,
      );
}

/// Sample authentication tokens and credentials
class TestAuth {
  /// Valid authentication token
  static const String validToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test_token';

  /// Expired authentication token
  static const String expiredToken = 'expired.jwt.token';

  /// Valid email addresses
  static const String validEmail = 'test@example.com';
  static const String validEmail2 = 'another@test.com';

  /// Invalid email addresses
  static const String invalidEmailNoAt = 'testexample.com';
  static const String invalidEmailNoDot = 'test@examplecom';
  static const String emptyEmail = '';

  /// Valid passwords
  static const String validPassword = 'SecurePassword123';
  static const String validPassword2 = 'AnotherPass456';

  /// Invalid passwords
  static const String emptyPassword = '';
  static const String shortPassword = '123';

  /// User credentials
  static const Map<String, String> validCredentials = {
    'email': validEmail,
    'password': validPassword,
  };

  /// Registration data
  static const Map<String, String> validRegistrationData = {
    'email': 'newuser@example.com',
    'password': 'NewPassword123',
    'name': 'New',
    'surname': 'User',
  };
}

/// Sample file and folder IDs for testing file management features
class TestFileIds {
  static const String file1 = 'file_001';
  static const String file2 = 'file_002';
  static const String file3 = 'file_003';
  static const String imageFile = 'img_001.jpg';
  static const String videoFile = 'vid_001.mp4';
  static const String folder1 = 'folder_001';
  static const String folder2 = 'folder_002';
  static const String rootFolder = 'root';

  /// List of multiple file IDs for bulk operations
  static const List<String> bulkFileIds = [file1, file2, file3];
}

/// Sample device information for sync testing
class TestDevices {
  static const String deviceId1 = 'device_android_001';
  static const String deviceId2 = 'device_ios_002';
  static const String deviceName1 = 'Samsung Galaxy S21';
  static const String deviceName2 = 'iPhone 13 Pro';

  static const Map<String, dynamic> androidDevice = {
    'id': deviceId1,
    'name': deviceName1,
    'platform': 'android',
    'osVersion': '13',
  };

  static const Map<String, dynamic> iosDevice = {
    'id': deviceId2,
    'name': deviceName2,
    'platform': 'ios',
    'osVersion': '16.0',
  };
}

/// Sample sync session data
class TestSyncSessions {
  static const String sessionId1 = 'sync_session_001';
  static const String sessionId2 = 'sync_session_002';

  static const Map<String, dynamic> activeSession = {
    'id': sessionId1,
    'deviceId': TestDevices.deviceId1,
    'status': 'active',
    'filesUploaded': 15,
    'totalFiles': 50,
  };

  static const Map<String, dynamic> completedSession = {
    'id': sessionId2,
    'deviceId': TestDevices.deviceId2,
    'status': 'completed',
    'filesUploaded': 100,
    'totalFiles': 100,
  };
}

/// Common error messages for testing
class TestErrors {
  static const String networkError = 'Network error occurred';
  static const String serverError = 'Internal server error';
  static const String unauthorizedError = 'Unauthorized access';
  static const String notFoundError = 'Resource not found';
  static const String validationError = 'Validation failed';
}

/// Sample date/time values for testing
class TestDates {
  static final DateTime now = DateTime(2024, 1, 15, 10, 30);
  static final DateTime yesterday = DateTime(2024, 1, 14, 10, 30);
  static final DateTime lastWeek = DateTime(2024, 1, 8, 10, 30);
  static final DateTime lastMonth = DateTime(2023, 12, 15, 10, 30);

  /// ISO 8601 formatted date strings
  static const String nowIso = '2024-01-15T10:30:00.000Z';
  static const String yesterdayIso = '2024-01-14T10:30:00.000Z';
}