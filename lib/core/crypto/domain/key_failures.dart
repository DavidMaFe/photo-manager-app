import 'package:photo_manager_app/core/errors/base/failures.dart';

/// The 24 words do not open any key version of the account.
class RecoveryPhraseMismatchFailure extends Failure {
  const RecoveryPhraseMismatchFailure({super.messageKey = 'errorRecoveryPhraseMismatch', super.code});
}

/// The words are not a valid recovery phrase (unknown word, wrong number of words or a typo).
class InvalidRecoveryPhraseFailure extends Failure {
  const InvalidRecoveryPhraseFailure({super.messageKey = 'errorInvalidRecoveryPhrase', super.code});
}

/// The password is shorter than the minimum (decision D6).
class WeakPasswordFailure extends Failure {
  static const int minimumLength = 10;

  const WeakPasswordFailure({super.messageKey = 'errorWeakPassword', super.messageParams = const {'min': minimumLength}});
}

/// This device does not hold every available key version, so it cannot wrap them again.
class MissingDeviceKeyFailure extends Failure {
  const MissingDeviceKeyFailure({super.messageKey = 'errorMissingDeviceKey', super.code});
}

/// A key from the server could not be opened with the password (it should not happen once the login succeeded).
class KeyUnlockFailure extends Failure {
  const KeyUnlockFailure({super.messageKey = 'errorKeyUnlock', super.code});
}

/// The device lock (fingerprint, face or PIN) was not passed or is not configured.
class DeviceAuthenticationFailure extends Failure {
  const DeviceAuthenticationFailure({super.messageKey = 'errorDeviceAuthentication', super.code});
}

/// This device has no current master key (account locked, or the keys were removed), so it cannot encrypt new files.
class MissingCurrentKeyFailure extends Failure {
  const MissingCurrentKeyFailure({super.messageKey = 'errorMissingCurrentKey', super.code});
}

/// The keys of the account changed on another device (password reset or a new key version): this device must
/// refresh them, with the current password, before uploading again.
class OutdatedKeysFailure extends Failure {
  const OutdatedKeysFailure({super.messageKey = 'errorOutdatedKeys', super.code});
}
