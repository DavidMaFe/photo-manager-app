import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource =
        AuthLocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
  });

  group('AuthLocalDataSource', () {
    final testUser = UserModel(
      id: '1',
      email: 'test@example.com',
      name: 'John',
      surname: 'Doe',
    );

    const testToken = 'test_token_123';
    const cachedUserKey = 'CACHED_USER';
    const authTokenKey = 'AUTH_TOKEN';

    group('cacheUser', () {
      test('should cache user as JSON string in SharedPreferences', () async {
        // Arrange
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheUser(testUser);

        // Assert
        final expectedJson = jsonEncode(testUser.toJson());
        verify(() =>
                mockSharedPreferences.setString(cachedUserKey, expectedJson))
            .called(1);
      });

      test('should convert UserModel to JSON correctly before caching',
          () async {
        // Arrange
        String? capturedJson;
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((invocation) async {
          capturedJson = invocation.positionalArguments[1] as String;
          return true;
        });

        // Act
        await dataSource.cacheUser(testUser);

        // Assert
        expect(capturedJson, isNotNull);
        final decoded = jsonDecode(capturedJson!);
        expect(decoded['id'], testUser.id);
        expect(decoded['email'], testUser.email);
        expect(decoded['name'], testUser.name);
      });
    });

    group('getCachedUser', () {
      test('should return cached user when data exists', () async {
        // Arrange
        final userJson = jsonEncode(testUser.toJson());
        when(() => mockSharedPreferences.getString(cachedUserKey))
            .thenReturn(userJson);

        // Act
        final result = await dataSource.getCachedUser();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, testUser.id);
        expect(result.email, testUser.email);
        expect(result.name, testUser.name);
        expect(result.surname, testUser.surname);
      });

      test('should return null when no cached user exists', () async {
        // Arrange
        when(() => mockSharedPreferences.getString(cachedUserKey))
            .thenReturn(null);

        // Act
        final result = await dataSource.getCachedUser();

        // Assert
        expect(result, isNull);
      });

      test('should parse JSON correctly from cache', () async {
        // Arrange
        final userMap = {
          'id': '999',
          'email': 'cached@example.com',
          'name': 'Cached',
          'surname': 'User',
        };
        final userJson = jsonEncode(userMap);
        when(() => mockSharedPreferences.getString(cachedUserKey))
            .thenReturn(userJson);

        // Act
        final result = await dataSource.getCachedUser();

        // Assert
        expect(result!.id, '999');
        expect(result.email, 'cached@example.com');
        expect(result.name, 'Cached');
        expect(result.surname, 'User');
      });

      test('should handle user without surname', () async {
        // Arrange
        final userWithoutSurname = UserModel(
          id: '1',
          email: 'test@example.com',
          name: 'John',
        );
        final userJson = jsonEncode(userWithoutSurname.toJson());
        when(() => mockSharedPreferences.getString(cachedUserKey))
            .thenReturn(userJson);

        // Act
        final result = await dataSource.getCachedUser();

        // Assert
        expect(result!.surname, isNull);
      });
    });

    group('cacheToken', () {
      test('should cache token in SharedPreferences', () async {
        // Arrange
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheToken(testToken);

        // Assert
        verify(() => mockSharedPreferences.setString(authTokenKey, testToken))
            .called(1);
      });

      test('should cache empty token', () async {
        // Arrange
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.cacheToken('');

        // Assert
        verify(() => mockSharedPreferences.setString(authTokenKey, ''))
            .called(1);
      });
    });

    group('getToken', () {
      test('should return cached token when exists', () async {
        // Arrange
        when(() => mockSharedPreferences.getString(authTokenKey))
            .thenReturn(testToken);

        // Act
        final result = await dataSource.getToken();

        // Assert
        expect(result, testToken);
      });

      test('should return null when no token exists', () async {
        // Arrange
        when(() => mockSharedPreferences.getString(authTokenKey))
            .thenReturn(null);

        // Act
        final result = await dataSource.getToken();

        // Assert
        expect(result, isNull);
      });

      test('should return empty string if cached', () async {
        // Arrange
        when(() => mockSharedPreferences.getString(authTokenKey))
            .thenReturn('');

        // Act
        final result = await dataSource.getToken();

        // Assert
        expect(result, '');
      });
    });

    group('hasValidToken', () {
      test('should return true when token exists and is not empty', () async {
        // Arrange
        when(() => mockSharedPreferences.getString(authTokenKey))
            .thenReturn(testToken);

        // Act
        final result = await dataSource.hasValidToken();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when token is null', () async {
        // Arrange
        when(() => mockSharedPreferences.getString(authTokenKey))
            .thenReturn(null);

        // Act
        final result = await dataSource.hasValidToken();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when token is empty string', () async {
        // Arrange
        when(() => mockSharedPreferences.getString(authTokenKey))
            .thenReturn('');

        // Act
        final result = await dataSource.hasValidToken();

        // Assert
        expect(result, isFalse);
      });

      test('should return true for any non-empty token', () async {
        // Arrange
        when(() => mockSharedPreferences.getString(authTokenKey))
            .thenReturn('any_token');

        // Act
        final result = await dataSource.hasValidToken();

        // Assert
        expect(result, isTrue);
      });
    });

    group('clearCache', () {
      test('should remove both user and token from cache', () async {
        // Arrange
        when(() => mockSharedPreferences.remove(any()))
            .thenAnswer((_) async => true);

        // Act
        await dataSource.clearCache();

        // Assert
        verify(() => mockSharedPreferences.remove(cachedUserKey)).called(1);
        verify(() => mockSharedPreferences.remove(authTokenKey)).called(1);
      });

      test('should complete even if keys do not exist', () async {
        // Arrange
        when(() => mockSharedPreferences.remove(any()))
            .thenAnswer((_) async => false);

        // Act & Assert - should not throw
        await expectLater(dataSource.clearCache(), completes);
      });
    });

    group('cache round-trip', () {
      test('should retrieve same user data after caching', () async {
        // Arrange
        String? cachedJson;
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((invocation) async {
          cachedJson = invocation.positionalArguments[1] as String;
          return true;
        });
        when(() => mockSharedPreferences.getString(cachedUserKey))
            .thenAnswer((_) => cachedJson);

        // Act
        await dataSource.cacheUser(testUser);
        final result = await dataSource.getCachedUser();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, testUser.id);
        expect(result.email, testUser.email);
        expect(result.name, testUser.name);
        expect(result.surname, testUser.surname);
      });

      test('should retrieve same token after caching', () async {
        // Arrange
        String? cachedToken;
        when(() => mockSharedPreferences.setString(any(), any()))
            .thenAnswer((invocation) async {
          cachedToken = invocation.positionalArguments[1] as String;
          return true;
        });
        when(() => mockSharedPreferences.getString(authTokenKey))
            .thenAnswer((_) => cachedToken);

        // Act
        await dataSource.cacheToken(testToken);
        final result = await dataSource.getToken();

        // Assert
        expect(result, testToken);
      });
    });
  });
}
