import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/reset_password_from_device_use_case.dart';

abstract class DeviceResetPasswordEvent {}

class DeviceResetPasswordSubmitted extends DeviceResetPasswordEvent {
  final String newPassword;

  /// Translated text shown with the fingerprint or PIN prompt.
  final String reason;

  DeviceResetPasswordSubmitted({required this.newPassword, required this.reason});
}

abstract class DeviceResetPasswordState {}

class DeviceResetPasswordInitial extends DeviceResetPasswordState {}

class DeviceResetPasswordLoading extends DeviceResetPasswordState {}

class DeviceResetPasswordSuccess extends DeviceResetPasswordState {}

class DeviceResetPasswordError extends DeviceResetPasswordState {
  final Failure failure;

  DeviceResetPasswordError(this.failure);
}

/// "I forgot my password" on a device with an open session (docs/e2ee-spec.md, section 8.5).
class DeviceResetPasswordBloc extends Bloc<DeviceResetPasswordEvent, DeviceResetPasswordState> {
  final ResetPasswordFromDeviceUseCase resetPasswordFromDeviceUseCase;

  DeviceResetPasswordBloc({required this.resetPasswordFromDeviceUseCase}) : super(DeviceResetPasswordInitial()) {
    on<DeviceResetPasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(DeviceResetPasswordSubmitted event, Emitter<DeviceResetPasswordState> emit) async {
    emit(DeviceResetPasswordLoading());
    try {
      await resetPasswordFromDeviceUseCase(newPassword: event.newPassword, reason: event.reason);
      emit(DeviceResetPasswordSuccess());
    } catch (e) {
      emit(DeviceResetPasswordError(ErrorHandler.handleError(e)));
    }
  }
}
