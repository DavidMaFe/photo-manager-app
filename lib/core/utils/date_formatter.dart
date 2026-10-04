import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class DateFormatter {

  static String formatRelativeTime(DateTime dateTime, BuildContext context) {

    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final l10n = AppLocalizations.of(context)!;

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      if (minutes < 1) return l10n.timeLessThanAMinute;
      return minutes == 1 ? l10n.timeOneMinute : l10n.timeMoreThanOneMinute(minutes);
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return hours == 1 ? l10n.timeOneHour : l10n.timeMoreThanOneHour(hours);
    }

    if(difference.inDays == 1) {
      final timeFormat = TimeOfDay.fromDateTime(dateTime).format(context);
      return l10n.timeYesterday(timeFormat);
    }

    final formatted = MaterialLocalizations.of(context).formatMediumDate(dateTime);
    return formatted;
  }

  /// "Today, 10:42", "Yesterday, 08:15", "Oct 1, 10:42" or "Oct 1, 2024, 10:42".
  static String formatDayAndTime(DateTime dateTime, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = l10n.localeName;
    final now = DateTime.now();
    final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final today = DateTime(now.year, now.month, now.day);

    final String dayLabel;
    if (day == today) {
      dayLabel = l10n.today;
    } else if (day == today.subtract(const Duration(days: 1))) {
      dayLabel = l10n.yesterday;
    } else if (dateTime.year == now.year) {
      dayLabel = DateFormat.MMMd(locale).format(dateTime);
    } else {
      dayLabel = DateFormat.yMMMd(locale).format(dateTime);
    }
    return l10n.dayAndTime(dayLabel, DateFormat.Hm(locale).format(dateTime));
  }

  /// Months covered by an album: "Aug 2024", "Jan – Aug 2024" or "Dec 2023 – Aug 2024"
  /// ("ago 2024", "ene – ago 2024" in Spanish). `null` without dates.
  static String? formatMonthRange(DateTime? oldest, DateTime? newest, String locale) {
    final from = oldest ?? newest;
    final to = newest ?? oldest;
    if (from == null || to == null) return null;

    final monthYear = DateFormat.yMMM(locale);
    if (from.year == to.year && from.month == to.month) return monthYear.format(to);
    if (from.year == to.year) return '${DateFormat.LLL(locale).format(from)} – ${monthYear.format(to)}';
    return '${monthYear.format(from)} – ${monthYear.format(to)}';
  }
}
