import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:photo_manager_app/features/auth/data/models/auth_response_model.dart';
import 'package:photo_manager_app/features/auth/data/models/user_model.dart';
import 'package:photo_manager_app/features/auth/data/repositories/auth_data_repository.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_local_data_source.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockProfileLocalDataSource extends Mock
    implements ProfileLocalDataSource {}

class FakeUserModel extends Fake implements UserModel {}

void main() {
  late AuthDataRepository repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockProfileLocalDataSource mockProfileLocalDataSource;

  setUpAll(() {
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockProfileLocalDataSource = MockProfileLocalDataSource();
    repository = AuthDataRepository(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      profileLocalDataSource: mockProfileLocalDataSource,
    );
  });

  group('AuthDataRepository', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testToken = 'test_token_123';

    final testUser = UserModel(
      id: '1',
      email: testEmail,
      name: 'John',
      surname: 'Doe',
    );

    final testAuthResponse = AuthResponseModel(
      token: testToken,
      user: testUser,
    );

    group('login', () {
      test('should call remote data source with correct credentials',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.login(any(), any()))
            .thenAnswer((_) async => testAuthResponse);
        when(() => mockLocalDataSource.cacheToken(any()))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.cacheUser(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.login(email: testEmail, password: testPassword);

        // Assert
        verify(() => mockRemoteDataSource.login(testEmail, testPassword))
            .called(1);
      });

      test('should cache token after successful login', () async {
        // Arrange
        when(() => mockRemoteDataSource.login(any(), any()))
            .thenAnswer((_) async => testAuthResponse);
        when(() => mockLocalDataSource.cacheToken(any()))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.cacheUser(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.login(email: testEmail, password: testPassword);

        // Assert
        verify(() => mockLocalDataSource.cacheToken(testToken)).called(1);
      });

      test('should cache user after successful login', () async {
        // Arrange
        when(() => mockRemoteDataSource.login(any(), any()))
            .thenAnswer((_) async => testAuthResponse);
        when(() => mockLocalDataSource.cacheToken(any()))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.cacheUser(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.login(email: testEmail, password: testPassword);

        // Assert
        verify(() => mockLocalDataSource.cacheUser(testUser)).called(1);
      });

      test('should return user from auth response', () async {
        // Arrange
        when(() => mockRemoteDataSource.login(any(), any()))
            .thenAnswer((_) async => testAuthResponse);
        when(() => mockLocalDataSource.cacheToken(any()))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.cacheUser(any()))
            .thenAnswer((_) async => {});

        // Act
        final result =
            await repository.login(email: testEmail, password: testPassword);

        // Assert
        expect(result, testUser);
        expect(result.id, testUser.id);
        expect(result.email, testUser.email);
      });

      test('should cache both token and user in correct order', () async {
        // Arrange
        final callOrder = <String>[];
        when(() => mockRemoteDataSource.login(any(), any()))
            .thenAnswer((_) async => testAuthResponse);
        when(() => mockLocalDataSource.cacheToken(any())).thenAnswer((_) async {
          callOrder.add('token');
        });
        when(() => mockLocalDataSource.cacheUser(any())).thenAnswer((_) async {
          callOrder.add('user');
        });

        // Act
        await repository.login(email: testEmail, password: testPassword);

        // Assert
        expect(callOrder, ['token', 'user']);
      });

      test('should propagate exceptions from remote data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.login(any(), any()))
            .thenThrow(Exception('Invalid credentials'));

        // Act & Assert
        expect(
          () => repository.login(email: testEmail, password: testPassword),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString().contains('Invalid credentials')),
          ),
        );

        // Cache should not be called if login fails
        verifyNever(() => mockLocalDataSource.cacheToken(any()));
        verifyNever(() => mockLocalDataSource.cacheUser(any()));
      });

      test('should not cache if remote call fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.login(any(), any()))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        await expectLater(
          repository.login(email: testEmail, password: testPassword),
          throwsException,
        );

        verifyNever(() => mockLocalDataSource.cacheToken(any()));
        verifyNever(() => mockLocalDataSource.cacheUser(any()));
      });
    });

    group('logout', () {
      test('should get token from local storage', () async {
        // Arrange
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockRemoteDataSource.logout(any()))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async => {});
        when(() => mockProfileLocalDataSource.clearProfileCache())
            .thenAnswer((_) async => {});

        // Act
        await repository.logout();

        // Assert
        verify(() => mockLocalDataSource.getToken()).called(1);
      });

      test('should call remote logout with token when token exists', () async {
        // Arrange
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockRemoteDataSource.logout(any()))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async => {});
        when(() => mockProfileLocalDataSource.clearProfileCache())
            .thenAnswer((_) async => {});

        // Act
        await repository.logout();

        // Assert
        verify(() => mockRemoteDataSource.logout(testToken)).called(1);
      });

      test('should clear auth cache after remote logout', () async {
        // Arrange
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockRemoteDataSource.logout(any()))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async => {});
        when(() => mockProfileLocalDataSource.clearProfileCache())
            .thenAnswer((_) async => {});

        // Act
        await repository.logout();

        // Assert
        verify(() => mockLocalDataSource.clearCache()).called(1);
      });

      test('should clear profile cache after remote logout', () async {
        // Arrange
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockRemoteDataSource.logout(any()))
            .thenAnswer((_) async => {});
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async => {});
        when(() => mockProfileLocalDataSource.clearProfileCache())
            .thenAnswer((_) async => {});

        // Act
        await repository.logout();

        // Assert
        verify(() => mockProfileLocalDataSource.clearProfileCache()).called(1);
      });

      test('should not call remote logout when token is null', () async {
        // Arrange
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => null);

        // Act
        await repository.logout();

        // Assert
        verifyNever(() => mockRemoteDataSource.logout(any()));
        verifyNever(() => mockLocalDataSource.clearCache());
        verifyNever(() => mockProfileLocalDataSource.clearProfileCache());
      });

      test('should not call remote logout when token is empty', () async {
        // Arrange
        when(() => mockLocalDataSource.getToken()).thenAnswer((_) async => '');

        // Act
        await repository.logout();

        // Assert
        verifyNever(() => mockRemoteDataSource.logout(any()));
        verifyNever(() => mockLocalDataSource.clearCache());
        verifyNever(() => mockProfileLocalDataSource.clearProfileCache());
      });

      test('should clear caches even when remote logout fails', () async {
        // Arrange
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockRemoteDataSource.logout(any()))
            .thenThrow(Exception('Network error'));
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async => {});
        when(() => mockProfileLocalDataSource.clearProfileCache())
            .thenAnswer((_) async => {});

        // Act
        await repository.logout();

        // Assert
        verify(() => mockLocalDataSource.clearCache()).called(1);
        verify(() => mockProfileLocalDataSource.clearProfileCache()).called(1);
      });

      test('should clear both caches in error handler', () async {
        // Arrange
        final callOrder = <String>[];
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockRemoteDataSource.logout(any()))
            .thenThrow(Exception('Error'));
        when(() => mockLocalDataSource.clearCache()).thenAnswer((_) async {
          callOrder.add('auth');
        });
        when(() => mockProfileLocalDataSource.clearProfileCache())
            .thenAnswer((_) async {
          callOrder.add('profile');
        });

        // Act
        await repository.logout();

        // Assert
        expect(callOrder, containsAll(['auth', 'profile']));
      });

      test('should not throw exception even if remote logout fails', () async {
        // Arrange
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockRemoteDataSource.logout(any()))
            .thenThrow(Exception('Server error'));
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async => {});
        when(() => mockProfileLocalDataSource.clearProfileCache())
            .thenAnswer((_) async => {});

        // Act & Assert - should not throw
        await expectLater(repository.logout(), completes);
      });
    });

    group('getCurrentUser', () {
      test('should return cached user when user and token exist', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => testUser);
        when(() => mockLocalDataSource.hasValidToken())
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, testUser);
      });

      test('should return null when cached user does not exist', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => null);
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNull);
      });

      test('should return null and clear cache when token is invalid',
          () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => testUser);
        when(() => mockLocalDataSource.hasValidToken())
            .thenAnswer((_) async => false);
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNull);
        verify(() => mockLocalDataSource.clearCache()).called(1);
      });

      test('should clear cache when user exists but token is invalid',
          () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => testUser);
        when(() => mockLocalDataSource.hasValidToken())
            .thenAnswer((_) async => false);
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async => {});

        // Act
        await repository.getCurrentUser();

        // Assert
        verify(() => mockLocalDataSource.clearCache()).called(1);
      });

      test('should check both user and token validity', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => testUser);
        when(() => mockLocalDataSource.hasValidToken())
            .thenAnswer((_) async => true);

        // Act
        await repository.getCurrentUser();

        // Assert
        verify(() => mockLocalDataSource.getCachedUser()).called(1);
        verify(() => mockLocalDataSource.hasValidToken()).called(1);
      });

      test('should not check token validity when user is null', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedUser())
            .thenAnswer((_) async => null);
        when(() => mockLocalDataSource.clearCache())
            .thenAnswer((_) async => {});

        // Act
        await repository.getCurrentUser();

        // Assert - short-circuit evaluation, token check should not happen
        verify(() => mockLocalDataSource.getCachedUser()).called(1);
        verify(() => mockLocalDataSource.clearCache()).called(1);
      });
    });

    group('hasToken', () {
      test('should return true when valid token exists', () async {
        // Arrange
        when(() => mockLocalDataSource.hasValidToken())
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.hasToken();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when no valid token exists', () async {
        // Arrange
        when(() => mockLocalDataSource.hasValidToken())
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.hasToken();

        // Assert
        expect(result, isFalse);
      });

      test('should delegate to local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.hasValidToken())
            .thenAnswer((_) async => true);

        // Act
        await repository.hasToken();

        // Assert
        verify(() => mockLocalDataSource.hasValidToken()).called(1);
      });
    });
  });
}
