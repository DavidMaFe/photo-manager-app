import 'dart:typed_data';

import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';

/// A new master key version generated on the device (docs/e2ee-spec.md, section 8.1). Only the wrapped keys and the
/// proofs go to the server; [masterKey] and [recoveryKey] stay on the device.
class NewKeyMaterial {
  final CryptoKey masterKey;
  final CryptoKey recoveryKey;
  final Uint8List encryptedMasterKey;
  final Uint8List masterKeyByRecovery;
  final Uint8List recoveryAuthKey;
  final Uint8List masterKeyAuth;
  final Uint8List publicKey;
  final Uint8List encryptedPrivateKey;

  const NewKeyMaterial({
    required this.masterKey,
    required this.recoveryKey,
    required this.encryptedMasterKey,
    required this.masterKeyByRecovery,
    required this.recoveryAuthKey,
    required this.masterKeyAuth,
    required this.publicKey,
    required this.encryptedPrivateKey,
  });
}

/// A key version wrapped again with the KEK of a new password.
class RewrappedKey {
  final int version;
  final Uint8List encryptedMasterKey;

  const RewrappedKey({required this.version, required this.encryptedMasterKey});
}

/// A key version opened with the recovery key, wrapped with the KEK of the new password.
class RecoveredKey {
  final int version;
  final Uint8List recoveryAuthKey;
  final Uint8List encryptedMasterKey;
  final CryptoKey masterKey;

  const RecoveredKey({
    required this.version,
    required this.recoveryAuthKey,
    required this.encryptedMasterKey,
    required this.masterKey,
  });
}

/// A key version this device holds, wrapped again, with the proof that the device has it.
class DeviceRewrappedKey {
  final int version;
  final Uint8List masterKeyAuth;
  final Uint8List encryptedMasterKey;

  const DeviceRewrappedKey({required this.version, required this.masterKeyAuth, required this.encryptedMasterKey});
}

/// Wrap of a key version with the recovery key, as given by the server with the emailed code.
class RecoveryWrap {
  final int version;
  final Uint8List masterKeyByRecovery;

  const RecoveryWrap({required this.version, required this.masterKeyByRecovery});
}
