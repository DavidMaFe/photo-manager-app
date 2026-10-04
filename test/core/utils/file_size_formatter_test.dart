import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:photo_manager_app/core/utils/file_size_formatter.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  group('FileSizeFormatter', () {
    group('format', () {
      test('should return 0 B for zero or negative sizes', () {
        expect(FileSizeFormatter.format(0, locale: 'en'), '0 B');
        expect(FileSizeFormatter.format(-5, locale: 'en'), '0 B');
      });

      test('should show bytes below 1 KB', () {
        expect(FileSizeFormatter.format(512, locale: 'en'), '512 B');
      });

      test('should show whole kilobytes and megabytes', () {
        expect(FileSizeFormatter.format(340 * 1024, locale: 'en'), '340 KB');
        expect(FileSizeFormatter.format(412 * 1024 * 1024, locale: 'en'), '412 MB');
      });

      test('should round megabytes to the nearest whole number', () {
        expect(FileSizeFormatter.format((2.6 * 1024 * 1024).round(), locale: 'en'), '3 MB');
      });

      test('should show one decimal for gigabytes below 10', () {
        expect(FileSizeFormatter.format((1.2 * 1024 * 1024 * 1024).round(), locale: 'en'), '1.2 GB');
      });

      test('should use the locale decimal separator', () {
        expect(FileSizeFormatter.format((1.2 * 1024 * 1024 * 1024).round(), locale: 'es'), '1,2 GB');
      });

      test('should show whole gigabytes from 10 GB', () {
        expect(FileSizeFormatter.format(15 * 1024 * 1024 * 1024, locale: 'en'), '15 GB');
      });

      test('should cap the unit at terabytes', () {
        expect(FileSizeFormatter.format(2 * 1024 * 1024 * 1024 * 1024, locale: 'en'), '2.0 TB');
      });
    });
  });
}
