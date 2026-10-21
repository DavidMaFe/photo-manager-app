import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/monitoring/domain/log_sanitizer.dart';

void main() {
  group('LogSanitizer', () {
    test('should replace emails', () {
      expect(LogSanitizer.clean('No account for ana.garcia+1@example.co.uk here'), 'No account for <email> here');
    });

    test('should replace absolute paths, which can carry the name of a photo', () {
      expect(LogSanitizer.clean("PathNotFoundException: Cannot open file, path = '/storage/emulated/0/DCIM/IMG_1.jpg'"),
          "PathNotFoundException: Cannot open file, path = '<path>'");
    });

    test('should replace content and file URIs', () {
      expect(LogSanitizer.clean('Failed content://media/external/images/123 and file:///data/x.png'),
          'Failed <uri> and <uri>');
    });

    test('should keep the frames of a Dart stack trace', () {
      const frame = '#0      main (package:photo_manager_app/main.dart:10:5)';

      expect(LogSanitizer.clean(frame), frame);
    });

    test('should cut a text over the limit', () {
      expect(LogSanitizer.clean('x' * 1200), hasLength(LogSanitizer.maxMessage));
      expect(LogSanitizer.clean('x' * 50, maxLength: 10), 'x' * 10);
    });

    test('should give null for null', () {
      expect(LogSanitizer.clean(null), isNull);
    });
  });
}
