
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';


abstract class AuthState {}


class AuthInitial extends AuthState {}


class AuthLoading extends AuthState {}


class AuthSuccessful extends AuthState {
  final User user;

  AuthSuccessful(this.user);
}


class NotAuthenticated extends AuthState {}


class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}