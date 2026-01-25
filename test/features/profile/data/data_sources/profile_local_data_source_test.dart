import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:photo_manager_app/features/profile/data/models/user_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late ProfileLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = ProfileLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('ProfileLocalDataSource', () {
    final testProfile = UserProfileModel(
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

    const cachedProfileKey = 'CACHED_USER_PROFILE';

    group('cacheProfile', () {
      test('should cache profile as JSON string in SharedPreferences',
          () async {
        // Arrange
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheProfile(testProfile);

        // Assert
        final expectedJson = jsonEncode(testProfile.toJson());
        verify(() => mockSharedPreferences.setString(
            cachedProfileKey, expectedJson)).called(1);
      });

      test('should convert UserProfileModel to JSON correctly before caching',
          () async {
        // Arrange
        String? capturedJson;
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((invocation) async {
          capturedJson = invocation.positionalArguments[1] as String;
          return true;
        });

        // Act
        await dataSource.cacheProfile(testProfile);

        // Assert
        expect(capturedJson, isNotNull);
        final decoded = jsonDecode(capturedJson!);
        expect(decoded['id'], testProfile.id);
        expect(decoded['email'], testProfile.email);
        expect(decoded['storageUsedMb'], testProfile.storageUsedMb);
        expect(decoded['stats']['fileCount'], testProfile.fileCount);
      });

      test('should include stats in cached JSON', () async {
        // Arrange
        String? capturedJson;
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((invocation) async {
          capturedJson = invocation.positionalArguments[1] as String;
          return true;
        });

        // Act
        await dataSource.cacheProfile(testProfile);

        // Assert
        final decoded = jsonDecode(capturedJson!);
        expect(decoded['stats'], isNotNull);
        expect(decoded['stats']['folderCount'], 10);
        expect(decoded['stats']['deviceCount'], 2);
      });
    });

    group('getCachedProfile', () {
      test('should return cached profile when data exists', () async {
        // Arrange
        final profileJson = jsonEncode(testProfile.toJson());
        when(() => mockSharedPreferences.getString(cachedProfileKey))
            .thenReturn(profileJson);

        // Act
        final result = await dataSource.getCachedProfile();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, testProfile.id);
        expect(result.email, testProfile.email);
        expect(result.name, testProfile.name);
        expect(result.storageUsedMb, testProfile.storageUsedMb);
      });

      test('should return null when no cached profile exists', () async {
        // Arrange
        when(() => mockSharedPreferences.getString(cachedProfileKey))
            .thenReturn(null);

        // Act
        final result = await dataSource.getCachedProfile();

        // Assert
        expect(result, isNull);
      });

      test('should parse JSON correctly from cache', () async {
        // Arrange
        final profileMap = {
          'id': '999',
          'email': 'cached@example.com',
          'name': 'Cached',
          'surname': 'User',
          'hasProfileImage': false,
          'storageUsedMb': 1000,
          'storageTotalMb': 2048,
          'stats': {
            'fileCount': 200,
            'folderCount': 20,
            'deviceCount': 3,
          }
        };
        final profileJson = jsonEncode(profileMap);
        when(() => mockSharedPreferences.getString(cachedProfileKey))
            .thenReturn(profileJson);

        // Act
        final result = await dataSource.getCachedProfile();

        // Assert
        expect(result!.id, '999');
        expect(result.email, 'cached@example.com');
        expect(result.fileCount, 200);
        expect(result.deviceCount, 3);
      });

      test('should handle profile without optional fields', () async {
        // Arrange
        final minimalProfile = UserProfileModel(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          storageUsedMb: 500,
          storageTotalMb: 1024,
          fileCount: 100,
          folderCount: 10,
          deviceCount: 2,
          hasProfileImage: false,
        );
        final profileJson = jsonEncode(minimalProfile.toJson());
        when(() => mockSharedPreferences.getString(cachedProfileKey))
            .thenReturn(profileJson);

        // Act
        final result = await dataSource.getCachedProfile();

        // Assert
        expect(result!.surname, isNull);
      });

      test('should correctly parse stats from cached JSON', () async {
        // Arrange
        final profileJson = jsonEncode(testProfile.toJson());
        when(() => mockSharedPreferences.getString(cachedProfileKey))
            .thenReturn(profileJson);

        // Act
        final result = await dataSource.getCachedProfile();

        // Assert
        expect(result!.fileCount, 100);
        expect(result.folderCount, 10);
        expect(result.deviceCount, 2);
      });
    });

    group('clearProfileCache', () {
      test('should remove profile from cache', () async {
        // Arrange
        when(() => mockSharedPreferences.remove(any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.clearProfileCache();

        // Assert
        verify(() => mockSharedPreferences.remove(cachedProfileKey)).called(1);
      });

      test('should complete even if key does not exist', () async {
        // Arrange
        when(() => mockSharedPreferences.remove(any()))
            .thenAnswer((_) async => false);

        // Act & Assert - should not throw
        await expectLater(dataSource.clearProfileCache(), completes);
      });
    });

    group('cache round-trip', () {
      test('should retrieve same profile data after caching', () async {
        // Arrange
        String? cachedJson;
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((invocation) async {
          cachedJson = invocation.positionalArguments[1] as String;
          return true;
        });
        when(() => mockSharedPreferences.getString(cachedProfileKey))
            .thenAnswer((_) => cachedJson);

        // Act
        await dataSource.cacheProfile(testProfile);
        final result = await dataSource.getCachedProfile();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, testProfile.id);
        expect(result.email, testProfile.email);
        expect(result.name, testProfile.name);
        expect(result.surname, testProfile.surname);
        expect(result.hasProfileImage, testProfile.hasProfileImage);
        expect(result.storageUsedMb, testProfile.storageUsedMb);
        expect(result.storageTotalMb, testProfile.storageTotalMb);
        expect(result.fileCount, testProfile.fileCount);
        expect(result.folderCount, testProfile.folderCount);
        expect(result.deviceCount, testProfile.deviceCount);
      });

      test('should maintain computed properties after round-trip', () async {
        // Arrange
        String? cachedJson;
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((invocation) async {
          cachedJson = invocation.positionalArguments[1] as String;
          return true;
        });
        when(() => mockSharedPreferences.getString(cachedProfileKey))
            .thenAnswer((_) => cachedJson);

        // Act
        await dataSource.cacheProfile(testProfile);
        final result = await dataSource.getCachedProfile();

        // Assert
        expect(result!.storageUsedGb, testProfile.storageUsedGb);
        expect(
            result.storageUsedPercentage, testProfile.storageUsedPercentage);
        expect(result.fullName, testProfile.fullName);
      });
    });
  });
}
