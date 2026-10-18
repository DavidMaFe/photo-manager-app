import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/utils/app_locale.dart';

void main() {
  group('AppLocale', () {
    group('resolve', () {
      test('should use Spanish when the device is in Spanish', () {
        expect(AppLocale.resolve(const [Locale('es', 'ES')]), const Locale('es'));
      });

      test('should use Spanish for any Spanish variant', () {
        expect(AppLocale.resolve(const [Locale('es', 'MX')]), const Locale('es'));
      });

      test('should use English when the device is in English', () {
        expect(AppLocale.resolve(const [Locale('en', 'GB')]), const Locale('en'));
      });

      test('should use English when the device language is not supported', () {
        expect(AppLocale.resolve(const [Locale('fr', 'FR')]), const Locale('en'));
      });

      test('should use the first supported language in the order of the device settings', () {
        expect(AppLocale.resolve(const [Locale('fr'), Locale('es'), Locale('en')]), const Locale('es'));
        expect(AppLocale.resolve(const [Locale('de'), Locale('en'), Locale('es')]), const Locale('en'));
      });

      test('should use English without device languages', () {
        expect(AppLocale.resolve(null), const Locale('en'));
        expect(AppLocale.resolve(const []), const Locale('en'));
      });
    });

    group('strings', () {
      test('should give the texts of the language the app is shown in', () {
        expect(AppLocale.strings().localeName, AppLocale.current().languageCode);
      });
    });
  });
}
