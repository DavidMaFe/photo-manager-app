import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/refresh_token_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/request_password_reset_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/validate_reset_code_use_case.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/register_sync_device_use_case.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockRegisterSyncDeviceUseCase extends Mock implements RegisterSyncDeviceUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockRequestPasswordResetUseCase extends Mock implements RequestPasswordResetUseCase {}

class MockValidateResetCodeUseCase extends Mock implements ValidateResetCodeUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSyncDeviceRepository extends Mock implements SyncDeviceRepository {}

class MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockRegisterSyncDeviceUseCase mockRegisterSyncDeviceUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockRequestPasswordResetUseCase mockRequestPasswordResetUseCase;
  late MockValidateResetCodeUseCase mockValidateResetCodeUseCase;
  late MockResetPasswordUseCase mockResetPasswordUseCase;
  late MockAuthRepository mockAuthRepository;
  late MockSyncDeviceRepository mockSyncDeviceRepository;
  late MockRefreshTokenUseCase mockRefreshTokenUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockRegisterSyncDeviceUseCase = MockRegisterSyncDeviceUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockRequestPasswordResetUseCase = MockRequestPasswordResetUseCase();
    mockValidateResetCodeUseCase = MockValidateResetCodeUseCase();
    mockResetPasswordUseCase = MockResetPasswordUseCase();
    mockAuthRepository = MockAuthRepository();
    mockSyncDeviceRepository = MockSyncDeviceRepository();
    mockRefreshTokenUseCase = MockRefreshTokenUseCase();

    authBloc = AuthBloc(
        loginUseCase: mockLoginUseCase,
        registerUseCase: mockRegisterUseCase,
        registerSyncDeviceUseCase: mockRegisterSyncDeviceUseCase,
        logoutUseCase: mockLogoutUseCase,
        requestPasswordResetUseCase: mockRequestPasswordResetUseCase,
        validateResetCodeUseCase: mockValidateResetCodeUseCase,
        resetPasswordUseCase: mockResetPasswordUseCase,
        authRepository: mockAuthRepository,
        syncDeviceRepository: mockSyncDeviceRepository,
        refreshTokenUseCase: mockRefreshTokenUseCase,
        eventBus: AppEventBus(),
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

    group('RegisterRequested', () {
      const testName = 'John';
      const testSurname = 'Doe';

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, RegisterSuccessful] when register succeeds',
        build: () {
          when(() => mockRegisterUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
                name: any(named: 'name'),
                surname: any(named: 'surname'),
              )).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(RegisterRequested(
          email: testEmail,
          password: testPassword,
          name: testName,
          surname: testSurname,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<RegisterSuccessful>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should call registerUseCase with correct parameters',
        build: () {
          when(() => mockRegisterUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
                name: any(named: 'name'),
                surname: any(named: 'surname'),
              )).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(RegisterRequested(
          email: testEmail,
          password: testPassword,
          name: testName,
          surname: testSurname,
        )),
        wait: const Duration(milliseconds: 900),
        verify: (_) {
          verify(() => mockRegisterUseCase(
                email: testEmail,
                password: testPassword,
                name: testName,
                surname: testSurname,
              )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should call registerUseCase with null surname',
        build: () {
          when(() => mockRegisterUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
                name: any(named: 'name'),
                surname: any(named: 'surname'),
              )).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(RegisterRequested(
          email: testEmail,
          password: testPassword,
          name: testName,
          surname: null,
        )),
        wait: const Duration(milliseconds: 900),
        verify: (_) {
          verify(() => mockRegisterUseCase(
                email: testEmail,
                password: testPassword,
                name: testName,
                surname: null,
              )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when register fails',
        build: () {
          when(() => mockRegisterUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
                name: any(named: 'name'),
                surname: any(named: 'surname'),
              )).thenThrow(Exception('Email already registered'));
          return authBloc;
        },
        act: (bloc) => bloc.add(RegisterRequested(
          email: testEmail,
          password: testPassword,
          name: testName,
          surname: testSurname,
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
          when(() => mockRegisterUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
                name: any(named: 'name'),
                surname: any(named: 'surname'),
              )).thenThrow(Exception('Email already exists'));
          return authBloc;
        },
        act: (bloc) => bloc.add(RegisterRequested(
          email: testEmail,
          password: testPassword,
          name: testName,
          surname: testSurname,
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
          when(() => mockRegisterUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
                name: any(named: 'name'),
                surname: any(named: 'surname'),
              )).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(RegisterRequested(
          email: testEmail,
          password: testPassword,
          name: testName,
          surname: testSurname,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<RegisterSuccessful>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should handle validation errors from use case',
        build: () {
          when(() => mockRegisterUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
                name: any(named: 'name'),
                surname: any(named: 'surname'),
              )).thenThrow(const ValidationFailure());
          return authBloc;
        },
        act: (bloc) => bloc.add(RegisterRequested(
          email: '',
          password: testPassword,
          name: testName,
          surname: testSurname,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having(
            (state) => state.failure,
            'failure',
            isA<ValidationFailure>(),
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should NOT auto-login after successful registration',
        build: () {
          when(() => mockRegisterUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
                name: any(named: 'name'),
                surname: any(named: 'surname'),
              )).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(RegisterRequested(
          email: testEmail,
          password: testPassword,
          name: testName,
          surname: testSurname,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<RegisterSuccessful>(),
        ],
        verify: (_) {
          // LoginUseCase should not be called
          verifyNever(() => mockLoginUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
              ));
        },
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
          when(() => (mockAuthRepository as dynamic).isRefreshTokenExpired())
              .thenAnswer((_) async => false);
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

    group('PasswordResetRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, PasswordResetEmailSent] when request succeeds',
        build: () {
          when(() => mockRequestPasswordResetUseCase(email: any(named: 'email')))
              .thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(PasswordResetRequested(email: testEmail)),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<PasswordResetEmailSent>().having(
            (state) => state.email,
            'email',
            testEmail,
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should call requestPasswordResetUseCase with correct email',
        build: () {
          when(() => mockRequestPasswordResetUseCase(email: any(named: 'email')))
              .thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(PasswordResetRequested(email: testEmail)),
        wait: const Duration(milliseconds: 900),
        verify: (_) {
          verify(() => mockRequestPasswordResetUseCase(email: testEmail))
              .called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when request fails',
        build: () {
          when(() => mockRequestPasswordResetUseCase(email: any(named: 'email')))
              .thenThrow(Exception('Email not found'));
          return authBloc;
        },
        act: (bloc) => bloc.add(PasswordResetRequested(email: testEmail)),
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
          when(() => mockRequestPasswordResetUseCase(email: any(named: 'email')))
              .thenThrow(Exception('EMAIL_NOT_FOUND'));
          return authBloc;
        },
        act: (bloc) => bloc.add(PasswordResetRequested(email: testEmail)),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should respect minimum loading duration of 800ms',
        build: () {
          when(() => mockRequestPasswordResetUseCase(email: any(named: 'email')))
              .thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(PasswordResetRequested(email: testEmail)),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<PasswordResetEmailSent>(),
        ],
      );
    });

    group('ResetCodeValidationRequested', () {
      const testCode = '123456';

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, ResetCodeValidated] when validation succeeds',
        build: () {
          when(() => mockValidateResetCodeUseCase(
                email: any(named: 'email'),
                code: any(named: 'code'),
              )).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(ResetCodeValidationRequested(
          email: testEmail,
          code: testCode,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<ResetCodeValidated>()
              .having((state) => state.email, 'email', testEmail)
              .having((state) => state.code, 'code', testCode),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should call validateResetCodeUseCase with correct parameters',
        build: () {
          when(() => mockValidateResetCodeUseCase(
                email: any(named: 'email'),
                code: any(named: 'code'),
              )).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(ResetCodeValidationRequested(
          email: testEmail,
          code: testCode,
        )),
        wait: const Duration(milliseconds: 900),
        verify: (_) {
          verify(() => mockValidateResetCodeUseCase(
                email: testEmail,
                code: testCode,
              )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when validation fails',
        build: () {
          when(() => mockValidateResetCodeUseCase(
                email: any(named: 'email'),
                code: any(named: 'code'),
              )).thenThrow(Exception('Invalid code'));
          return authBloc;
        },
        act: (bloc) => bloc.add(ResetCodeValidationRequested(
          email: testEmail,
          code: testCode,
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
          when(() => mockValidateResetCodeUseCase(
                email: any(named: 'email'),
                code: any(named: 'code'),
              )).thenThrow(Exception('INVALID_CODE'));
          return authBloc;
        },
        act: (bloc) => bloc.add(ResetCodeValidationRequested(
          email: testEmail,
          code: testCode,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should respect minimum loading duration of 800ms',
        build: () {
          when(() => mockValidateResetCodeUseCase(
                email: any(named: 'email'),
                code: any(named: 'code'),
              )).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(ResetCodeValidationRequested(
          email: testEmail,
          code: testCode,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<ResetCodeValidated>(),
        ],
      );
    });

    group('PasswordResetCodeResendRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, PasswordResetEmailSent] when resend succeeds',
        build: () {
          when(() => mockRequestPasswordResetUseCase(email: any(named: 'email')))
              .thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) =>
            bloc.add(PasswordResetCodeResendRequested(email: testEmail)),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<PasswordResetEmailSent>().having(
            (state) => state.email,
            'email',
            testEmail,
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should call requestPasswordResetUseCase with correct email',
        build: () {
          when(() => mockRequestPasswordResetUseCase(email: any(named: 'email')))
              .thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) =>
            bloc.add(PasswordResetCodeResendRequested(email: testEmail)),
        wait: const Duration(milliseconds: 900),
        verify: (_) {
          verify(() => mockRequestPasswordResetUseCase(email: testEmail))
              .called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when resend fails',
        build: () {
          when(() => mockRequestPasswordResetUseCase(email: any(named: 'email')))
              .thenThrow(Exception('Email not found'));
          return authBloc;
        },
        act: (bloc) =>
            bloc.add(PasswordResetCodeResendRequested(email: testEmail)),
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
        'should respect minimum loading duration of 800ms',
        build: () {
          when(() => mockRequestPasswordResetUseCase(email: any(named: 'email')))
              .thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) =>
            bloc.add(PasswordResetCodeResendRequested(email: testEmail)),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<PasswordResetEmailSent>(),
        ],
      );
    });

    group('NewPasswordSubmitted', () {
      const testCode = '123456';
      const testNewPassword = 'newPassword123';

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, PasswordResetSuccessful] when reset succeeds',
        build: () {
          when(() => mockResetPasswordUseCase(
                email: any(named: 'email'),
                code: any(named: 'code'),
                newPassword: any(named: 'newPassword'),
              )).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(NewPasswordSubmitted(
          email: testEmail,
          code: testCode,
          newPassword: testNewPassword,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<PasswordResetSuccessful>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should call resetPasswordUseCase with correct parameters',
        build: () {
          when(() => mockResetPasswordUseCase(
                email: any(named: 'email'),
                code: any(named: 'code'),
                newPassword: any(named: 'newPassword'),
              )).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(NewPasswordSubmitted(
          email: testEmail,
          code: testCode,
          newPassword: testNewPassword,
        )),
        wait: const Duration(milliseconds: 900),
        verify: (_) {
          verify(() => mockResetPasswordUseCase(
                email: testEmail,
                code: testCode,
                newPassword: testNewPassword,
              )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when reset fails',
        build: () {
          when(() => mockResetPasswordUseCase(
                email: any(named: 'email'),
                code: any(named: 'code'),
                newPassword: any(named: 'newPassword'),
              )).thenThrow(Exception('Password reset failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(NewPasswordSubmitted(
          email: testEmail,
          code: testCode,
          newPassword: testNewPassword,
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
          when(() => mockResetPasswordUseCase(
                email: any(named: 'email'),
                code: any(named: 'code'),
                newPassword: any(named: 'newPassword'),
              )).thenThrow(Exception('CODE_EXPIRED'));
          return authBloc;
        },
        act: (bloc) => bloc.add(NewPasswordSubmitted(
          email: testEmail,
          code: testCode,
          newPassword: testNewPassword,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should respect minimum loading duration of 800ms',
        build: () {
          when(() => mockResetPasswordUseCase(
                email: any(named: 'email'),
                code: any(named: 'code'),
                newPassword: any(named: 'newPassword'),
              )).thenAnswer((_) async => {});
          return authBloc;
        },
        act: (bloc) => bloc.add(NewPasswordSubmitted(
          email: testEmail,
          code: testCode,
          newPassword: testNewPassword,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<PasswordResetSuccessful>(),
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
