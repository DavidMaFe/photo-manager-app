import 'package:photo_manager_app/core/crypto/domain/password_keys.dart';
import 'package:photo_manager_app/core/errors/base/failure_codes.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/auth/domain/entities/second_factor_challenge.dart';

/// The login waiting for the second factor. The server gives the wrapped master keys only after the code, so the keys
/// derived from the password wait here, in memory only, until then: the user does not type the password twice. They
/// are disposed when the login ends, fails for good or is cancelled.
class PendingLogin {
  SecondFactorChallenge? _challenge;
  PasswordKeys? _keys;

  SecondFactorChallenge? get challenge => _challenge;
  PasswordKeys? get keys => _keys;

  bool get isActive => _challenge != null && _keys != null;

  /// Replaces (and disposes) any previous pending login.
  void start(SecondFactorChallenge challenge, PasswordKeys keys) {
    clear();
    _challenge = challenge;
    _keys = keys;
  }

  void clear() {
    _keys?.dispose();
    _keys = null;
    _challenge = null;
  }
}

/// Whether [error] says that the pending login can no longer go on (the server answered
/// `SECOND_FACTOR_CHALLENGE_EXPIRED`, or the app lost it).
bool isSecondFactorExpired(Object error) =>
    error is SecondFactorExpiredFailure ||
    (error is ApiException && error.code == FailureCodes.secondFactorChallengeExpired);
