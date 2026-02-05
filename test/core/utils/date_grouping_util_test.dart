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
        final daysUntilSunday = 7 - now.weekday; // Days until end of week
        final dateInThisWeek = now.add(Duration(days: daysUntilSunday > 1 ? 1 : -1));
        final normalized = DateGroupingUtil.normalizeDateToDay(dateInThisWeek);

        // Act
        final label = DateGroupingUtil.getSmartDateLabel(normalized);

        // Assert
        expect(label, 'This Week');
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
        final yesterday = today.subtract(const Duration(days: 1));
        final twoDaysAgo = today.subtract(const Duration(days: 2));

        final files = [
          _createTestFile('1', twoDaysAgo),
          _createTestFile('2', today),
          _createTestFile('3', yesterday),
        ];

        // Act
        final groups = DateGroupingUtil.groupFilesByDate(files);

        // Assert
        expect(groups.length, 3);
        expect(groups[0].label, 'Today');
        expect(groups[1].label, 'Yesterday');
        expect(groups[2].label, 'This Week'); // Two days ago should be in "This Week"
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
