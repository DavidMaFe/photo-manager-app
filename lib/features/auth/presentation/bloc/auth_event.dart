
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

