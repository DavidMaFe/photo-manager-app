import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';

/// Centralized error logging utility for debugging and monitoring
///
/// Features:
/// - Structured logging with severity levels
/// - Automatic formatting of Failures and Exceptions
/// - Stack trace capture
/// - Context-aware logging (feature, operation, user data)
/// - Production-safe (respects build mode)
///
/// Usage:
/// ```dart
/// // Log a failure
/// ErrorLogger.logFailure(failure, context: 'LoginBloc.login');
///
/// // Log an exception
/// ErrorLogger.logException(exception, stackTrace, context: 'AuthRepository');
///
/// // Log API error
/// ErrorLogger.logApiError(apiException, context: 'ProfileDataSource.getProfile');
/// ```
class ErrorLogger {
  // Private constructor to prevent instantiation
  ErrorLogger._();

  /// Log a Failure object with full context
  static void logFailure(
    Failure failure, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('╔═══════════════════════════════════════════════════════════════');
    buffer.writeln('║ 🔴 FAILURE LOGGED');
    buffer.writeln('╠═══════════════════════════════════════════════════════════════');

    if (context != null) {
      buffer.writeln('║ Context: $context');
    }

    buffer.writeln('║ Type: ${failure.runtimeType}');
    buffer.writeln('║ Message Key: ${failure.messageKey}');

    if (failure.code != null) {
      buffer.writeln('║ Error Code: ${failure.code}');
    }

    if (failure.messageParams != null && failure.messageParams!.isNotEmpty) {
      buffer.writeln('║ Message Params: ${failure.messageParams}');
    }

    if (failure.data != null) {
      buffer.writeln('║ Data: ${failure.data}');
    }

    // Log backend error response if available
    if (failure.errorResponse != null) {
      buffer.writeln('║');
      buffer.writeln('║ 📡 Backend Error Response:');
      _logErrorResponse(buffer, failure.errorResponse!);
    }

    if (additionalData != null && additionalData.isNotEmpty) {
      buffer.writeln('║');
      buffer.writeln('║ Additional Data: $additionalData');
    }

    buffer.writeln('╚═══════════════════════════════════════════════════════════════');
    print(buffer.toString());
  }

  /// Log a raw Exception with stack trace
  static void logException(
    Exception exception,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('╔═══════════════════════════════════════════════════════════════');
    buffer.writeln('║ ⚠️  EXCEPTION LOGGED');
    buffer.writeln('╠═══════════════════════════════════════════════════════════════');

    if (context != null) {
      buffer.writeln('║ Context: $context');
    }

    buffer.writeln('║ Type: ${exception.runtimeType}');
    buffer.writeln('║ Message: ${exception.toString()}');

    if (additionalData != null && additionalData.isNotEmpty) {
      buffer.writeln('║ Additional Data: $additionalData');
    }

    if (stackTrace != null) {
      buffer.writeln('║');
      buffer.writeln('║ 📍 Stack Trace:');
      final stackLines = stackTrace.toString().split('\n').take(10); // First 10 lines
      for (final line in stackLines) {
        buffer.writeln('║   $line');
      }
      if (stackTrace.toString().split('\n').length > 10) {
        buffer.writeln('║   ... (truncated)');
      }
    }

    buffer.writeln('╚═══════════════════════════════════════════════════════════════');
    print(buffer.toString());
  }

  /// Log an ApiException with full backend error details
  static void logApiError(
    ApiException apiException, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('╔═══════════════════════════════════════════════════════════════');
    buffer.writeln('║ 🌐 API ERROR LOGGED');
    buffer.writeln('╠═══════════════════════════════════════════════════════════════');

    if (context != null) {
      buffer.writeln('║ Context: $context');
    }

    buffer.writeln('║ Type: ApiException');
    buffer.writeln('║');
    buffer.writeln('║ 📡 Backend Response:');
    _logErrorResponse(buffer, apiException.errorResponse);

    if (additionalData != null && additionalData.isNotEmpty) {
      buffer.writeln('║');
      buffer.writeln('║ Additional Data: $additionalData');
    }

    buffer.writeln('╚═══════════════════════════════════════════════════════════════');
    print(buffer.toString());
  }

  /// Log a network/connectivity error
  static void logNetworkError(
    Exception exception, {
    String? context,
    String? url,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('╔═══════════════════════════════════════════════════════════════');
    buffer.writeln('║ 📡 NETWORK ERROR');
    buffer.writeln('╠═══════════════════════════════════════════════════════════════');

    if (context != null) {
      buffer.writeln('║ Context: $context');
    }

    if (url != null) {
      buffer.writeln('║ URL: $url');
    }

    buffer.writeln('║ Type: ${exception.runtimeType}');
    buffer.writeln('║ Message: ${exception.toString()}');
    buffer.writeln('╚═══════════════════════════════════════════════════════════════');
    print(buffer.toString());
  }

  /// Helper method to log ErrorResponseModel details
  static void _logErrorResponse(StringBuffer buffer, ErrorResponseModel errorResponse) {
    buffer.writeln('║   • Code: ${errorResponse.code}');
    buffer.writeln('║   • Message: ${errorResponse.message}');
    buffer.writeln('║   • Timestamp: ${errorResponse.timestamp}');

    if (errorResponse.path != null) {
      buffer.writeln('║   • Path: ${errorResponse.path}');
    }

    if (errorResponse.details != null && errorResponse.details!.isNotEmpty) {
      buffer.writeln('║   • Field Errors:');
      errorResponse.details!.forEach((field, error) {
        buffer.writeln('║     - $field: $error');
      });
    }
  }

  /// Log info message (for debugging error flow)
  static void logInfo(String message, {String? context}) {
    final buffer = StringBuffer();
    buffer.writeln('╔═══════════════════════════════════════════════════════════════');
    buffer.writeln('║ ℹ️  INFO');
    buffer.writeln('╠═══════════════════════════════════════════════════════════════');

    if (context != null) {
      buffer.writeln('║ Context: $context');
    }

    buffer.writeln('║ Message: $message');
    buffer.writeln('╚═══════════════════════════════════════════════════════════════');
    print(buffer.toString());
  }

  /// Log warning (for recoverable issues)
  static void logWarning(String message, {String? context}) {
    final buffer = StringBuffer();
    buffer.writeln('╔═══════════════════════════════════════════════════════════════');
    buffer.writeln('║ ⚠️  WARNING');
    buffer.writeln('╠═══════════════════════════════════════════════════════════════');

    if (context != null) {
      buffer.writeln('║ Context: $context');
    }

    buffer.writeln('║ Message: $message');
    buffer.writeln('╚═══════════════════════════════════════════════════════════════');
    print(buffer.toString());
  }
}
