import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/devices/domain/entities/device.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/battery_preference.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/network_preference.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/sync_frequency.dart';

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

/// Sample Device entities for the devices feature testing
class TestDeviceEntities {
  /// Standard Android device with auto sync enabled
  static Device get androidDevice => const Device(
        id: '1',
        uuid: 'android-uuid-001',
        name: 'Samsung Galaxy S21',
        model: 'SM-G991B',
        osType: 'Android',
        osVersion: '13',
        appVersion: '1.0.0',
        autoSync: true,
      );

  /// iOS device with auto sync disabled
  static Device get iosDevice => const Device(
        id: '2',
        uuid: 'ios-uuid-002',
        name: 'iPhone 13 Pro',
        model: 'iPhone14,3',
        osType: 'iOS',
        osVersion: '16.0',
        appVersion: '1.0.0',
        autoSync: false,
      );

  /// Android tablet with auto sync enabled
  static Device get androidTablet => const Device(
        id: '3',
        uuid: 'android-tablet-uuid-003',
        name: 'Samsung Galaxy Tab S8',
        model: 'SM-X706B',
        osType: 'Android',
        osVersion: '12',
        appVersion: '1.0.0',
        autoSync: true,
      );

  /// Device with lowercase os type (for testing isAndroid/isIOS getters)
  static Device get deviceWithLowercaseOs => const Device(
        id: '4',
        uuid: 'lowercase-uuid-004',
        name: 'Test Device',
        model: 'TEST-001',
        osType: 'android',
        osVersion: '11',
        appVersion: '1.0.0',
        autoSync: false,
      );

  /// Device with unknown OS type
  static Device get unknownOsDevice => const Device(
        id: '5',
        uuid: 'unknown-uuid-005',
        name: 'Unknown Device',
        model: 'UNKNOWN-001',
        osType: 'Windows',
        osVersion: '11',
        appVersion: '1.0.0',
        autoSync: false,
      );

  /// List of multiple devices for testing lists
  static List<Device> get deviceList => [
        androidDevice,
        iosDevice,
        androidTablet,
      ];

  /// Empty list for testing empty states
  static List<Device> get emptyDeviceList => [];
}

/// Sample device JSON responses for data layer testing
class TestDeviceJsonData {
  /// Android device JSON (as returned by API)
  static const Map<String, dynamic> androidDeviceJson = {
    'deviceId': '1',
    'uuid': 'android-uuid-001',
    'name': 'Samsung Galaxy S21',
    'model': 'SM-G991B',
    'osType': 'Android',
    'osVersion': '13',
    'appVersion': '1.0.0',
    'autoSyncEnabled': true,
  };

  /// iOS device JSON
  static const Map<String, dynamic> iosDeviceJson = {
    'deviceId': '2',
    'uuid': 'ios-uuid-002',
    'name': 'iPhone 13 Pro',
    'model': 'iPhone14,3',
    'osType': 'iOS',
    'osVersion': '16.0',
    'appVersion': '1.0.0',
    'autoSyncEnabled': false,
  };

  /// Device JSON with integer deviceId (should be converted to string)
  static const Map<String, dynamic> deviceJsonWithIntegerId = {
    'deviceId': 123,
    'uuid': 'int-id-uuid-123',
    'name': 'Test Device',
    'model': 'TEST-001',
    'osType': 'Android',
    'osVersion': '11',
    'appVersion': '1.0.0',
    'autoSyncEnabled': true,
  };

  /// Device JSON without autoSyncEnabled (should default to false)
  static const Map<String, dynamic> deviceJsonWithoutAutoSync = {
    'deviceId': '4',
    'uuid': 'no-autosync-uuid-004',
    'name': 'Legacy Device',
    'model': 'LEGACY-001',
    'osType': 'Android',
    'osVersion': '10',
    'appVersion': '0.9.0',
  };

  /// API response with multiple devices
  static const Map<String, dynamic> deviceListResponse = {
    'devices': [
      androidDeviceJson,
      iosDeviceJson,
    ],
  };

  /// Empty device list response
  static const Map<String, dynamic> emptyDeviceListResponse = {
    'devices': [],
  };

  /// Error response example
  static const Map<String, dynamic> errorResponse = {
    'error': 'Unauthorized access',
    'code': 'UNAUTHORIZED',
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

/// Sample SyncConfig entities for sync configuration testing
class TestSyncConfigs {
  /// Disabled sync configuration (default state)
  static SyncConfig get disabled => SyncConfig.disabled();

  /// Default enabled sync configuration
  static SyncConfig get defaultEnabled => SyncConfig.defaultEnabled();

  /// Daily sync at 2:00 AM with WiFi-only and battery requirement
  static SyncConfig get dailySync => const SyncConfig(
        autoSyncEnabled: true,
        syncFrequency: SyncFrequency.daily,
        syncHour: 2,
        syncMinute: 0,
        syncDayOfWeek: null,
        networkPreference: NetworkPreference.wifiOnly,
        batteryPreference: BatteryPreference.chargingOrAbove15Percent,
        notifyOnSuccess: false,
        notifyOnFailure: true,
      );

  /// Daily sync at 3:30 AM with any network and any battery
  static SyncConfig get dailySyncAnyConditions => const SyncConfig(
        autoSyncEnabled: true,
        syncFrequency: SyncFrequency.daily,
        syncHour: 3,
        syncMinute: 30,
        syncDayOfWeek: null,
        networkPreference: NetworkPreference.anyNetwork,
        batteryPreference: BatteryPreference.any,
        notifyOnSuccess: true,
        notifyOnFailure: true,
      );

  /// Weekly sync on Monday at 1:00 AM
  static SyncConfig get weeklySync => const SyncConfig(
        autoSyncEnabled: true,
        syncFrequency: SyncFrequency.weekly,
        syncHour: 1,
        syncMinute: 0,
        syncDayOfWeek: 1, // Monday
        networkPreference: NetworkPreference.wifiOnly,
        batteryPreference: BatteryPreference.chargingOrAbove15Percent,
        notifyOnSuccess: false,
        notifyOnFailure: true,
      );

  /// Weekly sync on Sunday at 23:45 with all notifications enabled
  static SyncConfig get weeklySyncSunday => const SyncConfig(
        autoSyncEnabled: true,
        syncFrequency: SyncFrequency.weekly,
        syncHour: 23,
        syncMinute: 45,
        syncDayOfWeek: 7, // Sunday
        networkPreference: NetworkPreference.wifiOnly,
        batteryPreference: BatteryPreference.chargingOrAbove15Percent,
        notifyOnSuccess: true,
        notifyOnFailure: true,
      );

  /// Sync config with only success notifications
  static SyncConfig get onlySuccessNotifications => const SyncConfig(
        autoSyncEnabled: true,
        syncFrequency: SyncFrequency.daily,
        syncHour: 4,
        syncMinute: 0,
        syncDayOfWeek: null,
        networkPreference: NetworkPreference.wifiOnly,
        batteryPreference: BatteryPreference.chargingOrAbove15Percent,
        notifyOnSuccess: true,
        notifyOnFailure: false,
      );

  /// Sync config with no notifications
  static SyncConfig get noNotifications => const SyncConfig(
        autoSyncEnabled: true,
        syncFrequency: SyncFrequency.daily,
        syncHour: 5,
        syncMinute: 15,
        syncDayOfWeek: null,
        networkPreference: NetworkPreference.wifiOnly,
        batteryPreference: BatteryPreference.chargingOrAbove15Percent,
        notifyOnSuccess: false,
        notifyOnFailure: false,
      );
}

/// Sample SyncConfig JSON data for data layer testing
class TestSyncConfigJsonData {
  /// Daily sync JSON
  static const Map<String, dynamic> dailySyncJson = {
    'autoSyncEnabled': true,
    'syncFrequency': 'daily',
    'syncHour': 2,
    'syncMinute': 0,
    'syncDayOfWeek': null,
    'networkPreference': 'wifiOnly',
    'batteryPreference': 'chargingOrAbove15Percent',
    'notifyOnSuccess': false,
    'notifyOnFailure': true,
  };

  /// Weekly sync JSON
  static const Map<String, dynamic> weeklySyncJson = {
    'autoSyncEnabled': true,
    'syncFrequency': 'weekly',
    'syncHour': 1,
    'syncMinute': 0,
    'syncDayOfWeek': 1,
    'networkPreference': 'wifiOnly',
    'batteryPreference': 'chargingOrAbove15Percent',
    'notifyOnSuccess': false,
    'notifyOnFailure': true,
  };

  /// Disabled sync JSON
  static const Map<String, dynamic> disabledSyncJson = {
    'autoSyncEnabled': false,
    'syncFrequency': 'daily',
    'syncHour': 2,
    'syncMinute': 0,
    'syncDayOfWeek': null,
    'networkPreference': 'wifiOnly',
    'batteryPreference': 'chargingOrAbove15Percent',
    'notifyOnSuccess': false,
    'notifyOnFailure': true,
  };

  /// Sync with any network and any battery
  static const Map<String, dynamic> anyConditionsSyncJson = {
    'autoSyncEnabled': true,
    'syncFrequency': 'daily',
    'syncHour': 3,
    'syncMinute': 30,
    'syncDayOfWeek': null,
    'networkPreference': 'anyNetwork',
    'batteryPreference': 'any',
    'notifyOnSuccess': true,
    'notifyOnFailure': true,
  };
}

/// Albums shared by the folders presentation tests.
class TestFolders {
  static final createdAt = DateTime(2024, 1, 15);

  static Folder album({
    String id = 'folder-1',
    String name = 'Vacation',
    String? parentFolderId,
    String? path,
    int fileCount = 42,
    int subfolderCount = 3,
    DateTime? oldestCapturedAt,
    DateTime? newestCapturedAt,
    List<String> coverFileIds = const [],
    List<String> fallbackCoverFileIds = const [],
  }) {
    return Folder(
      id: id,
      name: name,
      parentFolderId: parentFolderId,
      path: path ?? '/$name',
      createdAt: createdAt,
      fileCount: fileCount,
      subfolderCount: subfolderCount,
      oldestCapturedAt: oldestCapturedAt,
      newestCapturedAt: newestCapturedAt,
      coverFileIds: coverFileIds,
      fallbackCoverFileIds: fallbackCoverFileIds,
    );
  }
}
