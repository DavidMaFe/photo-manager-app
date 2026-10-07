import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';

/// Keys and password of the logged-in user (docs/e2ee-spec.md, section 12).
abstract class AccountSecurityRepository {
  /// Argon2id parameters of the current password of the logged-in user.
  Future<KdfParams> getKdfParams();

  Future<AccountKeys> getAccountKeys();

  Future<void> changePassword({
    required CryptoKey currentAuthKey,
    required CryptoKey newAuthKey,
    required KdfParams kdfParams,
    required List<RewrappedKey> keys,
  });

  Future<void> resetPasswordFromDevice({
    required CryptoKey newAuthKey,
    required KdfParams kdfParams,
    required List<DeviceRewrappedKey> keys,
  });

  /// Returns the version of the new key.
  Future<int> createKeyVersion(NewKeyMaterial key);

  /// One proof: [recoveryAuthKey] (24 words) or [masterKeyAuth] (this device holds the key).
  Future<void> unlockKeyVersion({
    required int version,
    CryptoKey? recoveryAuthKey,
    List<int>? masterKeyAuth,
    required List<int> encryptedMasterKey,
  });
}
