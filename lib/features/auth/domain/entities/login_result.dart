import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';

/// Logged-in user and the key versions of the account. If [keys] says the account is locked, the app shows the
/// locked account flow before the gallery (docs/e2ee-spec.md, section 8.6). If [legalAcceptanceRequired], the terms
/// of use and the privacy policy in force are accepted first.
class LoginResult {
  final User user;
  final AccountKeys keys;
  final bool legalAcceptanceRequired;

  const LoginResult({required this.user, required this.keys, this.legalAcceptanceRequired = false});

  bool get accountLocked => keys.accountLocked;
}
