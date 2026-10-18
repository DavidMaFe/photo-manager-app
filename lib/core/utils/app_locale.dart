import 'dart:ui';

import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Language of the app: the first language of the device that the app supports, English otherwise.
///
/// Used by the [MaterialApp], by the requests (`Accept-Language`) and by the notifications, which are also shown
/// from the WorkManager isolate, without a `BuildContext`.
class AppLocale {
  const AppLocale._();

  static const supported = [Locale('es'), Locale('en')];
  static const fallback = Locale('en');

  /// The first locale of [deviceLocales] (in the order of the device settings) whose language the app supports.
  static Locale resolve(List<Locale>? deviceLocales) {
    for (final locale in deviceLocales ?? const <Locale>[]) {
      for (final candidate in supported) {
        if (candidate.languageCode == locale.languageCode) return candidate;
      }
    }
    return fallback;
  }

  /// Language of the app on this device.
  static Locale current() => resolve(PlatformDispatcher.instance.locales);

  /// Texts of the app in the language of this device.
  static AppLocalizations strings() => lookupAppLocalizations(current());
}
