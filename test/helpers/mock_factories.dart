import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Mock Factories for Common Test Dependencies
///
/// This file provides factory functions to create commonly used mock objects
/// with sensible default configurations, reducing boilerplate in tests.
///
/// Usage Example:
/// ```dart
/// final mockClient = createMockHttpClient();
/// final mockPrefs = createMockSharedPreferences();
/// final response = createHttpResponse(200, '{"success": true}');
/// ```

/// Creates a fake HTTP response for testing.
///
/// This utility helps create http.Response objects with custom status codes,
/// bodies, and headers for testing HTTP interactions.
///
/// Parameters:
/// - [statusCode]: HTTP status code (e.g., 200, 404, 500)
/// - [body]: Response body as string (typically JSON)
/// - [headers]: Optional response headers
///
/// Example:
/// ```dart
/// // Success response
/// final response = createHttpResponse(
///   200,
///   '{"id": "123", "name": "John Doe"}',
/// );
///
/// // Error response
/// final errorResponse = createHttpResponse(
///   401,
///   '{"error": "Unauthorized"}',
/// );
///
/// // With custom headers
/// final responseWithHeaders = createHttpResponse(
///   200,
///   '{"data": "test"}',
///   headers: {'content-type': 'application/json'},
/// );
/// ```
http.Response createHttpResponse(
  int statusCode,
  String body, {
  Map<String, String>? headers,
}) {
  return http.Response(
    body,
    statusCode,
    headers: headers ?? {'content-type': 'application/json'},
  );
}

/// Creates a fake HTTP StreamedResponse for testing multipart requests.
///
/// This is useful for testing file upload scenarios where the API returns
/// a StreamedResponse instead of a regular Response.
///
/// Parameters:
/// - [statusCode]: HTTP status code
/// - [body]: Response body as string
/// - [headers]: Optional response headers
///
/// Example:
/// ```dart
/// final streamedResponse = createHttpStreamedResponse(
///   200,
///   '{"uploadId": "abc123", "success": true}',
/// );
/// ```
http.StreamedResponse createHttpStreamedResponse(
  int statusCode,
  String body, {
  Map<String, String>? headers,
}) {
  return http.StreamedResponse(
    Stream.value(body.codeUnits),
    statusCode,
    headers: headers ?? {'content-type': 'application/json'},
  );
}

/// Creates common HTTP error responses.
///
/// Provides factory methods for standard HTTP error scenarios to reduce
/// duplication in error handling tests.
class HttpErrorResponses {
  /// 400 Bad Request
  static http.Response badRequest([String message = 'Bad Request']) {
    return createHttpResponse(400, '{"error": "$message"}');
  }

  /// 401 Unauthorized
  static http.Response unauthorized([String message = 'Unauthorized']) {
    return createHttpResponse(401, '{"error": "$message"}');
  }

  /// 403 Forbidden
  static http.Response forbidden([String message = 'Forbidden']) {
    return createHttpResponse(403, '{"error": "$message"}');
  }

  /// 404 Not Found
  static http.Response notFound([String message = 'Not Found']) {
    return createHttpResponse(404, '{"error": "$message"}');
  }

  /// 409 Conflict
  static http.Response conflict([String message = 'Conflict']) {
    return createHttpResponse(409, '{"error": "$message"}');
  }

  /// 422 Unprocessable Entity
  static http.Response unprocessableEntity([String message = 'Validation Error']) {
    return createHttpResponse(422, '{"error": "$message"}');
  }

  /// 500 Internal Server Error
  static http.Response internalServerError([String message = 'Internal Server Error']) {
    return createHttpResponse(500, '{"error": "$message"}');
  }

  /// 503 Service Unavailable
  static http.Response serviceUnavailable([String message = 'Service Unavailable']) {
    return createHttpResponse(503, '{"error": "$message"}');
  }
}

/// Creates a mock SharedPreferences instance with initial values.
///
/// This utility helps set up SharedPreferences for testing with predefined
/// key-value pairs.
///
/// Parameters:
/// - [initialValues]: Map of initial key-value pairs
///
/// Example:
/// ```dart
/// setUp(() async {
///   await setupMockSharedPreferences({
///     'auth_token': 'test_token_123',
///     'user_id': 'user_456',
///   });
/// });
/// ```
Future<void> setupMockSharedPreferences(Map<String, Object> initialValues) async {
  SharedPreferences.setMockInitialValues(initialValues);
}

/// Common test constants for HTTP headers
class TestHeaders {
  static const Map<String, String> jsonContentType = {
    'content-type': 'application/json',
  };

  static const Map<String, String> formDataContentType = {
    'content-type': 'multipart/form-data',
  };

  static Map<String, String> withAuth(String token) => {
        'content-type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static Map<String, String> jsonWithAuth(String token) => {
        'content-type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}

/// Common test timeouts for async operations
class TestTimeouts {
  /// Short timeout for fast operations (100ms)
  static const Duration short = Duration(milliseconds: 100);

  /// Medium timeout for network calls (1 second)
  static const Duration medium = Duration(seconds: 1);

  /// Long timeout for file operations (5 seconds)
  static const Duration long = Duration(seconds: 5);
}

/// HTTP method constants for clarity in tests
class HttpMethods {
  static const String get = 'GET';
  static const String post = 'POST';
  static const String put = 'PUT';
  static const String patch = 'PATCH';
  static const String delete = 'DELETE';
}