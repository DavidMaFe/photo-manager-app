import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/register_sync_device_use_case.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {

  final LoginUseCase loginUseCase;
  final RegisterSyncDeviceUseCase registerSyncDeviceUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;
  final SyncDeviceRepository syncDeviceRepository;

  static const int minimumLoadingDuration = 800;

  AuthBloc({
    required this.loginUseCase,
    required this.registerSyncDeviceUseCase,
    required this.logoutUseCase,
    required this.authRepository,
    required this.syncDeviceRepository
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {

    emit(AuthLoading());

    // This stopwatch it's for control the time if the request it's
    // answered too fast. With this we ensure that the loading it's shown.
    final stopwatch = Stopwatch()..start();

    try {
      final user = await loginUseCase(
        email: event.email,
        password: event.password
      );
      // Delay the promise response the remaining time
      await _registerDevice();
      await _waitForLoading(stopwatch);

      emit(AuthSuccessful(user));
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
        emit(AuthSuccessful(user));
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
}