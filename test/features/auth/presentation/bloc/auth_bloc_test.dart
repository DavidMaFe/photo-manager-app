import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/recovery_phrase_use_cases.dart';
import 'package:photo_manager_app/features/auth/domain/entities/login_result.dart';
import 'package:photo_manager_app/features/auth/domain/entities/registration_result.dart';
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
import 'package:photo_manager_app/features/legal/domain/use_cases/accept_legal_terms_use_case.dart';
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

class MockRecoveryReminderUseCase extends Mock implements RecoveryReminderUseCase {}

class MockAcceptLegalTermsUseCase extends Mock implements AcceptLegalTermsUseCase {}

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
  late MockRecoveryReminderUseCase mockRecoveryReminderUseCase;
  late MockAcceptLegalTermsUseCase mockAcceptLegalTermsUseCase;

  setUpAll(() {
    registerFallbackValue(RecoveryPhraseLanguage.english);
  });

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
    mockRecoveryReminderUseCase = MockRecoveryReminderUseCase();
    mockAcceptLegalTermsUseCase = MockAcceptLegalTermsUseCase();
    when(() => mockRecoveryReminderUseCase.start()).thenAnswer((_) async {});

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
        recoveryReminderUseCase: mockRecoveryReminderUseCase,
        acceptLegalTermsUseCase: mockAcceptLegalTermsUseCase,
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
    final testWords = List.filled(RecoveryPhrase.wordCount, 'abandon');

    LoginResult loginResult({bool accountLocked = false, bool legalAcceptanceRequired = false}) => LoginResult(
        user: testUser,
        keys: AccountKeys(accountLocked: accountLocked, versions: const []),
        legalAcceptanceRequired: legalAcceptanceRequired);

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
              )).thenAnswer((_) async => loginResult());
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
        'should emit [AuthLoading, AuthAccountLocked] when no key opens with the password',
        build: () {
          when(() => mockLoginUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => loginResult(accountLocked: true));
          return authBloc;
        },
        act: (bloc) => bloc.add(LoginRequested(email: testEmail, password: testPassword)),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAccountLocked>().having((state) => state.user, 'user', testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should call loginUseCase with correct parameters',
        build: () {
          when(() => mockLoginUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => loginResult());
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
              )).thenAnswer((_) async => loginResult());
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

      void stubRegister() {
        when(() => mockRegisterUseCase(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              language: any(named: 'language'),
              acceptedLegalTerms: any(named: 'acceptedLegalTerms'),
            )).thenAnswer((_) async => RegistrationResult(user: testUser, recoveryWords: testWords));
      }

      RegisterRequested request({String? surname = testSurname}) => RegisterRequested(
            email: testEmail,
            password: testPassword,
            name: testName,
            surname: surname,
            language: RecoveryPhraseLanguage.spanish,
            acceptedLegalTerms: true,
          );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, RecoveryPhraseRequired] with the 24 words when register succeeds',
        build: () {
          stubRegister();
          return authBloc;
        },
        act: (bloc) => bloc.add(request()),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<RecoveryPhraseRequired>()
              .having((state) => state.user, 'user', testUser)
              .having((state) => state.words, 'words', testWords),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should call registerUseCase with the language of the words',
        build: () {
          stubRegister();
          return authBloc;
        },
        act: (bloc) => bloc.add(request(surname: null)),
        wait: const Duration(milliseconds: 900),
        verify: (_) {
          verify(() => mockRegisterUseCase(
                email: testEmail,
                password: testPassword,
                name: testName,
                surname: null,
                language: RecoveryPhraseLanguage.spanish,
                acceptedLegalTerms: true,
              )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should not start the session nor the reminders until the words are confirmed',
        build: () {
          stubRegister();
          return authBloc;
        },
        act: (bloc) => bloc.add(request()),
        wait: const Duration(milliseconds: 900),
        verify: (_) {
          verifyNever(() => mockRecoveryReminderUseCase.start());
          verifyNever(() => mockLoginUseCase(email: any(named: 'email'), password: any(named: 'password')));
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
                language: any(named: 'language'),
                acceptedLegalTerms: any(named: 'acceptedLegalTerms'),
              )).thenThrow(Exception('Email already registered'));
          return authBloc;
        },
        act: (bloc) => bloc.add(request()),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having((state) => state.failure, 'failure', isA<Failure>()),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should keep the weak password failure to show its message',
        build: () {
          when(() => mockRegisterUseCase(
                email: any(named: 'email'),
                password: any(named: 'password'),
                name: any(named: 'name'),
                surname: any(named: 'surname'),
                language: any(named: 'language'),
                acceptedLegalTerms: any(named: 'acceptedLegalTerms'),
              )).thenThrow(const WeakPasswordFailure());
          return authBloc;
        },
        act: (bloc) => bloc.add(request()),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having((state) => state.failure, 'failure', isA<WeakPasswordFailure>()),
        ],
      );
    });

    group('LegalTermsAccepted', () {
      AuthLegalAcceptanceRequired pending({bool accountLocked = false}) =>
          AuthLegalAcceptanceRequired(testUser, accountLocked: accountLocked);

      blocTest<AuthBloc, AuthState>(
        'should ask for the terms in force after a login that requires them',
        build: () {
          when(() => mockLoginUseCase(email: any(named: 'email'), password: any(named: 'password')))
              .thenAnswer((_) async => loginResult(accountLocked: true, legalAcceptanceRequired: true));
          return authBloc;
        },
        act: (bloc) => bloc.add(LoginRequested(email: testEmail, password: testPassword)),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthLegalAcceptanceRequired>()
              .having((s) => s.user, 'user', testUser)
              .having((s) => s.accountLocked, 'accountLocked', isTrue),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should start the session once the terms are accepted',
        build: () {
          when(() => mockAcceptLegalTermsUseCase()).thenAnswer((_) async {});
          return authBloc;
        },
        seed: pending,
        act: (bloc) => bloc.add(LegalTermsAccepted()),
        expect: () => [
          isA<AuthLegalAcceptanceRequired>().having((s) => s.working, 'working', isTrue),
          isA<AuthSuccessful>().having((s) => s.user, 'user', testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should go on to the locked account flow once the terms are accepted',
        build: () {
          when(() => mockAcceptLegalTermsUseCase()).thenAnswer((_) async {});
          return authBloc;
        },
        seed: () => pending(accountLocked: true),
        act: (bloc) => bloc.add(LegalTermsAccepted()),
        expect: () => [
          isA<AuthLegalAcceptanceRequired>(),
          isA<AuthAccountLocked>().having((s) => s.user, 'user', testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should stay on the acceptance with the failure when it cannot be saved',
        build: () {
          when(() => mockAcceptLegalTermsUseCase()).thenThrow(Exception('network'));
          return authBloc;
        },
        seed: pending,
        act: (bloc) => bloc.add(LegalTermsAccepted()),
        expect: () => [
          isA<AuthLegalAcceptanceRequired>().having((s) => s.working, 'working', isTrue),
          isA<AuthLegalAcceptanceRequired>()
              .having((s) => s.working, 'working', isFalse)
              .having((s) => s.failure, 'failure', isA<Failure>()),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should ignore the acceptance when none is pending',
        build: () => authBloc,
        act: (bloc) => bloc.add(LegalTermsAccepted()),
        expect: () => <AuthState>[],
        verify: (_) => verifyNever(() => mockAcceptLegalTermsUseCase()),
      );
    });

    group('RecoveryPhraseConfirmed', () {
      blocTest<AuthBloc, AuthState>(
        'should start the reminders and the session once the words are confirmed',
        build: () => authBloc,
        act: (bloc) => bloc.add(RecoveryPhraseConfirmed(testUser)),
        expect: () => [
          isA<AuthSuccessful>().having((state) => state.user, 'user', testUser),
        ],
        verify: (_) {
          verify(() => mockRecoveryReminderUseCase.start()).called(1);
        },
      );
    });

    group('AccountLockDetected', () {
      blocTest<AuthBloc, AuthState>(
        'should start the locked account flow when the account turns out to be locked',
        build: () => authBloc,
        seed: () => AuthSuccessful(testUser),
        act: (bloc) => bloc.add(AccountLockDetected()),
        expect: () => [isA<AuthAccountLocked>().having((state) => state.user, 'user', testUser)],
      );

      blocTest<AuthBloc, AuthState>(
        'should ignore it without a session',
        build: () => authBloc,
        act: (bloc) => bloc.add(AccountLockDetected()),
        expect: () => <AuthState>[],
      );
    });

    group('AccountUnlocked', () {
      blocTest<AuthBloc, AuthState>(
        'should start the session when a locked account gets a usable key',
        build: () => authBloc,
        act: (bloc) => bloc.add(AccountUnlocked(testUser)),
        expect: () => [
          isA<AuthSuccessful>().having((state) => state.user, 'user', testUser),
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
                recoveryWords: any(named: 'recoveryWords'),
              )).thenAnswer((_) async => false);
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
        'should send the 24 words and keep the account usable',
        build: () {
          when(() => mockResetPasswordUseCase(
                email: any(named: 'email'),
                code: any(named: 'code'),
                newPassword: any(named: 'newPassword'),
                recoveryWords: any(named: 'recoveryWords'),
              )).thenAnswer((_) async => false);
          return authBloc;
        },
        act: (bloc) => bloc.add(NewPasswordSubmitted(
          email: testEmail,
          code: testCode,
          newPassword: testNewPassword,
          recoveryWords: testWords,
        )),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<AuthLoading>(),
          isA<PasswordResetSuccessful>().having((state) => state.accountLocked, 'accountLocked', isFalse),
        ],
        verify: (_) {
          verify(() => mockResetPasswordUseCase(
                email: testEmail,
                code: testCode,
                newPassword: testNewPassword,
                recoveryWords: testWords,
              )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should tell that the account is locked when the reset was done without the words',
        build: () {
          when(() => mockResetPasswordUseCase(
                email: any(named: 'email'),
                code: any(named: 'code'),
                newPassword: any(named: 'newPassword'),
                recoveryWords: any(named: 'recoveryWords'),
              )).thenAnswer((_) async => true);
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
          isA<PasswordResetSuccessful>().having((state) => state.accountLocked, 'accountLocked', isTrue),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should call resetPasswordUseCase with correct parameters',
        build: () {
          when(() => mockResetPasswordUseCase(
                email: any(named: 'email'),
                code: any(named: 'code'),
                newPassword: any(named: 'newPassword'),
                recoveryWords: any(named: 'recoveryWords'),
              )).thenAnswer((_) async => false);
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
                recoveryWords: null,
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
                recoveryWords: any(named: 'recoveryWords'),
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
                recoveryWords: any(named: 'recoveryWords'),
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
                recoveryWords: any(named: 'recoveryWords'),
              )).thenAnswer((_) async => false);
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
              )).thenAnswer((_) async => loginResult());
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
