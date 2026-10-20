import 'package:photo_manager_app/features/auth/domain/entities/login_result.dart';
import 'package:photo_manager_app/features/auth/domain/entities/second_factor_challenge.dart';

/// What a login with the password gives: the session, or a second factor to pass first.
sealed class LoginOutcome {
  const LoginOutcome();
}

/// A trusted device: the session started.
class LoginCompleted extends LoginOutcome {
  final LoginResult result;

  const LoginCompleted(this.result);
}

/// A device that is not trusted: the code emailed to the account is needed (VerifyLoginSecondFactorUseCase).
class LoginSecondFactorRequired extends LoginOutcome {
  final SecondFactorChallenge challenge;

  const LoginSecondFactorRequired(this.challenge);
}
