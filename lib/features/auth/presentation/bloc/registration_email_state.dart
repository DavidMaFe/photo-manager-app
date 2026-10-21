import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';

/// Steps of the registration: the email is verified with an emailed code before the rest of the data is asked.
enum RegistrationStep { email, code, details }

class RegistrationEmailState extends Equatable {
  final RegistrationStep step;
  final String email;

  /// The emailed code, once verified (sent again with the registration, which spends it).
  final String code;
  final bool loading;

  /// The email already has an account: the first step offers to log in instead.
  final bool emailTaken;

  /// The last request failed (cleared by the next one).
  final Failure? failure;

  /// A new code was emailed: the page says it once.
  final bool codeResent;

  const RegistrationEmailState({
    this.step = RegistrationStep.email,
    this.email = '',
    this.code = '',
    this.loading = false,
    this.emailTaken = false,
    this.failure,
    this.codeResent = false,
  });

  RegistrationEmailState copyWith({
    RegistrationStep? step,
    String? email,
    String? code,
    bool? loading,
    bool? emailTaken,
    Failure? Function()? failure,
    bool? codeResent,
  }) =>
      RegistrationEmailState(
        step: step ?? this.step,
        email: email ?? this.email,
        code: code ?? this.code,
        loading: loading ?? this.loading,
        emailTaken: emailTaken ?? this.emailTaken,
        failure: failure != null ? failure() : this.failure,
        codeResent: codeResent ?? this.codeResent,
      );

  @override
  List<Object?> get props => [step, email, code, loading, emailTaken, failure, codeResent];
}
