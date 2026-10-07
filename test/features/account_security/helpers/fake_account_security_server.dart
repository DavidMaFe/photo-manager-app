import 'dart:convert';
import 'dart:typed_data';

import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/features/account_security/domain/repositories/account_security_repository.dart';

/// In-memory backend for the account security use cases. Like the real one it only keeps wrapped keys and checks the
/// proofs: a wrong recoveryAuthKey or masterKeyAuth is rejected.
class FakeAccountSecurityServer implements AccountSecurityRepository {
  KdfParams kdfParams;
  final List<KeyVersion> versions = [];
  final Map<int, Uint8List> _recoveryAuthKeys = {};
  final Map<int, Uint8List> _masterKeyAuths = {};

  /// Base64 of the last authKeys received (the use cases wipe the keys after the call).
  String? receivedCurrentAuthKey;
  String? receivedNewAuthKey;
  int passwordChanges = 0;

  FakeAccountSecurityServer({required this.kdfParams});

  void addVersion(NewKeyMaterial material, {required int version, KeyState state = KeyState.current}) {
    versions.add(KeyVersion(
      version: version,
      state: state,
      encryptedMasterKey: material.encryptedMasterKey,
      masterKeyByRecovery: material.masterKeyByRecovery,
      publicKey: material.publicKey,
      encryptedPrivateKey: material.encryptedPrivateKey,
    ));
    _recoveryAuthKeys[version] = material.recoveryAuthKey;
    _masterKeyAuths[version] = material.masterKeyAuth;
  }

  KeyVersion version(int number) => versions.singleWhere((version) => version.version == number);

  @override
  Future<KdfParams> getKdfParams() async => kdfParams;

  @override
  Future<AccountKeys> getAccountKeys() async => AccountKeys(
        accountLocked: !versions.any((version) => version.state == KeyState.current),
        versions: List.of(versions),
      );

  @override
  Future<void> changePassword({
    required CryptoKey currentAuthKey,
    required CryptoKey newAuthKey,
    required KdfParams kdfParams,
    required List<RewrappedKey> keys,
  }) async {
    receivedCurrentAuthKey = base64Encode(currentAuthKey.bytes);
    _newPassword(newAuthKey, kdfParams);
    for (final key in keys) {
      _rewrap(key.version, key.encryptedMasterKey, version(key.version).state);
    }
  }

  @override
  Future<void> resetPasswordFromDevice({
    required CryptoKey newAuthKey,
    required KdfParams kdfParams,
    required List<DeviceRewrappedKey> keys,
  }) async {
    for (final key in keys) {
      _checkProof(_masterKeyAuths, key.version, key.masterKeyAuth);
    }
    _newPassword(newAuthKey, kdfParams);
    for (final key in keys) {
      _rewrap(key.version, key.encryptedMasterKey, version(key.version).state);
    }
  }

  @override
  Future<int> createKeyVersion(NewKeyMaterial key) async {
    final number = versions.map((version) => version.version).fold(0, (a, b) => a > b ? a : b) + 1;
    for (final current in versions.where((version) => version.state == KeyState.current).toList()) {
      _rewrap(current.version, current.encryptedMasterKey, KeyState.unlocked);
    }
    addVersion(key, version: number);
    return number;
  }

  @override
  Future<void> unlockKeyVersion({
    required int version,
    CryptoKey? recoveryAuthKey,
    List<int>? masterKeyAuth,
    required List<int> encryptedMasterKey,
  }) async {
    if (recoveryAuthKey != null) {
      _checkProof(_recoveryAuthKeys, version, recoveryAuthKey.bytes);
    } else {
      _checkProof(_masterKeyAuths, version, masterKeyAuth!);
    }
    final hasCurrent = versions.any((key) => key.state == KeyState.current);
    _rewrap(version, Uint8List.fromList(encryptedMasterKey), hasCurrent ? KeyState.unlocked : KeyState.current);
  }

  void _newPassword(CryptoKey newAuthKey, KdfParams params) {
    receivedNewAuthKey = base64Encode(newAuthKey.bytes);
    kdfParams = params;
    passwordChanges++;
  }

  void _checkProof(Map<int, Uint8List> proofs, int version, List<int> proof) {
    if (base64Encode(proofs[version]!) != base64Encode(proof)) {
      throw Exception('403: wrong proof for version $version');
    }
  }

  void _rewrap(int number, Uint8List encryptedMasterKey, KeyState state) {
    final index = versions.indexWhere((version) => version.version == number);
    final old = versions[index];
    versions[index] = KeyVersion(
      version: number,
      state: state,
      encryptedMasterKey: encryptedMasterKey,
      masterKeyByRecovery: old.masterKeyByRecovery,
      publicKey: old.publicKey,
      encryptedPrivateKey: old.encryptedPrivateKey,
    );
  }
}
