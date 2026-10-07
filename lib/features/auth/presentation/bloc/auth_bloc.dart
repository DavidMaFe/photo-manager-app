import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/recovery_phrase_use_cases.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/refresh_token_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/request_password_reset_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/validate_reset_code_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/legal/domain/use_cases/accept_legal_terms_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/register_sync_device_use_case.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final RegisterSyncDeviceUseCase registerSyncDeviceUseCase;
  final LogoutUseCase logoutUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final RequestPasswordResetUseCase requestPasswordResetUseCase;
  final ValidateResetCodeUseCase validateResetCodeUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final AuthRepository authRepository;
  final SyncDeviceRepository syncDeviceRepository;
  final RecoveryReminderUseCase? recoveryReminderUseCase;
  final AcceptLegalTermsUseCase acceptLegalTermsUseCase;

  static const int minimumLoadingDuration = 800;

  // Subscription for hard authentication failures fired by AuthenticatedHttpClient
  // (e.g. refresh token expired). Forces a logout so the router redirects to login.
  StreamSubscription<AuthenticationFailedEvent>? _authFailedSubscription;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.registerSyncDeviceUseCase,
    required this.logoutUseCase,
    required this.refreshTokenUseCase,
    required this.requestPasswordResetUseCase,
    required this.validateResetCodeUseCase,
    required this.resetPasswordUseCase,
    required this.authRepository,
    required this.syncDeviceRepository,
    this.recoveryReminderUseCase,
    required this.acceptLegalTermsUseCase,
    required AppEventBus eventBus,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<TokenRefreshRequested>(_onTokenRefreshRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<ResetCodeValidationRequested>(_onResetCodeValidationRequested);
    on<PasswordResetCodeResendRequested>(_onPasswordResetCodeResendRequested);
    on<NewPasswordSubmitted>(_onNewPasswordSubmitted);
    on<RecoveryPhraseConfirmed>(_onRecoveryPhraseConfirmed);
    on<AccountUnlocked>((event, emit) => emit(AuthSuccessful(event.user)));
    on<LegalTermsAccepted>(_onLegalTermsAccepted);

    // When the HTTP layer cannot refresh the token (session fully expired),
    // trigger a logout so GoRouter redirects back to the login screen.
    _authFailedSubscription = eventBus
        .on<AuthenticationFailedEvent>()
        .listen((_) => add(LogoutRequested()));
  }

  @override
  Future<void> close() {
    _authFailedSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {

    emit(AuthLoading());

    // This stopwatch it's for control the time if the request it's
    // answered too fast. With this we ensure that the loading it's shown.
    final stopwatch = Stopwatch()..start();

    try {
      final result = await loginUseCase(
        email: event.email,
        password: event.password
      );
      // Delay the promise response the remaining time
      await _registerDevice();
      await _waitForLoading(stopwatch);

      if (result.legalAcceptanceRequired) {
        // The terms in force are accepted first, then the locked account flow or the gallery
        emit(AuthLegalAcceptanceRequired(result.user, accountLocked: result.accountLocked));
      } else {
        // A locked account goes through the locked account flow before the gallery
        emit(result.accountLocked ? AuthAccountLocked(result.user) : AuthSuccessful(result.user));
      }
    } catch (e) {
      await _waitForLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(AuthError(failure));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {

    emit(AuthLoading());
    final stopwatch = Stopwatch()..start();

    try {

      final result = await registerUseCase(email: event.email, password: event.password,
          name: event.name, surname: event.surname, language: event.language,
          acceptedLegalTerms: event.acceptedLegalTerms);
      await _waitForLoading(stopwatch);
      emit(RecoveryPhraseRequired(result.user, result.recoveryWords));

    } catch (e) {
      await _waitForLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(AuthError(failure));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {

    try {
      await logoutUseCase();
      emit(NotAuthenticated());
    } catch (e) {
      final failure = ErrorHandler.handleError(e);
      emit(AuthError(failure));
    }
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {

    emit(AuthLoading());

    try {

      final user = await authRepository.getCurrentUser();

      if (await authRepository.hasToken() && user != null) {
        // Check if refresh token has expired (30 days)
        final authDataRepository = authRepository as dynamic;
        final isExpired = await authDataRepository.isRefreshTokenExpired();

        if (isExpired) {
          // 30 days have passed, force logout
          await logoutUseCase();
          emit(NotAuthenticated());
        } else {
          emit(AuthSuccessful(user));
        }
      } else {
        emit(NotAuthenticated());
      }
    } catch (e) {
      emit(NotAuthenticated());
    }

  }

  Future<void> _registerDevice() async {

    try {

      final deviceUuid = await syncDeviceRepository.getDeviceUuid();
      final deviceInfo = await syncDeviceRepository.getCurrentDeviceInfo();

      await registerSyncDeviceUseCase(
        uuid: deviceUuid,
        name: deviceInfo.name,
        model: deviceInfo.model,
        osType: deviceInfo.osType,
        osVersion: deviceInfo.osVersion,
        appVersion: deviceInfo.appVersion,
        pushToken: null
      );
    } catch(e) {
      // Ignore error
    }
  }

  Future<void> _waitForLoading(Stopwatch stopwatch) async {
    stopwatch.stop();
    final elapsed = stopwatch.elapsedMilliseconds;
    final remaining = minimumLoadingDuration - elapsed;

    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }
  }

  Future<void> _onPasswordResetRequested(PasswordResetRequested event, Emitter<AuthState> emit) async {

    emit(AuthLoading());
    final stopwatch = Stopwatch()..start();

    try {
      await requestPasswordResetUseCase(email: event.email);
      await _waitForLoading(stopwatch);
      emit(PasswordResetEmailSent(event.email));
    } catch (e) {
      await _waitForLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(AuthError(failure));
    }
  }

  Future<void> _onResetCodeValidationRequested(ResetCodeValidationRequested event, Emitter<AuthState> emit) async {

    emit(AuthLoading());
    final stopwatch = Stopwatch()..start();

    try {
      await validateResetCodeUseCase(email: event.email, code: event.code);
      await _waitForLoading(stopwatch);
      emit(ResetCodeValidated(event.email, event.code));
    } catch (e) {
      await _waitForLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(AuthError(failure));
    }
  }

  Future<void> _onPasswordResetCodeResendRequested(PasswordResetCodeResendRequested event, Emitter<AuthState> emit) async {

    emit(AuthLoading());
    final stopwatch = Stopwatch()..start();

    try {
      await requestPasswordResetUseCase(email: event.email);
      await _waitForLoading(stopwatch);
      emit(PasswordResetEmailSent(event.email));
    } catch (e) {
      await _waitForLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(AuthError(failure));
    }
  }

  Future<void> _onLegalTermsAccepted(LegalTermsAccepted event, Emitter<AuthState> emit) async {
    final current = state;
    if (current is! AuthLegalAcceptanceRequired) {
      return;
    }
    emit(AuthLegalAcceptanceRequired(current.user, accountLocked: current.accountLocked, working: true));
    try {
      await acceptLegalTermsUseCase();
      emit(current.accountLocked ? AuthAccountLocked(current.user) : AuthSuccessful(current.user));
    } catch (e) {
      // The state stays (an error state would send the router back to the login)
      emit(AuthLegalAcceptanceRequired(current.user, accountLocked: current.accountLocked,
          failure: ErrorHandler.handleError(e)));
    }
  }

  Future<void> _onRecoveryPhraseConfirmed(RecoveryPhraseConfirmed event, Emitter<AuthState> emit) async {
    await recoveryReminderUseCase?.start();
    await _registerDevice();
    emit(AuthSuccessful(event.user));
  }

  Future<void> _onNewPasswordSubmitted(NewPasswordSubmitted event, Emitter<AuthState> emit) async {

    emit(AuthLoading());
    final stopwatch = Stopwatch()..start();

    try {
      final accountLocked = await resetPasswordUseCase(
        email: event.email,
        code: event.code,
        newPassword: event.newPassword,
        recoveryWords: event.recoveryWords,
      );
      await _waitForLoading(stopwatch);
      emit(PasswordResetSuccessful(accountLocked: accountLocked));
    } catch (e) {
      await _waitForLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(AuthError(failure));
    }
  }

  Future<void> _onTokenRefreshRequested(TokenRefreshRequested event, Emitter<AuthState> emit) async {
    try {
      await refreshTokenUseCase();
      // Token refreshed successfully - maintain current state
      // The HTTP interceptor will use the new token automatically
    } catch (e) {
      // Refresh failed - force logout
      final failure = ErrorHandler.handleError(e);
      emit(AuthError(failure));
      emit(NotAuthenticated());
    }
  }
}