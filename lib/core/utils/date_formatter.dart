import 'package:flutter/material.dart';
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
}