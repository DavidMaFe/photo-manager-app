import 'dart:typed_data';

/// State of a master key version (docs/e2ee-spec.md, section 4.2).
enum KeyState {
  /// Wrapped with the current password; used for new uploads.
  current,

  /// Older version wrapped with the current password: its files can be opened.
  unlocked,

  /// Wrapped with a forgotten password. Opened with its recovery key or from a device that still holds it.
  locked;

  bool get isAvailable => this != KeyState.locked;
}

/// One version of the user's master key as the server keeps it: always wrapped.
class KeyVersion {
  final int version;
  final KeyState state;
  final Uint8List encryptedMasterKey;
  final Uint8List masterKeyByRecovery;
  final Uint8List publicKey;
  final Uint8List encryptedPrivateKey;

  const KeyVersion({
    required this.version,
    required this.state,
    required this.encryptedMasterKey,
    required this.masterKeyByRecovery,
    required this.publicKey,
    required this.encryptedPrivateKey,
  });
}

/// Key versions of the account. [accountLocked]: no version can be opened with the current password.
class AccountKeys {
  final bool accountLocked;
  final List<KeyVersion> versions;

  const AccountKeys({required this.accountLocked, required this.versions});

  List<KeyVersion> get available => versions.where((version) => version.state.isAvailable).toList();

  List<KeyVersion> get locked => versions.where((version) => !version.state.isAvailable).toList();
}
