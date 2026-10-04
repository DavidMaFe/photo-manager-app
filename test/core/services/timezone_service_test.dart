import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/services/timezone_service.dart';

void main() {
  tearDown(TimezoneService.reset);

  group('TimezoneService', () {
    test('should default to Europe/Madrid before init', () {
      // Assert
      expect(TimezoneService.current, 'Europe/Madrid');
    });

    group('init', () {
      test('should cache the device time zone when the lookup succeeds', () async {
        // Act
        await TimezoneService.init(resolver: () async => 'America/New_York');

        // Assert
        expect(TimezoneService.current, 'America/New_York');
      });

      test('should fall back to Europe/Madrid when the lookup fails', () async {
        // Arrange
        await TimezoneService.init(resolver: () async => 'Asia/Tokyo');

        // Act
        await TimezoneService.init(resolver: () async => throw Exception('no plugin'));

        // Assert
        expect(TimezoneService.current, 'Europe/Madrid');
      });

      test('should fall back to Europe/Madrid when the lookup returns an empty id', () async {
        // Act
        await TimezoneService.init(resolver: () async => '  ');

        // Assert
        expect(TimezoneService.current, 'Europe/Madrid');
      });

      test('should trim the time zone id', () async {
        // Act
        await TimezoneService.init(resolver: () async => ' Europe/London ');

        // Assert
        expect(TimezoneService.current, 'Europe/London');
      });
    });
  });
}
