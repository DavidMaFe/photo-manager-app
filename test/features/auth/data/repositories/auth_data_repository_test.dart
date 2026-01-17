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

    group('requestPasswordReset', () {
      test('should delegate to remote data source with email', () async {
        // Arrange
        when(() => mockRemoteDataSource.requestPasswordReset(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.requestPasswordReset(testEmail);

        // Assert
        verify(() => mockRemoteDataSource.requestPasswordReset(testEmail))
            .called(1);
      });

      test('should complete successfully when remote call succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.requestPasswordReset(any()))
            .thenAnswer((_) async => {});

        // Act & Assert - should not throw
        await expectLater(
            repository.requestPasswordReset(testEmail), completes);
      });

      test('should propagate exceptions from remote data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.requestPasswordReset(any()))
            .thenThrow(Exception('Email not found'));

        // Act & Assert
        expect(
          () => repository.requestPasswordReset(testEmail),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Email not found')),
          ),
        );
      });
    });

    group('validateResetCode', () {
      const testCode = '123456';

      test('should delegate to remote data source with email and code',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.validateResetCode(any(), any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.validateResetCode(testEmail, testCode);

        // Assert
        verify(() =>
                mockRemoteDataSource.validateResetCode(testEmail, testCode))
            .called(1);
      });

      test('should complete successfully when remote call succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.validateResetCode(any(), any()))
            .thenAnswer((_) async => {});

        // Act & Assert - should not throw
        await expectLater(
            repository.validateResetCode(testEmail, testCode), completes);
      });

      test('should propagate exceptions from remote data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.validateResetCode(any(), any()))
            .thenThrow(Exception('Invalid code'));

        // Act & Assert
        expect(
          () => repository.validateResetCode(testEmail, testCode),
          throwsA(
            predicate(
                (e) => e is Exception && e.toString().contains('Invalid code')),
          ),
        );
      });
    });

    group('resetPassword', () {
      const testCode = '123456';
      const testNewPassword = 'newPassword123';

      test('should delegate to remote data source with all parameters',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.resetPassword(any(), any(), any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.resetPassword(testEmail, testCode, testNewPassword);

        // Assert
        verify(() => mockRemoteDataSource.resetPassword(
            testEmail, testCode, testNewPassword)).called(1);
      });

      test('should complete successfully when remote call succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.resetPassword(any(), any(), any()))
            .thenAnswer((_) async => {});

        // Act & Assert - should not throw
        await expectLater(
            repository.resetPassword(testEmail, testCode, testNewPassword),
            completes);
      });

      test('should propagate exceptions from remote data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.resetPassword(any(), any(), any()))
            .thenThrow(Exception('Password reset failed'));

        // Act & Assert
        expect(
          () => repository.resetPassword(testEmail, testCode, testNewPassword),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString().contains('Password reset failed')),
          ),
        );
      });
    });

    group('register', () {
      const testName = 'John';
      const testSurname = 'Doe';

      test('should delegate to remote data source with all parameters',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.register(
              any(),
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await repository.register(
          email: testEmail,
          password: testPassword,
          name: testName,
          surname: testSurname,
        );

        // Assert
        verify(() => mockRemoteDataSource.register(
              testEmail,
              testPassword,
              testName,
              testSurname,
            )).called(1);
      });

      test('should delegate to remote data source without surname', () async {
        // Arrange
        when(() => mockRemoteDataSource.register(
              any(),
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await repository.register(
          email: testEmail,
          password: testPassword,
          name: testName,
          surname: null,
        );

        // Assert
        verify(() => mockRemoteDataSource.register(
              testEmail,
              testPassword,
              testName,
              null,
            )).called(1);
      });

      test('should complete successfully when remote call succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.register(
              any(),
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act & Assert - should not throw
        await expectLater(
            repository.register(
              email: testEmail,
              password: testPassword,
              name: testName,
              surname: testSurname,
            ),
            completes);
      });

      test('should NOT cache token after successful registration', () async {
        // Arrange
        when(() => mockRemoteDataSource.register(
              any(),
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await repository.register(
          email: testEmail,
          password: testPassword,
          name: testName,
          surname: testSurname,
        );

        // Assert - no caching should occur
        verifyNever(() => mockLocalDataSource.cacheToken(any()));
      });

      test('should NOT cache user after successful registration', () async {
        // Arrange
        when(() => mockRemoteDataSource.register(
              any(),
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await repository.register(
          email: testEmail,
          password: testPassword,
          name: testName,
          surname: testSurname,
        );

        // Assert - no caching should occur
        verifyNever(() => mockLocalDataSource.cacheUser(any()));
      });

      test('should propagate exceptions from remote data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.register(
              any(),
              any(),
              any(),
              any(),
            )).thenThrow(Exception('Email already registered'));

        // Act & Assert
        expect(
          () => repository.register(
            email: testEmail,
            password: testPassword,
            name: testName,
            surname: testSurname,
          ),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString().contains('Email already registered')),
          ),
        );

        // Ensure no caching occurs on error
        verifyNever(() => mockLocalDataSource.cacheToken(any()));
        verifyNever(() => mockLocalDataSource.cacheUser(any()));
      });

      test('should not cache anything if remote call fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.register(
              any(),
              any(),
              any(),
              any(),
            )).thenThrow(Exception('Network error'));

        // Act & Assert
        await expectLater(
          repository.register(
            email: testEmail,
            password: testPassword,
            name: testName,
            surname: testSurname,
          ),
          throwsException,
        );

        verifyNever(() => mockLocalDataSource.cacheToken(any()));
        verifyNever(() => mockLocalDataSource.cacheUser(any()));
      });
    });
  });
}
