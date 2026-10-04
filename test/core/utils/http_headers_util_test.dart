import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/services/timezone_service.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';

void main() {
  tearDown(TimezoneService.reset);

  group('HttpHeadersUtil', () {
    group('X-Timezone', () {
      test('should send the default time zone when the device one is unknown', () {
        // Act
        final headers = HttpHeadersUtil.getJsonHeaders();

        // Assert
        expect(headers['X-Timezone'], 'Europe/Madrid');
      });

      test('should send the device time zone in every header set', () async {
        // Arrange
        await TimezoneService.init(resolver: () async => 'America/Mexico_City');

        // Act
        final all = [
          HttpHeadersUtil.getJsonHeaders(),
          HttpHeadersUtil.getAuthJsonHeaders('token'),
          HttpHeadersUtil.getMultipartHeaders(),
          HttpHeadersUtil.getAuthHeaders('token'),
        ];

        // Assert
        for (final headers in all) {
          expect(headers['X-Timezone'], 'America/Mexico_City');
          expect(headers['Accept-Language'], isNotEmpty);
        }
      });
    });

    group('getJsonHeaders', () {
      test('should include the JSON content type', () {
        expect(HttpHeadersUtil.getJsonHeaders()['Content-Type'], 'application/json');
      });
    });

    group('getAuthJsonHeaders', () {
      test('should include the bearer token and content type', () {
        // Act
        final headers = HttpHeadersUtil.getAuthJsonHeaders('abc');

        // Assert
        expect(headers['Authorization'], 'Bearer abc');
        expect(headers['Content-Type'], 'application/json');
      });

      test('should throw when the token is missing', () {
        expect(() => HttpHeadersUtil.getAuthJsonHeaders(null), throwsException);
      });
    });

    group('getMultipartHeaders', () {
      test('should not set a content type', () {
        expect(HttpHeadersUtil.getMultipartHeaders().containsKey('Content-Type'), isFalse);
      });
    });

    group('getAuthHeaders', () {
      test('should include the bearer token without content type', () {
        // Act
        final headers = HttpHeadersUtil.getAuthHeaders('abc');

        // Assert
        expect(headers['Authorization'], 'Bearer abc');
        expect(headers.containsKey('Content-Type'), isFalse);
      });

      test('should throw when the token is missing', () {
        expect(() => HttpHeadersUtil.getAuthHeaders(null), throwsException);
      });
    });
  });
}
