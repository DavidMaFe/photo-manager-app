import 'package:intl/intl.dart';

/// Human-readable sizes with the locale's decimal separator:
/// "512 B", "340 KB", "412 MB", "1,2 GB" (es) / "1.2 GB" (en).
///
/// Uses binary units (1 KB = 1024 B), like the phone's storage settings.
class FileSizeFormatter {
  static const _units = ['B', 'KB', 'MB', 'GB', 'TB'];

  static String format(int bytes, {String? locale}) {
    if (bytes <= 0) return '0 B';

    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < _units.length - 1) {
      value /= 1024;
      unit++;
    }

    // One decimal only for GB and up below 10 ("1,2 GB"); whole numbers otherwise.
    final decimals = unit >= 3 && value < 10 ? 1 : 0;
    final number = NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: decimals).format(value);
    return '$number ${_units[unit]}';
  }
}
