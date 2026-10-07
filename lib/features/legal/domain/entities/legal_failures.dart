import 'package:photo_manager_app/core/errors/base/failures.dart';

/// The terms of use and the privacy policy were not accepted.
class LegalTermsNotAcceptedFailure extends Failure {
  const LegalTermsNotAcceptedFailure({super.messageKey = 'errorLegalTermsNotAccepted', super.code});
}
