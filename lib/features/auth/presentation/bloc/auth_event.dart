
abstract class AuthEvent {}


class LoginRequested extends AuthEvent {

  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}


class RegisterRequested extends AuthEvent {

  final String email;
  final String password;
  final String name;
  final String? surname;

  RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    this.surname
  });
}


class LogoutRequested extends AuthEvent {}


class CheckAuthStatus extends AuthEvent {}


class TokenRefreshRequested extends AuthEvent {}


class PasswordResetRequested extends AuthEvent {

  final String email;

  PasswordResetRequested({required this.email});
}


class ResetCodeValidationRequested extends AuthEvent {

  final String email;
  final String code;

  ResetCodeValidationRequested({required this.email, required this.code});
}


class PasswordResetCodeResendRequested extends AuthEvent {

  final String email;

  PasswordResetCodeResendRequested({required this.email});
}


class NewPasswordSubmitted extends AuthEvent {

  final String email;
  final String code;
  final String newPassword;

  NewPasswordSubmitted({
    required this.email,
    required this.code,
    required this.newPassword
  });
}

