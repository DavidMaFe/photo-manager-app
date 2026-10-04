import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/utils/date_grouping_util.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/file_date_group.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';

void main() {

  group('DateGroupingUtil', () {
    group('normalizeDateToDay', () {
      test('should remove time component from DateTime', () {
        // Arrange
        final dateTime = DateTime(2024, 3, 15, 14, 30, 45);

        // Act
        final normalized = DateGroupingUtil.normalizeDateToDay(dateTime);

        // Assert
        expect(normalized.year, 2024);
        expect(normalized.month, 3);
        expect(normalized.day, 15);
        expect(normalized.hour, 0);
        expect(normalized.minute, 0);
        expect(normalized.second, 0);
        expect(normalized.millisecond, 0);
      });

      test('should return same date if already normalized', () {
        // Arrange
        final dateTime = DateTime(2024, 3, 15);

        // Act
        final normalized = DateGroupingUtil.normalizeDateToDay(dateTime);

        // Assert
        expect(normalized, dateTime);
      });
    });

    group('getSmartDateLabel', () {
      test('should return "Today" for today\'s date', () {
        // Arrange
        final today = DateTime.now();
        final normalizedToday = DateGroupingUtil.normalizeDateToDay(today);

        // Act
        final label = DateGroupingUtil.getSmartDateLabel(normalizedToday);

        // Assert
        expect(label, 'Today');
      });

      test('should return "Yesterday" for yesterday\'s date', () {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final normalizedYesterday = DateGroupingUtil.normalizeDateToDay(yesterday);

        // Act
        final label = DateGroupingUtil.getSmartDateLabel(normalizedYesterday);

        // Assert
        expect(label, 'Yesterday');
      });

      test('should return "This Week" for dates within current week', () {
        // Arrange
        final now = DateTime.now();
        // Go back to the start of the week (Monday) and add 3 days
        // This ensures we're in the current week but not today or yesterday
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final dateInThisWeek = startOfWeek.add(const Duration(days: 3));
        final normalized = DateGroupingUtil.normalizeDateToDay(dateInThisWeek);

        // Act
        final label = DateGroupingUtil.getSmartDateLabel(normalized);

        // Assert
        // Only expect "This Week" if the date is not today or yesterday
        final today = DateGroupingUtil.normalizeDateToDay(now);
        final yesterday = today.subtract(const Duration(days: 1));

        if (normalized == today) {
          expect(label, 'Today');
        } else if (normalized == yesterday) {
          expect(label, 'Yesterday');
        } else {
          expect(label, 'This Week');
        }
      });

      test('should return "Last Week" for dates in previous week', () {
        // Arrange
        final now = DateTime.now();
        final daysToSubtract = now.weekday + 3; // Go back to middle of last week
        final dateInLastWeek = now.subtract(Duration(days: daysToSubtract));
        final normalized = DateGroupingUtil.normalizeDateToDay(dateInLastWeek);

        // Act
        final label = DateGroupingUtil.getSmartDateLabel(normalized);

        // Assert
        expect(label, 'Last Week');
      });

      test('should return month name and year for older dates', () {
        // Arrange
        final oldDate = DateTime(2024, 1, 15);

        // Act
        final label = DateGroupingUtil.getSmartDateLabel(oldDate);

        // Assert
        expect(label, 'January 2024');
      });

      test('should handle different months correctly', () {
        // Arrange & Act & Assert
        expect(
          DateGroupingUtil.getSmartDateLabel(DateTime(2024, 3, 1)),
          'March 2024',
        );
        expect(
          DateGroupingUtil.getSmartDateLabel(DateTime(2023, 12, 25)),
          'December 2023',
        );
      });
    });

    group('groupFilesByDate', () {
      test('should return empty list for empty input', () {
        // Arrange
        final files = <GalleryFile>[];

        // Act
        final groups = DateGroupingUtil.groupFilesByDate(files);

        // Assert
        expect(groups, isEmpty);
      });

      test('should group files by date correctly', () {
        // Arrange
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));

        final files = [
          _createTestFile('1', today),
          _createTestFile('2', today),
          _createTestFile('3', yesterday),
        ];

        // Act
        final groups = DateGroupingUtil.groupFilesByDate(files);

        // Assert
        expect(groups.length, 2);
        expect(groups[0].label, 'Today');
        expect(groups[0].files.length, 2);
        expect(groups[1].label, 'Yesterday');
        expect(groups[1].files.length, 1);
      });

      test('should sort groups by date (newest first)', () {
        // Arrange
        final today = DateTime.now();
        final normalizedToday = DateGroupingUtil.normalizeDateToDay(today);
        final yesterday = normalizedToday.subtract(const Duration(days: 1));
        final lastMonth = DateTime(today.year, today.month - 1, 15); // Date from last month

        final files = [
          _createTestFile('1', lastMonth),
          _createTestFile('2', normalizedToday),
          _createTestFile('3', yesterday),
        ];

        // Act
        final groups = DateGroupingUtil.groupFilesByDate(files);

        // Assert
        expect(groups.length, 3);
        expect(groups[0].label, 'Today');
        expect(groups[1].label, 'Yesterday');
        // Third group should be month name (e.g., "January 2026")
        expect(groups[2].label, contains('202')); // Should contain year
      });

      test('should sort files within each group by captured date (newest first)', () {
        // Arrange
        final today = DateTime.now();
        final todayMorning = DateTime(today.year, today.month, today.day, 8, 0);
        final todayAfternoon = DateTime(today.year, today.month, today.day, 14, 0);
        final todayEvening = DateTime(today.year, today.month, today.day, 20, 0);

        final files = [
          _createTestFile('1', todayMorning),
          _createTestFile('2', todayEvening),
          _createTestFile('3', todayAfternoon),
        ];

        // Act
        final groups = DateGroupingUtil.groupFilesByDate(files);

        // Assert
        expect(groups.length, 1);
        expect(groups[0].files.length, 3);
        expect(groups[0].files[0].id, '2'); // Evening (newest)
        expect(groups[0].files[1].id, '3'); // Afternoon
        expect(groups[0].files[2].id, '1'); // Morning (oldest)
      });

      test('should handle files from different months', () {
        // Arrange
        final files = [
          _createTestFile('1', DateTime(2024, 3, 15)),
          _createTestFile('2', DateTime(2024, 2, 10)),
          _createTestFile('3', DateTime(2024, 1, 5)),
        ];

        // Act
        final groups = DateGroupingUtil.groupFilesByDate(files);

        // Assert
        expect(groups.length, 3);
        expect(groups[0].label, 'March 2024');
        expect(groups[1].label, 'February 2024');
        expect(groups[2].label, 'January 2024');
      });
    });

    group('mergeFilesIntoGroups', () {
      test('should return existing groups when no new files', () {
        // Arrange
        final existingGroups = [
          FileDateGroup(
            date: DateTime(2024, 3, 15),
            label: 'March 2024',
            files: [_createTestFile('1', DateTime(2024, 3, 15))],
          ),
        ];
        final newFiles = <GalleryFile>[];

        // Act
        final result = DateGroupingUtil.mergeFilesIntoGroups(
          existingGroups,
          newFiles,
        );

        // Assert
        expect(result, existingGroups);
      });

      test('should merge new files into existing date groups', () {
        // Arrange
        final today = DateTime.now();
        final existingGroups = [
          FileDateGroup(
            date: DateGroupingUtil.normalizeDateToDay(today),
            label: 'Today',
            files: [_createTestFile('1', today)],
          ),
        ];
        final newFiles = [
          _createTestFile('2', today),
          _createTestFile('3', today),
        ];

        // Act
        final result = DateGroupingUtil.mergeFilesIntoGroups(
          existingGroups,
          newFiles,
        );

        // Assert
        expect(result.length, 1);
        expect(result[0].label, 'Today');
        expect(result[0].files.length, 3);
      });

      test('should create new date groups for files with different dates', () {
        // Arrange
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));

        final existingGroups = [
          FileDateGroup(
            date: DateGroupingUtil.normalizeDateToDay(today),
            label: 'Today',
            files: [_createTestFile('1', today)],
          ),
        ];
        final newFiles = [
          _createTestFile('2', yesterday),
        ];

        // Act
        final result = DateGroupingUtil.mergeFilesIntoGroups(
          existingGroups,
          newFiles,
        );

        // Assert
        expect(result.length, 2);
        expect(result[0].label, 'Today');
        expect(result[1].label, 'Yesterday');
      });

      test('should remove duplicate files based on ID', () {
        // Arrange
        final today = DateTime.now();
        final existingGroups = [
          FileDateGroup(
            date: DateGroupingUtil.normalizeDateToDay(today),
            label: 'Today',
            files: [_createTestFile('1', today)],
          ),
        ];
        final newFiles = [
          _createTestFile('1', today), // Duplicate ID
          _createTestFile('2', today),
        ];

        // Act
        final result = DateGroupingUtil.mergeFilesIntoGroups(
          existingGroups,
          newFiles,
        );

        // Assert
        expect(result.length, 1);
        expect(result[0].files.length, 2); // Only 2 unique files
        final fileIds = result[0].files.map((f) => f.id).toSet();
        expect(fileIds, {'1', '2'});
      });

      test('should maintain correct sorting after merge', () {
        // Arrange
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final twoDaysAgo = today.subtract(const Duration(days: 2));

        final existingGroups = [
          FileDateGroup(
            date: DateGroupingUtil.normalizeDateToDay(today),
            label: 'Today',
            files: [_createTestFile('1', today)],
          ),
        ];
        final newFiles = [
          _createTestFile('2', yesterday),
          _createTestFile('3', twoDaysAgo),
        ];

        // Act
        final result = DateGroupingUtil.mergeFilesIntoGroups(
          existingGroups,
          newFiles,
        );

        // Assert
        expect(result.length, 3);
        expect(result[0].label, 'Today');
        expect(result[1].label, 'Yesterday');
        // Third group should be "This Week" if within the week
      });
    });

    group('files without capture date', () {
      test('should put undated files in a last group with a null date', () {
        // Arrange
        final today = DateTime.now();
        final files = [
          _createUndatedFile('1'),
          _createTestFile('2', today),
          _createTestFile('3', DateTime(2020, 5, 10)),
          _createUndatedFile('4'),
        ];

        // Act
        final result = DateGroupingUtil.groupFilesByDate(files, noDateLabel: 'Sin fecha');

        // Assert
        expect(result.length, 3);
        expect(result[0].label, 'Today');
        expect(result[1].date, DateTime(2020, 5, 1));
        expect(result.last.date, isNull);
        expect(result.last.label, 'Sin fecha');
        expect(result.last.files.map((f) => f.id), ['1', '4']);
      });

      test('should use the default label when none is given', () {
        // Act
        final result = DateGroupingUtil.groupFilesByDate([_createUndatedFile('1')]);

        // Assert
        expect(result.single.label, 'No date');
      });

      test('should relabel the undated group', () {
        // Arrange
        final groups = DateGroupingUtil.groupFilesByDate([_createUndatedFile('1')]);

        // Act
        final result = DateGroupingUtil.relabelGroups(groups, noDateLabel: 'Sin fecha');

        // Assert
        expect(result.single.label, 'Sin fecha');
      });

      test('should keep the undated group last when merging new files', () {
        // Arrange
        final existing = DateGroupingUtil.groupFilesByDate([_createUndatedFile('1')]);

        // Act
        final result = DateGroupingUtil.mergeFilesIntoGroups(
          existing,
          [_createTestFile('2', DateTime.now()), _createUndatedFile('3')],
        );

        // Assert
        expect(result.length, 2);
        expect(result.first.date, isNotNull);
        expect(result.last.date, isNull);
        expect(result.last.files.map((f) => f.id), ['1', '3']);
      });
    });
  });
}

// Helper function to create test files
GalleryFile _createTestFile(String id, DateTime capturedAt) {
  return GalleryFile(
    id: id,
    type: FileType.image,
    status: FileStatus.managed,
    capturedAt: capturedAt,
  );
}

GalleryFile _createUndatedFile(String id) {
  return GalleryFile(
    id: id,
    type: FileType.image,
    status: FileStatus.managed,
    capturedAt: null,
  );
}
