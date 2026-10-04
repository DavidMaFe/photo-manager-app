import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// Device time zone (IANA id, e.g. `Europe/Madrid`) sent to the backend in the
/// `X-Timezone` header, so dates come back in the user's local time.
///
/// The zone is read once at startup ([init]) and cached; until then, or if the
/// platform lookup fails, [defaultTimezone] is used (same default as the server).
class TimezoneService {
  static const String defaultTimezone = 'Europe/Madrid';

  static String _current = defaultTimezone;

  /// Cached IANA time zone id.
  static String get current => _current;

  /// Reads the device time zone and caches it.
  ///
  /// [resolver] replaces the platform lookup in tests.
  static Future<void> init({Future<String> Function()? resolver}) async {
    try {
      final timezone = (await (resolver ?? _deviceTimezone)()).trim();
      _current = timezone.isEmpty ? defaultTimezone : timezone;
    } catch (_) {
      _current = defaultTimezone;
    }
  }

  static Future<String> _deviceTimezone() async {
    final info = await FlutterTimezone.getLocalTimezone();
    return info.identifier;
  }

  @visibleForTesting
  static void reset() => _current = defaultTimezone;
}
