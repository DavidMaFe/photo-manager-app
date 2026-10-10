import 'dart:convert';

import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/features/account_security/data/data_sources/account_security_remote_data_source.dart';
import 'package:photo_manager_app/features/account_security/domain/repositories/account_security_repository.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';

class AccountSecurityDataRepository implements AccountSecurityRepository {
  final AccountSecurityRemoteDataSource remoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  AccountSecurityDataRepository({required this.remoteDataSource, required this.authLocalDataSource});

  @override
  Future<KdfParams> getKdfParams() async {
    final user = await authLocalDataSource.getCachedUser();
    if (user == null) {
      throw Exception('No logged-in user');
    }
    return remoteDataSource.getKdfParams(user.email);
  }

  @override
  Future<AccountKeys> getAccountKeys() => remoteDataSource.getAccountKeys();

  @override
  Future<void> changePassword({
    required CryptoKey currentAuthKey,
    required CryptoKey newAuthKey,
    required KdfParams kdfParams,
    required List<RewrappedKey> keys,
  }) {
    return remoteDataSource.changePassword(
      currentAuthKey: base64Encode(currentAuthKey.bytes),
      newAuthKey: base64Encode(newAuthKey.bytes),
      kdfParams: kdfParams,
      keys: keys,
    );
  }

  @override
  Future<void> resetPasswordFromDevice({
    required CryptoKey newAuthKey,
    required KdfParams kdfParams,
    required List<DeviceRewrappedKey> keys,
  }) {
    return remoteDataSource.resetPasswordFromDevice(
        newAuthKey: base64Encode(newAuthKey.bytes), kdfParams: kdfParams, keys: keys);
  }

  @override
  Future<int> createKeyVersion(NewKeyMaterial key) => remoteDataSource.createKeyVersion(key);

  @override
  Future<void> unlockKeyVersion({
    required int version,
    CryptoKey? recoveryAuthKey,
    List<int>? masterKeyAuth,
    required List<int> encryptedMasterKey,
  }) {
    return remoteDataSource.unlockKeyVersion(
      version: version,
      recoveryAuthKey: recoveryAuthKey == null ? null : base64Encode(recoveryAuthKey.bytes),
      masterKeyAuth: masterKeyAuth == null ? null : base64Encode(masterKeyAuth),
      encryptedMasterKey: base64Encode(encryptedMasterKey),
    );
  }
}
