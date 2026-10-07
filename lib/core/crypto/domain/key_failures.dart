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
