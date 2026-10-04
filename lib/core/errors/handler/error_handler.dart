import 'dart:async';
import 'dart:io';

import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/base/generic_failure.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/utils/error_logger.dart';

import '../base/failure_codes.dart';

/// Centralized error handling that converts exceptions to Failure objects
///
/// Priority order:
/// 1. ApiException (from backend) → Map error code to specific Failure
/// 2. Network exceptions (SocketException, TimeoutException) → Network Failures
/// 3. Other exceptions (FormatException, etc.) → Generic Failures
class ErrorHandler {
  static Failure handleError(dynamic error, {String? context}) {
    // If already a Failure, return as-is
    if (error is Failure) {
      ErrorLogger.logFailure(error, context: context);
      return error;
    }

    // Handle Exception types
    if (error is Exception) {
      final failure = _handleException(error);
      ErrorLogger.logFailure(failure, context: context);
      return failure;
    }

    // Handle Error types
    if (error is Error) {
      ErrorLogger.logException(
        Exception('Dart Error: ${error.toString()}'),
        error.stackTrace,
        context: context,
      );
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
    // Priority 1: Handle ApiException (from backend)
    if (exception is ApiException) {
      ErrorLogger.logApiError(exception);
      return _mapApiExceptionToFailure(exception);
    }

    // Priority 2: Handle network-related exceptions
    if (exception is SocketException) {
      ErrorLogger.logNetworkError(exception);
      return const NetworkFailure();
    }

    if (exception is TimeoutException) {
      ErrorLogger.logNetworkError(exception);
      return const TimeoutFailure();
    }

    if (exception is HttpException) {
      ErrorLogger.logNetworkError(exception);
      return ServerFailure(code: exception.message);
    }

    // Priority 3: Handle format exceptions (JSON parsing, etc.)
    if (exception is FormatException) {
      return ValidationFailure(
        data: {'message': exception.message},
      );
    }

    // Priority 4: Handle cache errors
    final exceptionString = exception.toString();
    if (exceptionString.toLowerCase().contains('cache')) {
      return const CacheFailure();
    }

    // Default to UnknownFailure with exception details
    return UnknownFailure(
      data: {'message': exceptionString},
    );
  }

  /// Maps ApiException (from backend) to specific Failure types based on error code
  static Failure _mapApiExceptionToFailure(ApiException exception) {
    final errorResponse = exception.errorResponse;
    final code = errorResponse.code;

    // Map backend error codes to specific Failure types
    switch (code) {
      // ==================== User Domain Errors ====================
      case FailureCodes.emailAlreadyUsed:
        return EmailAlreadyExistsFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.userNotFound:
        return NotFoundFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.incorrectPassword:
        return InvalidCredentialsFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.userDoesNotHaveStorageSpace:
        return StorageSpaceExceededFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.updateUserError:
        return ServerFailure(
          code: code,
          errorResponse: errorResponse,
        );

      // ==================== Device Domain Errors ====================
      case FailureCodes.deviceNotFound:
      case FailureCodes.deviceLinkedToAnotherUser:
      case FailureCodes.deviceNotLinkedToUser:
        return NotFoundFailure(
          code: code,
          errorResponse: errorResponse,
        );

      // ==================== File Domain Errors ====================
      case FailureCodes.fileNotFound:
        return NotFoundFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.fileSizeNotAccepted:
        return ValidationFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.invalidFileMimeType:
        return ValidationFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.deleteFileError:
        return ServerFailure(
          code: code,
          errorResponse: errorResponse,
        );

      // ==================== Sync Session Domain Errors ====================
      case FailureCodes.syncSessionNotFound:
        return NotFoundFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.syncSessionAlreadyInProgress:
      case FailureCodes.syncSessionNotInProgress:
        return AlreadyExistsFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.uploadFileError:
        return ServerFailure(
          code: code,
          errorResponse: errorResponse,
        );

      // ==================== Folder Domain Errors ====================
      case FailureCodes.folderNotFound:
        return NotFoundFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.folderAlreadyExists:
        return AlreadyExistsFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.folderCoversLimitExceeded:
      case FailureCodes.folderCoverDuplicated:
      case FailureCodes.folderCoverFileNotValid:
      case FailureCodes.folderCoverVideoNotAllowed:
      case FailureCodes.folderCoverReplaceNotValid:
        return ValidationFailure(
          code: code,
          errorResponse: errorResponse,
        );

      // ==================== Password Reset Domain Errors ====================
      case FailureCodes.expiredResetCode:
      case FailureCodes.invalidResetCode:
        return TokenExpiredFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.resetCodeNotFound:
        return NotFoundFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.tooManyResetAttempts:
        return PermissionDeniedFailure(
          code: code,
          errorResponse: errorResponse,
        );

      // ==================== JWT/Token Errors ====================
      case FailureCodes.invalidTokenFormat:
      case FailureCodes.invalidTokenSignature:
        return InvalidCredentialsFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.tokenExpired:
        return TokenExpiredFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.unauthorized:
        return UnauthorizedFailure(
          code: code,
          errorResponse: errorResponse,
        );

      // ==================== General Errors ====================
      case FailureCodes.authenticationError:
        return InvalidCredentialsFailure(
          code: code,
          errorResponse: errorResponse,
        );

      case FailureCodes.validationError:
        // Extract field-level validation errors from errorResponse.details
        return ValidationFailure(
          code: code,
          data: errorResponse.details,
          errorResponse: errorResponse,
        );

      // ==================== Unknown Backend Error ====================
      default:
        // Use GenericFailure for unknown backend error codes
        // This preserves the backend code and message for debugging
        return GenericFailure(
          backendCode: code,
          backendMessage: errorResponse.message,
          errorResponse: errorResponse,
        );
    }
  }
}