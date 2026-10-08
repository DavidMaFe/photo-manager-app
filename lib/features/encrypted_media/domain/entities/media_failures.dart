import 'package:photo_manager_app/core/errors/base/failures.dart';

/// The file is encrypted with a key version this device cannot open (locked after a password reset without the 24
/// words). It is not deleted: it opens again once the version is unlocked.
class LockedFileFailure extends Failure {
  const LockedFileFailure({super.messageKey = 'errorLockedFile', super.code});
}

/// The file was uploaded before end-to-end encryption and has no key: this app cannot show it.
class UnencryptedFileFailure extends Failure {
  const UnencryptedFileFailure({super.messageKey = 'errorUnencryptedFile', super.code});
}
