import 'package:photo_manager_app/features/gallery/domain/entities/file_date_group.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';

class DateGroupingUtil {
  /// Groups files by date using smart grouping logic:
  /// - Today
  /// - Yesterday
  /// - This Week (Monday - Sunday)
  /// - Last Week
  /// - Month name (e.g., "March 2024")
  /// - No date (files without `capturedAt`), always last
  static List<FileDateGroup> groupFilesByDate(
    List<GalleryFile> files, {
    String? todayLabel,
    String? yesterdayLabel,
    String? thisWeekLabel,
    String? lastWeekLabel,
    List<String>? monthNames,
    String? noDateLabel,
  }) {
    if (files.isEmpty) return [];

    // Sort files by capturedAt in descending order (newest first, undated last)
    final sortedFiles = List<GalleryFile>.from(files)
      ..sort((a, b) => _compareNewestFirst(a.capturedAt, b.capturedAt));

    // Group files by smart normalized date (null key = no capture date)
    final Map<DateTime?, List<GalleryFile>> groupedMap = {};

    for (final file in sortedFiles) {
      final capturedAt = file.capturedAt;
      final normalizedDate = capturedAt != null ? getSmartNormalizedDate(capturedAt) : null;
      groupedMap.putIfAbsent(normalizedDate, () => []).add(file);
    }

    // Convert map to list of FileDateGroup with smart labels
    final groups = groupedMap.entries.map((entry) {
      return FileDateGroup(
        date: entry.key,
        label: _groupLabel(
          entry.key,
          todayLabel: todayLabel,
          yesterdayLabel: yesterdayLabel,
          thisWeekLabel: thisWeekLabel,
          lastWeekLabel: lastWeekLabel,
          monthNames: monthNames,
          noDateLabel: noDateLabel,
        ),
        files: entry.value,
      );
    }).toList();

    // Sort groups by date (newest first, undated last)
    groups.sort((a, b) => _compareNewestFirst(a.date, b.date));

    return groups;
  }

  /// Newest first; `null` (no capture date) goes after every dated item.
  static int _compareNewestFirst(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return b.compareTo(a);
  }

  static String _groupLabel(
    DateTime? date, {
    String? todayLabel,
    String? yesterdayLabel,
    String? thisWeekLabel,
    String? lastWeekLabel,
    List<String>? monthNames,
    String? noDateLabel,
  }) {
    if (date == null) return noDateLabel ?? 'No date';
    return getSmartDateLabel(
      date,
      todayLabel: todayLabel,
      yesterdayLabel: yesterdayLabel,
      thisWeekLabel: thisWeekLabel,
      lastWeekLabel: lastWeekLabel,
      monthNames: monthNames,
    );
  }

  /// Normalizes a DateTime to the start of the day (midnight)
  static DateTime normalizeDateToDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Normalizes a DateTime to the first day of its month
  static DateTime normalizeDateToMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }

  /// Normalizes a DateTime to the start of its week (Monday)
  static DateTime normalizeToStartOfWeek(DateTime dateTime) {
    final normalizedDay = normalizeDateToDay(dateTime);
    return _getStartOfWeek(normalizedDay);
  }

  /// Determines HOW to normalize based on WHEN the file is from
  /// - Today/Yesterday: normalize to specific day
  /// - This Week: normalize to Monday of this week
  /// - Last Week: normalize to Monday of last week
  /// - Older: normalize to first day of month
  static DateTime getSmartNormalizedDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = normalizeDateToDay(now);
    final yesterday = today.subtract(const Duration(days: 1));
    final normalizedDate = normalizeDateToDay(dateTime);

    // TODAY: group by day
    if (normalizedDate == today) {
      return today;
    }

    // YESTERDAY: group by day
    if (normalizedDate == yesterday) {
      return yesterday;
    }

    // THIS WEEK: group all together (normalize to Monday)
    final startOfThisWeek = _getStartOfWeek(today);
    final endOfThisWeek = startOfThisWeek.add(const Duration(days: 6));

    if (normalizedDate.isAfter(startOfThisWeek.subtract(const Duration(days: 1))) &&
        normalizedDate.isBefore(endOfThisWeek.add(const Duration(days: 1)))) {
      return startOfThisWeek; // All "This Week" files → Monday
    }

    // LAST WEEK: group all together (normalize to last Monday)
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfLastWeek.add(const Duration(days: 6));

    if (normalizedDate.isAfter(startOfLastWeek.subtract(const Duration(days: 1))) &&
        normalizedDate.isBefore(endOfLastWeek.add(const Duration(days: 1)))) {
      return startOfLastWeek; // All "Last Week" files → last Monday
    }

    // OLDER: group by month (normalize to first day of month)
    return normalizeDateToMonth(normalizedDate);
  }

  /// Returns a smart label for the given date based on how recent it is
  static String getSmartDateLabel(
    DateTime date, {
    String? todayLabel,
    String? yesterdayLabel,
    String? thisWeekLabel,
    String? lastWeekLabel,
    List<String>? monthNames,
  }) {
    final now = DateTime.now();
    final today = normalizeDateToDay(now);
    final yesterday = today.subtract(const Duration(days: 1));
    final normalizedDate = normalizeDateToDay(date);

    // Today
    if (normalizedDate == today) {
      return todayLabel ?? 'Today';
    }

    // Yesterday
    if (normalizedDate == yesterday) {
      return yesterdayLabel ?? 'Yesterday';
    }

    // This Week (Monday to Sunday)
    final startOfThisWeek = _getStartOfWeek(today);
    final endOfThisWeek = startOfThisWeek.add(const Duration(days: 6));

    if (normalizedDate.isAfter(startOfThisWeek.subtract(const Duration(days: 1))) &&
        normalizedDate.isBefore(endOfThisWeek.add(const Duration(days: 1)))) {
      return thisWeekLabel ?? 'This Week';
    }

    // Last Week
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfLastWeek.add(const Duration(days: 6));

    if (normalizedDate.isAfter(startOfLastWeek.subtract(const Duration(days: 1))) &&
        normalizedDate.isBefore(endOfLastWeek.add(const Duration(days: 1)))) {
      return lastWeekLabel ?? 'Last Week';
    }

    // Month name (e.g., "March 2024")
    return _formatMonthYear(normalizedDate, monthNames: monthNames);
  }

  /// Returns the start of the week (Monday) for a given date
  static DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday; // Monday = 1, Sunday = 7
    final daysToSubtract = weekday - 1; // Days since Monday
    return date.subtract(Duration(days: daysToSubtract));
  }

  /// Formats a date as "Month Year" (e.g., "March 2024")
  static String _formatMonthYear(DateTime date, {List<String>? monthNames}) {
    if (monthNames != null && monthNames.length == 12) {
      final monthName = monthNames[date.month - 1];
      return '$monthName ${date.year}';
    }

    // Fallback to English
    const defaultMonthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final monthName = defaultMonthNames[date.month - 1];
    return '$monthName ${date.year}';
  }

  /// Updates the labels of existing groups with localized strings
  static List<FileDateGroup> relabelGroups(
    List<FileDateGroup> groups, {
    String? todayLabel,
    String? yesterdayLabel,
    String? thisWeekLabel,
    String? lastWeekLabel,
    List<String>? monthNames,
    String? noDateLabel,
  }) {
    return groups.map((group) {
      final newLabel = _groupLabel(
        group.date,
        todayLabel: todayLabel,
        yesterdayLabel: yesterdayLabel,
        thisWeekLabel: thisWeekLabel,
        lastWeekLabel: lastWeekLabel,
        monthNames: monthNames,
        noDateLabel: noDateLabel,
      );
      return group.copyWith(label: newLabel);
    }).toList();
  }

  /// Merges new files into existing groups, maintaining proper grouping and sorting
  static List<FileDateGroup> mergeFilesIntoGroups(
    List<FileDateGroup> existingGroups,
    List<GalleryFile> newFiles, {
    String? todayLabel,
    String? yesterdayLabel,
    String? thisWeekLabel,
    String? lastWeekLabel,
    List<String>? monthNames,
    String? noDateLabel,
  }) {
    if (newFiles.isEmpty) return existingGroups;

    // Flatten existing groups into a single list
    final allFiles = <GalleryFile>[];
    for (final group in existingGroups) {
      allFiles.addAll(group.files);
    }

    // Add new files
    allFiles.addAll(newFiles);

    // Remove duplicates based on file ID
    final uniqueFiles = <String, GalleryFile>{};
    for (final file in allFiles) {
      uniqueFiles[file.id] = file;
    }

    // Regroup all files
    return groupFilesByDate(
      uniqueFiles.values.toList(),
      todayLabel: todayLabel,
      yesterdayLabel: yesterdayLabel,
      thisWeekLabel: thisWeekLabel,
      lastWeekLabel: lastWeekLabel,
      monthNames: monthNames,
      noDateLabel: noDateLabel,
    );
  }
}
