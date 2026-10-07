
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';


abstract class AuthState {}


class AuthInitial extends AuthState {}


class AuthLoading extends AuthState {}


class AuthSuccessful extends AuthState {
  final User user;

  AuthSuccessful(this.user);
}


/// Registered: the 24 recovery words must be shown and confirmed before the session starts.
class RecoveryPhraseRequired extends AuthState {
  final User user;
  final List<String> words;

  RecoveryPhraseRequired(this.user, this.words);
}


/// Logged in, but no key can be opened with the password (docs/e2ee-spec.md, section 8.6).
class AuthAccountLocked extends AuthState {
  final User user;

  AuthAccountLocked(this.user);
}


class NotAuthenticated extends AuthState {}


class AuthError extends AuthState {
  final Failure failure;

  AuthError(this.failure);
}


class PasswordResetEmailSent extends AuthState {
  final String email;

  PasswordResetEmailSent(this.email);
}


class ResetCodeValidated extends AuthState {
  final String email;
  final String code;

  ResetCodeValidated(this.email, this.code);
}


class PasswordResetSuccessful extends AuthState {
  /// The password changed without the 24 words: the photos are locked until the user recovers them.
  final bool accountLocked;

  PasswordResetSuccessful({this.accountLocked = false});
}