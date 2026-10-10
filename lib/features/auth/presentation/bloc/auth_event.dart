import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';


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

  /// Language of the 24 recovery words (the language of the app).
  final RecoveryPhraseLanguage language;

  /// The user ticked the acceptance of the terms of use and the privacy policy.
  final bool acceptedLegalTerms;

  RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    this.surname,
    required this.language,
    required this.acceptedLegalTerms,
  });
}


/// The user accepted the terms of use and the privacy policy in force after logging in.
class LegalTermsAccepted extends AuthEvent {}


/// The user confirmed that the 24 words of the registration are saved: the session starts.
class RecoveryPhraseConfirmed extends AuthEvent {
  final User user;

  RecoveryPhraseConfirmed(this.user);
}


/// A locked account got a usable key again (unlocked or new): the session starts.
class AccountUnlocked extends AuthEvent {
  final User user;

  AccountUnlocked(this.user);
}


/// With a session open, the account turned out to be locked (the password was reset without the 24 words on another
/// device): the locked account flow starts, as after a login.
class AccountLockDetected extends AuthEvent {}


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

  /// The 24 words, or null if the user does not have them (the account becomes locked, nothing is deleted).
  final List<String>? recoveryWords;

  NewPasswordSubmitted({
    required this.email,
    required this.code,
    required this.newPassword,
    this.recoveryWords,
  });
}

