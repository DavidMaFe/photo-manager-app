import 'package:photo_manager_app/features/auth/domain/services/pending_login.dart';

/// The user leaves the second factor: the keys derived from the password are disposed.
class CancelLoginSecondFactorUseCase {

  final PendingLogin _pendingLogin;

  CancelLoginSecondFactorUseCase(this._pendingLogin);

  void call() => _pendingLogin.clear();
}
