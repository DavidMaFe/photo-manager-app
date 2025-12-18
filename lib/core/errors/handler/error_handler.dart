import 'dart:async';
import 'dart:io';

import 'package:photo_manager_app/core/errors/base/failures.dart';

import '../base/failure_codes.dart';


class ErrorHandler {
  static Failure handleError(dynamic error) {
    // If already a Failure, return as-is
    if (error is Failure) {
      return error;
    }

    // Handle Exception types
    if (error is Exception) {
      return _handleException(error);
    }

    // Handle Error types
    if (error is Error) {
      return UnknownFailure(
        code: 'ERROR',
        data: {'type': error.runtimeType.toString(), 'message': error.toString()},
      );
    }

    // Fallback for unknown error types
    return UnknownFailure(
      data: {'message': error.toString()},
    );
  }

  static Failure _handleException(Exception exception) {
    final exceptionString = exception.toString();

    // Network-related exceptions
    if (exception is SocketException) {
      return NetworkFailure();
    }

    if (exception is TimeoutException) {
      return TimeoutFailure();
    }

    if (exception is HttpException) {
      return ServerFailure(code: exception.message);
    }

    // Format exceptions (JSON parsing, etc.)
    if (exception is FormatException) {
      return ValidationFailure(
        data: {'message': exception.message},
      );
    }

    // Parse HTTP status codes from exception messages
    if (exceptionString.contains(FailureCodes.authenticationErrorCode)) {
      return InvalidCredentialsFailure();
    }

    if (exceptionString.contains('403')) {
      return PermissionDeniedFailure();
    }

    if (exceptionString.contains('404')) {
      return NotFoundFailure();
    }

    if (exceptionString.contains('409') ||
        exceptionString.toLowerCase().contains('already exists')) {
      return AlreadyExistsFailure();
    }

    if (exceptionString.contains('422') ||
        exceptionString.toLowerCase().contains('validation')) {
      return ValidationFailure();
    }

    if (exceptionString.contains('500') ||
        exceptionString.contains('502') ||
        exceptionString.contains('503') ||
        exceptionString.contains('504') ||
        exceptionString.toLowerCase().contains('server error')) {
      return ServerFailure(
        code: _extractStatusCode(exceptionString),
      );
    }

    // Email-specific errors (server-side only)
    if (exceptionString.toLowerCase().contains('email') &&
        (exceptionString.toLowerCase().contains('exists') ||
         exceptionString.toLowerCase().contains('already'))) {
      return EmailAlreadyExistsFailure();
    }

    // Token/Auth errors
    if (exceptionString.toLowerCase().contains('token') &&
        (exceptionString.toLowerCase().contains('expired') ||
         exceptionString.toLowerCase().contains('invalid'))) {
      return TokenExpiredFailure();
    }

    // Cache errors
    if (exceptionString.toLowerCase().contains('cache')) {
      return CacheFailure();
    }

    // Storage errors
    if (exceptionString.toLowerCase().contains('storage') &&
        (exceptionString.toLowerCase().contains('full') ||
         exceptionString.toLowerCase().contains('exceeded'))) {
      return StorageSpaceExceededFailure();
    }

    // Default to UnknownFailure with exception details
    return UnknownFailure(
      data: {'message': exceptionString},
    );
  }

  static String? _extractStatusCode(String message) {
    final regex = RegExp(r'\b[45]\d{2}\b');
    final match = regex.firstMatch(message);
    return match?.group(0);
  }
}