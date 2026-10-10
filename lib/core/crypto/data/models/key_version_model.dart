import 'dart:convert';

import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';

/// JSON of the key versions sent by the server (login, register and GET /api/auth/keys/).
class AccountKeysModel {
  const AccountKeysModel._();

  /// `{ accountLocked, keys: [{ version, state, encryptedMasterKey, masterKeyByRecovery, publicKey,
  /// encryptedPrivateKey }] }`
  static AccountKeys fromJson(Map<String, dynamic> json) {
    final versions = (json['keys'] as List<dynamic>)
        .map((key) => key as Map<String, dynamic>)
        .map((key) => KeyVersion(
              version: key['version'] as int,
              state: _state(key['state'] as String),
              encryptedMasterKey: base64Decode(key['encryptedMasterKey'] as String),
              masterKeyByRecovery: base64Decode(key['masterKeyByRecovery'] as String),
              publicKey: base64Decode(key['publicKey'] as String),
              encryptedPrivateKey: base64Decode(key['encryptedPrivateKey'] as String),
            ))
        .toList();
    return AccountKeys(accountLocked: json['accountLocked'] as bool, versions: versions);
  }

  static KeyState _state(String value) => switch (value) {
        'CURRENT' => KeyState.current,
        'UNLOCKED' => KeyState.unlocked,
        _ => KeyState.locked,
      };
}

/// JSON of the key material sent to the server.
class KeyRequestModel {
  const KeyRequestModel._();

  static Map<String, dynamic> newKey(NewKeyMaterial key) => {
        'encryptedMasterKey': base64Encode(key.encryptedMasterKey),
        'masterKeyByRecovery': base64Encode(key.masterKeyByRecovery),
        'recoveryAuthKey': base64Encode(key.recoveryAuthKey),
        'masterKeyAuth': base64Encode(key.masterKeyAuth),
        'publicKey': base64Encode(key.publicKey),
        'encryptedPrivateKey': base64Encode(key.encryptedPrivateKey),
      };

  static Map<String, dynamic> rewrapped(RewrappedKey key) =>
      {'version': key.version, 'encryptedMasterKey': base64Encode(key.encryptedMasterKey)};

  static Map<String, dynamic> recovered(RecoveredKey key) => {
        'version': key.version,
        'recoveryAuthKey': base64Encode(key.recoveryAuthKey),
        'encryptedMasterKey': base64Encode(key.encryptedMasterKey),
      };

  static Map<String, dynamic> deviceRewrapped(DeviceRewrappedKey key) => {
        'version': key.version,
        'masterKeyAuth': base64Encode(key.masterKeyAuth),
        'encryptedMasterKey': base64Encode(key.encryptedMasterKey),
      };

  /// `{ keys: [{ version, state, masterKeyByRecovery }] }` of POST /api/password-reset/recovery-keys/
  static List<RecoveryWrap> recoveryWrapsFromJson(Map<String, dynamic> json) {
    return (json['keys'] as List<dynamic>)
        .map((key) => key as Map<String, dynamic>)
        .map((key) => RecoveryWrap(
              version: key['version'] as int,
              masterKeyByRecovery: base64Decode(key['masterKeyByRecovery'] as String),
            ))
        .toList();
  }
}
