import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:photo_manager_app/core/utils/date_formatter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('es');
  });

  group('DateFormatter', () {
    group('formatMonthRange', () {
      test('should return null without dates', () {
        expect(DateFormatter.formatMonthRange(null, null, 'en'), isNull);
      });

      test('should show one month when both dates are in the same month', () {
        expect(DateFormatter.formatMonthRange(DateTime(2024, 8, 1), DateTime(2024, 8, 31), 'en'), 'Aug 2024');
        expect(DateFormatter.formatMonthRange(DateTime(2024, 8, 1), DateTime(2024, 8, 31), 'es'), 'ago 2024');
      });

      test('should share the year when both dates are in the same year', () {
        expect(DateFormatter.formatMonthRange(DateTime(2024, 1, 3), DateTime(2024, 8, 20), 'en'), 'Jan – Aug 2024');
        expect(DateFormatter.formatMonthRange(DateTime(2024, 1, 3), DateTime(2024, 8, 20), 'es'), 'ene – ago 2024');
      });

      test('should show both years when the years differ', () {
        expect(
          DateFormatter.formatMonthRange(DateTime(2023, 12, 24), DateTime(2024, 8, 20), 'en'),
          'Dec 2023 – Aug 2024',
        );
      });

      test('should use the only date it has', () {
        expect(DateFormatter.formatMonthRange(DateTime(2024, 8, 1), null, 'en'), 'Aug 2024');
        expect(DateFormatter.formatMonthRange(null, DateTime(2024, 8, 1), 'en'), 'Aug 2024');
      });
    });
  });
}
