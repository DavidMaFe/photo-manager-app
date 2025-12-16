

abstract class Failure {

  final String messageKey;
  final Map<String, dynamic>? messageParams;
  final String? code;
  final dynamic data;

  const Failure({
    required this.messageKey,
    this.messageParams,
    this.code,
    this.data
  });

  @override
  String toString() => 'Failure(key: $messageKey, code: $code)';
}

// ============= NETWORK ERRORS =============

class ServerFailure extends Failure {
  const ServerFailure({
    super.messageKey = 'errorServer',
    super.messageParams,
    super.code,
    super.data
  });
}


class NetworkFailure extends Failure {
  const NetworkFailure({
    super.messageKey = 'errorNetwork',
    super.messageParams,
    super.code,
    super.data
  });
}


class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.messageKey = 'errorTimeout',
    super.messageParams,
    super.code,
    super.data
  });
}

// ============= AUTH ERRORS =============

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.messageKey = 'errorUnauthorized',
    super.messageParams,
    super.code,
    super.data
  });
}


class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({
    super.messageKey = 'errorInvalidCredentials',
    super.messageParams,
    super.code,
    super.data
  });
}


class TokenExpiredFailure extends Failure {
  const TokenExpiredFailure({
    super.messageKey = 'errorTokenExpired',
    super.messageParams,
    super.code,
    super.data
  });
}

// ============= VALIDATION ERRORS =============

class ValidationFailure extends Failure {
  const ValidationFailure({
    super.messageKey = 'errorValidation',
    super.messageParams,
    super.code,
    super.data
  });
}


class InvalidEmailFailure extends ValidationFailure {
  const InvalidEmailFailure({
    super.messageKey = 'errorInvalidEmail',
    super.messageParams,
    super.code,
    super.data
  });
}


class PasswordMismatchFailure extends ValidationFailure {
  const PasswordMismatchFailure({
    super.messageKey = 'errorPasswordMismatch',
    super.messageParams,
    super.code,
    super.data
  });
}


class RequiredFieldFailure extends ValidationFailure {
  RequiredFieldFailure({
    required String fieldName,
    super.messageKey = 'errorRequiredField',
    super.code,
    super.data,
  }) : super(
    messageParams: {'fieldName': fieldName},
  );
}

// ============= DATA ERRORS =============

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.messageKey = 'errorNotFound',
    super.messageParams,
    super.code,
    super.data
  });
}


class AlreadyExistsFailure extends Failure {
  const AlreadyExistsFailure({
    super.messageKey = 'errorAlreadyExists',
    super.messageParams,
    super.code,
    super.data
  });
}


class EmailAlreadyExistsFailure extends Failure {
  const EmailAlreadyExistsFailure({
    super.messageKey = 'errorEmailAlreadyExists',
    super.messageParams,
    super.code,
    super.data
  });
}


class CacheFailure extends Failure {
  const CacheFailure({
    super.messageKey = 'errorCache',
    super.messageParams,
    super.code,
    super.data
  });
}

// ============= PERMISSION ERRORS =============

class StorageSpaceExceededFailure extends Failure {
  const StorageSpaceExceededFailure({
    super.messageKey = 'errorStorageSpaceExceeded',
    super.messageParams,
    super.code,
    super.data
  });
}


class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure({
    super.messageKey = 'errorPermissionDenied',
    super.messageParams,
    super.code,
    super.data
  });
}

// ============= GENERIC ERRORS =============

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.messageKey = 'errorUnknown',
    super.messageParams,
    super.code,
    super.data
  });
}