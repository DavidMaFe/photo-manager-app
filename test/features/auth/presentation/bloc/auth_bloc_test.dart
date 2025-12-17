import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    final testUser = User(
      id: '1',
      email: testEmail,
      name: 'John',
      surname: 'Doe',
    );

    test('initial state should be AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    group('LoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthSuccessful] when login succeeds',
        build: () {
          when(() => mockLoginUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(LoginRequested(
          email: testEmail,
          password: testPassword,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccessful>().having(
            (state) => state.user,
            'user',
            testUser,
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should call loginUseCase with correct parameters',
        build: () {
          when(() => mockLoginUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(LoginRequested(
          email: testEmail,
          password: testPassword,
        )),
        wait: const Duration(milliseconds: 900),
        verify: (_) {
          verify(() => mockLoginUseCase(
                email: testEmail,
                password: testPassword,
              )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when login fails',
        build: () {
          when(() => mockLoginUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenThrow(Exception('Invalid credentials'));
          return authBloc;
        },
        act: (bloc) => bloc.add(LoginRequested(
          email: testEmail,
          password: testPassword,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.failure,
            'failure',
            isA<Failure>(),
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should convert exception to Failure via ErrorHandler',
        build: () {
          when(() => mockLoginUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenThrow(Exception('Email or password are not correct'));
          return authBloc;
        },
        act: (bloc) => bloc.add(LoginRequested(
          email: testEmail,
          password: testPassword,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
        verify: (_) {
          // ErrorHandler.handleError should be called internally
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should respect minimum loading duration of 800ms',
        build: () {
          when(() => mockLoginUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(LoginRequested(
          email: testEmail,
          password: testPassword,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccessful>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should handle validation errors from use case',
        build: () {
          when(() => mockLoginUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenThrow(Exception('Email is required'));
          return authBloc;
        },
        act: (bloc) => bloc.add(LoginRequested(
          email: '',
          password: testPassword,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );
    });

    group('LogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [NotAuthenticated] when logout succeeds',
        build: () {
          when(() => mockLogoutUseCase()).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(LogoutRequested()),
        expect: () => [
          isA<NotAuthenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should call logoutUseCase',
        build: () {
          when(() => mockLogoutUseCase()).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(LogoutRequested()),
        verify: (_) {
          verify(() => mockLogoutUseCase()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthError] when logout fails',
        build: () {
          when(() => mockLogoutUseCase())
              .thenThrow(Exception('Logout failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(LogoutRequested()),
        expect: () => [
          isA<AuthError>().having(
            (state) => state.failure,
            'failure',
            isA<Failure>(),
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should not emit loading state for logout',
        build: () {
          when(() => mockLogoutUseCase()).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(LogoutRequested()),
        expect: () => [
          isA<NotAuthenticated>(),
        ],
        verify: (_) {
          // Ensure no AuthLoading was emitted
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should handle network errors during logout',
        build: () {
          when(() => mockLogoutUseCase())
              .thenThrow(Exception('Network error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(LogoutRequested()),
        expect: () => [
          isA<AuthError>(),
        ],
      );
    });

    group('CheckAuthStatus', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthSuccessful] when user and token exist',
        build: () {
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => testUser);
          when(() => mockAuthRepository.hasToken())
              .thenAnswer((_) async => true);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatus()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccessful>().having(
            (state) => state.user,
            'user',
            testUser,
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, NotAuthenticated] when token is missing',
        build: () {
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => testUser);
          when(() => mockAuthRepository.hasToken())
              .thenAnswer((_) async => false);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatus()),
        expect: () => [
          isA<AuthLoading>(),
          isA<NotAuthenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, NotAuthenticated] when user is null',
        build: () {
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => null);
          when(() => mockAuthRepository.hasToken())
              .thenAnswer((_) async => true);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatus()),
        expect: () => [
          isA<AuthLoading>(),
          isA<NotAuthenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, NotAuthenticated] when both are missing',
        build: () {
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => null);
          when(() => mockAuthRepository.hasToken())
              .thenAnswer((_) async => false);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatus()),
        expect: () => [
          isA<AuthLoading>(),
          isA<NotAuthenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, NotAuthenticated] when exception occurs',
        build: () {
          when(() => mockAuthRepository.getCurrentUser())
              .thenThrow(Exception('Error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatus()),
        expect: () => [
          isA<AuthLoading>(),
          isA<NotAuthenticated>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should check both user and token before emitting success',
        build: () {
          when(() => mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => testUser);
          when(() => mockAuthRepository.hasToken())
              .thenAnswer((_) async => true);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatus()),
        verify: (_) {
          verify(() => mockAuthRepository.getCurrentUser()).called(1);
          verify(() => mockAuthRepository.hasToken()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should gracefully handle errors by defaulting to not authenticated',
        build: () {
          when(() => mockAuthRepository.getCurrentUser())
              .thenThrow(Exception('Cache corrupted'));
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckAuthStatus()),
        expect: () => [
          isA<AuthLoading>(),
          isA<NotAuthenticated>(),
        ],
      );
    });

    group('Multiple events', () {
      blocTest<AuthBloc, AuthState>(
        'should transition from authenticated to not authenticated on logout',
        build: () {
          when(() => mockLoginUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => testUser);
          when(() => mockLogoutUseCase()).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) async {
          bloc.add(LoginRequested(email: testEmail, password: testPassword));
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(LogoutRequested());
        },
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccessful>(),
          isA<NotAuthenticated>(),
        ],
      );
    });
  });
}
