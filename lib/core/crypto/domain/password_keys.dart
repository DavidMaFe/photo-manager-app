import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';

/// Keys derived from the password (docs/e2ee-spec.md, section 4).
///
/// [authKey] is sent to the server to log in. [kek] never leaves the device: it wraps the master key.
class PasswordKeys {
  final CryptoKey authKey;
  final CryptoKey kek;

  const PasswordKeys({required this.authKey, required this.kek});

  void dispose() {
    authKey.dispose();
    kek.dispose();
  }
}
