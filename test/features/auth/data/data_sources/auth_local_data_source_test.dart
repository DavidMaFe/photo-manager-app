import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/in_memory_secure_store.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;
  late InMemorySecureStore secureStore;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    secureStore = InMemorySecureStore();
    when(() => mockSharedPreferences.remove(any())).thenAnswer((_) async => true);
    dataSource = AuthLocalDataSourceImpl(sharedPreferences: mockSharedPreferences, secureStore: secureStore);
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
    const refreshTokenKey = 'REFRESH_TOKEN';

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
      test('should store the token in the secure storage, not in SharedPreferences', () async {
        // Act
        await dataSource.cacheToken(testToken);

        // Assert
        expect(secureStore.values[authTokenKey], testToken);
        verifyNever(() => mockSharedPreferences.setString(authTokenKey, any()));
      });

      test('should remove the legacy unencrypted tokens from SharedPreferences', () async {
        // Act
        await dataSource.cacheToken(testToken);

        // Assert
        verify(() => mockSharedPreferences.remove(authTokenKey)).called(1);
        verify(() => mockSharedPreferences.remove(refreshTokenKey)).called(1);
      });
    });

    group('cacheRefreshToken', () {
      test('should store the refresh token in the secure storage', () async {
        // Act
        await dataSource.cacheRefreshToken('refresh_123');

        // Assert
        expect(secureStore.values[refreshTokenKey], 'refresh_123');
        expect(await dataSource.getRefreshToken(), 'refresh_123');
      });
    });

    group('getToken', () {
      test('should return the token from the secure storage', () async {
        // Arrange
        await secureStore.write(authTokenKey, testToken);

        // Act
        final result = await dataSource.getToken();

        // Assert
        expect(result, testToken);
      });

      test('should return null when no token exists', () async {
        expect(await dataSource.getToken(), isNull);
      });

      test('should ignore a legacy token left in SharedPreferences', () async {
        // Arrange: a token stored by a version before the end-to-end encryption
        when(() => mockSharedPreferences.getString(authTokenKey)).thenReturn('legacy');

        // Act & Assert
        expect(await dataSource.getToken(), isNull);
      });
    });

    group('hasValidToken', () {
      test('should return true when token exists and is not empty', () async {
        await secureStore.write(authTokenKey, testToken);

        expect(await dataSource.hasValidToken(), isTrue);
      });

      test('should return false when token is null', () async {
        expect(await dataSource.hasValidToken(), isFalse);
      });

      test('should return false when token is empty string', () async {
        await secureStore.write(authTokenKey, '');

        expect(await dataSource.hasValidToken(), isFalse);
      });
    });

    group('clearCache', () {
      test('should remove the tokens from the secure storage and the user from SharedPreferences', () async {
        // Arrange
        await secureStore.write(authTokenKey, testToken);
        await secureStore.write(refreshTokenKey, 'refresh_123');
        await secureStore.write('E2EE_MASTER_KEY_V1', 'kept by its own data source');

        // Act
        await dataSource.clearCache();

        // Assert
        expect(secureStore.values.keys, ['E2EE_MASTER_KEY_V1']);
        verify(() => mockSharedPreferences.remove(cachedUserKey)).called(1);
        verify(() => mockSharedPreferences.remove(authTokenKey)).called(1);
      });

      test('should complete even if keys do not exist', () async {
        when(() => mockSharedPreferences.remove(any())).thenAnswer((_) async => false);

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
        // Act
        await dataSource.cacheToken(testToken);
        final result = await dataSource.getToken();

        // Assert
        expect(result, testToken);
      });
    });
  });
}
