import 'dart:ui';

/// Utility class for generating HTTP headers with proper localization support
class HttpHeadersUtil {
  /// Generates standard JSON headers with Accept-Language based on current locale
  ///
  /// The Accept-Language header tells the backend which language the client prefers.
  /// This enables the backend to return localized error messages and content.
  ///
  /// Returns a Map with:
  /// - Content-Type: application/json
  /// - Accept-Language: <current-locale> (e.g., "es", "en")
  static Map<String, String> getJsonHeaders() {
    final locale = PlatformDispatcher.instance.locale;
    final languageCode = locale.languageCode; // e.g., 'es', 'en'

    return {
      'Content-Type': 'application/json',
      'Accept-Language': languageCode,
    };
  }

  /// Generates JSON headers with authorization token
  ///
  /// Includes both Content-Type, Accept-Language, and Authorization headers.
  ///
  /// Parameters:
  /// - token: The authentication token (can be null, will throw if missing)
  ///
  /// Returns a Map with:
  /// - Content-Type: application/json
  /// - Accept-Language: <current-locale>
  /// - Authorization: Bearer <token>
  ///
  /// Throws [Exception] if token is null
  static Map<String, String> getAuthJsonHeaders(String? token) {
    if (token == null) {
      throw Exception('Authentication token is required but was not found');
    }

    final locale = PlatformDispatcher.instance.locale;
    final languageCode = locale.languageCode;

    return {
      'Content-Type': 'application/json',
      'Accept-Language': languageCode,
      'Authorization': 'Bearer $token',
    };
  }

  /// Generates headers with only authorization token (no Content-Type)
  ///
  /// Useful for GET requests or when Content-Type shouldn't be specified.
  ///
  /// Parameters:
  /// - token: The authentication token (can be null, will throw if missing)
  ///
  /// Returns a Map with:
  /// - Accept-Language: <current-locale>
  /// - Authorization: Bearer <token>
  ///
  /// Throws [Exception] if token is null
  static Map<String, String> getAuthHeaders(String? token) {
    if (token == null) {
      throw Exception('Authentication token is required but was not found');
    }

    final locale = PlatformDispatcher.instance.locale;
    final languageCode = locale.languageCode;

    return {
      'Accept-Language': languageCode,
      'Authorization': 'Bearer $token',
    };
  }
}
