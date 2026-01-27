import 'package:photo_manager_app/core/errors/models/error_response_model.dart';

/// Custom exception thrown when an API request fails
///
/// This exception wraps the complete ErrorResponse from the backend,
/// providing access to:
/// - Error code (for mapping to specific Failure types)
/// - Localized error message
/// - Field-level validation errors (if applicable)
/// - Timestamp and request path (for debugging)
///
/// This exception is thrown by all remote data sources when the backend
/// returns a non-2xx status code.
class ApiException implements Exception {
  final ErrorResponseModel errorResponse;

  ApiException(this.errorResponse);

  /// The error code from the backend (e.g., "USER_NOT_FOUND")
  String get code => errorResponse.code;

  /// The localized error message from the backend
  String get message => errorResponse.message;

  /// Field-level validation errors (null if not a validation error)
  Map<String, String>? get fieldErrors => errorResponse.details;

  /// The request path where the error occurred
  String? get path => errorResponse.path;

  /// The timestamp when the error occurred
  String get timestamp => errorResponse.timestamp;

  @override
  String toString() {
    return 'ApiException(code: $code, message: $message, path: $path, fieldErrors: $fieldErrors)';
  }
}
