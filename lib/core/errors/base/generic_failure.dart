import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';

/// Generic failure used when the backend error code doesn't match any known Failure type
///
/// This failure preserves the backend error code and message for debugging
/// while providing a generic user-facing display.
///
/// Used by ErrorHandler when encountering unknown backend error codes.
class GenericFailure extends Failure {
  /// The original backend error code (e.g., "NEW_BACKEND_ERROR")
  final String backendCode;

  /// The backend error message
  final String backendMessage;

  GenericFailure({
    required this.backendCode,
    required this.backendMessage,
    ErrorResponseModel? errorResponse,
  }) : super(
          messageKey: 'errorGeneric',
          code: backendCode,
          data: {'backendMessage': backendMessage},
          errorResponse: errorResponse,
        );

  @override
  String toString() {
    return 'GenericFailure(backendCode: $backendCode, backendMessage: $backendMessage)';
  }
}
