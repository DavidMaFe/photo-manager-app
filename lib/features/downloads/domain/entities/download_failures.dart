import 'package:photo_manager_app/core/errors/base/failures.dart';

/// The files do not fit in the free space of the device (keeping [DownloadPlan.reservedBytes] free).
class NotEnoughSpaceFailure extends Failure {
  const NotEnoughSpaceFailure({super.messageKey = 'errorNotEnoughSpace', super.messageParams});
}

/// This device cannot save into its gallery (iOS, or Android before 10).
class DeviceMediaUnsupportedFailure extends Failure {
  const DeviceMediaUnsupportedFailure({super.messageKey = 'errorDeviceMediaUnsupported'});
}

/// More files than can be shared at once.
class TooManyFilesToShareFailure extends Failure {
  const TooManyFilesToShareFailure({super.messageKey = 'errorTooManyFilesToShare', super.messageParams});
}
