import 'package:photo_manager_app/core/errors/models/error_response_model.dart';

abstract class Failure {
  final String messageKey;
  final Map<String, dynamic>? messageParams;
  final String? code;
  final dynamic data;

  /// The complete error response from the backend (if this failure originated from an API error)
  /// Used for debugging, logging, and accessing additional error details
  final ErrorResponseModel? errorResponse;

  const Failure({
    required this.messageKey,
    this.messageParams,
    this.code,
    this.data,
    this.errorResponse,
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
    super.data,
    super.errorResponse,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.messageKey = 'errorNetwork',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.messageKey = 'errorTimeout',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}

// ============= AUTH ERRORS =============

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.messageKey = 'errorUnauthorized',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}

class InvalidCredentialsFailure extends UnauthorizedFailure {
  const InvalidCredentialsFailure({
    super.messageKey = 'errorInvalidCredentials',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}

class TokenExpiredFailure extends UnauthorizedFailure {
  const TokenExpiredFailure({
    super.messageKey = 'errorTokenExpired',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}

// ============= VALIDATION ERRORS =============

class ValidationFailure extends Failure {
  const ValidationFailure({
    super.messageKey = 'errorValidation',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}

class InvalidEmailFailure extends ValidationFailure {
  const InvalidEmailFailure({
    super.messageKey = 'errorInvalidEmail',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}

class PasswordMismatchFailure extends ValidationFailure {
  const PasswordMismatchFailure({
    super.messageKey = 'errorPasswordMismatch',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}

class RequiredFieldFailure extends ValidationFailure {
  RequiredFieldFailure({
    required String fieldName,
    super.messageKey = 'errorRequiredField',
    super.code,
    super.data,
    super.errorResponse,
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
    super.data,
    super.errorResponse,
  });
}

class AlreadyExistsFailure extends Failure {
  const AlreadyExistsFailure({
    super.messageKey = 'errorAlreadyExists',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}

class EmailAlreadyExistsFailure extends Failure {
  const EmailAlreadyExistsFailure({
    super.messageKey = 'errorEmailAlreadyExists',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.messageKey = 'errorCache',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}

// ============= PERMISSION ERRORS =============

class StorageSpaceExceededFailure extends Failure {
  const StorageSpaceExceededFailure({
    super.messageKey = 'errorStorageSpaceExceeded',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure({
    super.messageKey = 'errorPermissionDenied',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}

// ============= CONCURRENCY ERRORS =============

class ConcurrencyFailure extends Failure {
  const ConcurrencyFailure({
    super.messageKey = 'syncInProgressError',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}

// ============= GENERIC ERRORS =============

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.messageKey = 'errorUnknown',
    super.messageParams,
    super.code,
    super.data,
    super.errorResponse,
  });
}