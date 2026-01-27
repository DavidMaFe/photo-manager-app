/// Model representing the error response structure from the backend
///
/// This mirrors the ErrorResponse record from the backend server:
/// - code: Error code (e.g., "USER_NOT_FOUND", "EMAIL_ALREADY_USED")
/// - message: Localized error message
/// - timestamp: When the error occurred (ISO 8601 format)
/// - path: Request URI path where error occurred
/// - details: Field-level validation errors (for validation failures)
class ErrorResponseModel {
  final String code;
  final String message;
  final String timestamp;
  final String? path;
  final Map<String, String>? details;

  ErrorResponseModel({
    required this.code,
    required this.message,
    required this.timestamp,
    this.path,
    this.details,
  });

  /// Creates an ErrorResponseModel from JSON
  ///
  /// Example JSON from backend:
  /// ```json
  /// {
  ///   "code": "EMAIL_ALREADY_USED",
  ///   "message": "Email 'user@example.com' is already registered",
  ///   "timestamp": "2025-01-25T10:30:45.123456",
  ///   "path": "/api/auth/register",
  ///   "details": null
  /// }
  /// ```
  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) {
    return ErrorResponseModel(
      code: json['code'] as String,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
      path: json['path'] as String?,
      details: json['details'] != null
          ? Map<String, String>.from(json['details'] as Map)
          : null,
    );
  }

  /// Converts ErrorResponseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'timestamp': timestamp,
      if (path != null) 'path': path,
      if (details != null) 'details': details,
    };
  }

  @override
  String toString() {
    return 'ErrorResponseModel(code: $code, message: $message, timestamp: $timestamp, path: $path, details: $details)';
  }
}
