import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/request_registration_code_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/verify_registration_code_use_case.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/registration_email_state.dart';

export 'registration_email_state.dart';

/// First two steps of the registration: the email (an email with an account is told at once) and the code emailed
/// to it. The last step, with the password and the rest of the data, is `RegisterRequested` in the AuthBloc.
class RegistrationEmailCubit extends Cubit<RegistrationEmailState> {

  /// Prevents the loading from flickering.
  static const int minimumLoadingDuration = 800;

  final RequestRegistrationCodeUseCase _requestCode;
  final VerifyRegistrationCodeUseCase _verifyCode;

  RegistrationEmailCubit({
    required RequestRegistrationCodeUseCase requestCode,
    required VerifyRegistrationCodeUseCase verifyCode,
  })  : _requestCode = requestCode,
        _verifyCode = verifyCode,
        super(const RegistrationEmailState());

  Future<void> sendCode(String email) async {
    if (state.loading) return;
    final trimmed = email.trim();
    emit(state.copyWith(email: trimmed, loading: true, emailTaken: false, failure: () => null));
    final failure = await _run(() => _requestCode(trimmed));
    if (failure == null) {
      emit(state.copyWith(step: RegistrationStep.code, code: '', loading: false));
    } else if (failure is EmailAlreadyExistsFailure) {
      emit(state.copyWith(loading: false, emailTaken: true));
    } else {
      emit(state.copyWith(loading: false, failure: () => failure));
    }
  }

  Future<void> resendCode() async {
    if (state.loading) return;
    emit(state.copyWith(loading: true, failure: () => null));
    final failure = await _run(() => _requestCode(state.email));
    emit(state.copyWith(loading: false, codeResent: failure == null, failure: () => failure));
  }

  Future<void> verifyCode(String code) async {
    if (state.loading) return;
    emit(state.copyWith(loading: true, failure: () => null));
    final failure = await _run(() => _verifyCode(email: state.email, code: code));
    if (failure == null) {
      emit(state.copyWith(step: RegistrationStep.details, code: code.trim(), loading: false));
    } else {
      emit(state.copyWith(loading: false, failure: () => failure));
    }
  }

  /// Back to the first step, keeping the email typed.
  void changeEmail() => emit(RegistrationEmailState(email: state.email));

  /// The registration rejected the code (it expired while the user filled the last step): a new one is needed.
  void codeRejected() => emit(state.copyWith(step: RegistrationStep.code, code: ''));

  void codeResentShown() => emit(state.copyWith(codeResent: false));

  /// Runs [request] for at least [minimumLoadingDuration]; returns its failure, or null when it succeeded.
  Future<Failure?> _run(Future<void> Function() request) async {
    final stopwatch = Stopwatch()..start();
    Failure? failure;
    try {
      await request();
    } catch (e) {
      failure = ErrorHandler.handleError(e);
    }
    final remaining = minimumLoadingDuration - stopwatch.elapsedMilliseconds;
    if (remaining > 0) await Future<void>.delayed(Duration(milliseconds: remaining));
    return failure;
  }
}
