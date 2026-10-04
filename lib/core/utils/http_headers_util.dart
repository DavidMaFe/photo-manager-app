import 'dart:ui';

import 'package:photo_manager_app/core/services/timezone_service.dart';

/// Utility class for generating HTTP headers with proper localization support
class HttpHeadersUtil {
  /// Header with the device time zone (IANA id). The backend formats dates in it.
  static const String timezoneHeader = 'X-Timezone';

  /// Generates standard JSON headers with Accept-Language based on current locale
  ///
  /// The Accept-Language header tells the backend which language the client prefers.
  /// This enables the backend to return localized error messages and content.
  ///
  /// Returns a Map with:
  /// - Content-Type: application/json
  /// - Accept-Language: <current-locale> (e.g., "es", "en")
  /// - X-Timezone: <device-time-zone> (e.g., "Europe/Madrid")
  static Map<String, String> getJsonHeaders() {
    return {
      'Content-Type': 'application/json',
      ..._localeHeaders(),
    };
  }

  /// Generates JSON headers with authorization token
  ///
  /// Includes both Content-Type, Accept-Language, X-Timezone and Authorization headers.
  ///
  /// Parameters:
  /// - token: The authentication token (can be null, will throw if missing)
  ///
  /// Returns a Map with:
  /// - Content-Type: application/json
  /// - Accept-Language: <current-locale>
  /// - X-Timezone: <device-time-zone>
  /// - Authorization: Bearer <token>
  ///
  /// Throws [Exception] if token is null
  static Map<String, String> getAuthJsonHeaders(String? token) {
    if (token == null) {
      throw Exception('Authentication token is required but was not found');
    }

    return {
      'Content-Type': 'application/json',
      ..._localeHeaders(),
      'Authorization': 'Bearer $token',
    };
  }

  /// Generates headers for multipart/form-data requests (no Content-Type).
  ///
  /// For multipart requests the `http` library sets `Content-Type: multipart/form-data`
  /// with the correct boundary automatically. Adding `application/json` would
  /// override that and break server-side parsing of form fields and files.
  ///
  /// Returns a Map with:
  /// - Accept-Language: <current-locale> (e.g., "es", "en")
  /// - X-Timezone: <device-time-zone>
  static Map<String, String> getMultipartHeaders() {
    return _localeHeaders();
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
  /// - X-Timezone: <device-time-zone>
  /// - Authorization: Bearer <token>
  ///
  /// Throws [Exception] if token is null
  static Map<String, String> getAuthHeaders(String? token) {
    if (token == null) {
      throw Exception('Authentication token is required but was not found');
    }

    return {
      ..._localeHeaders(),
      'Authorization': 'Bearer $token',
    };
  }

  /// Language and time zone of the device, shared by every request.
  static Map<String, String> _localeHeaders() {
    final languageCode = PlatformDispatcher.instance.locale.languageCode; // e.g., 'es', 'en'
    return {
      'Accept-Language': languageCode,
      timezoneHeader: TimezoneService.current,
    };
  }
}
