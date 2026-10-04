import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/features/profile/domain/entities/storage_usage.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/storage_bar.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  Future<void> pump(WidgetTester tester, UserProfile profile) {
    return tester.pumpWidget(makeTestableWidget(Scaffold(body: StorageBar(profile: profile))));
  }

  LinearProgressIndicator bar(WidgetTester tester) =>
      tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));

  group('StorageBar', () {
    testWidgets('should show used of total storage', (tester) async {
      // Arrange & Act
      await pump(tester, TestProfiles.fullStorageProfile);

      // Assert
      expect(find.text('Storage'), findsOneWidget);
      expect(find.text('2 GB of 2 GB', findRichText: true), findsOneWidget);
    });

    testWidgets('should fill the bar with the usage percentage', (tester) async {
      // Arrange & Act
      await pump(tester, TestProfiles.johnDoeProfile);

      // Assert
      expect(bar(tester).value, closeTo(0.5, 0.01));
      expect(bar(tester).minHeight, 10);
    });

    testWidgets('should use a single accent color even when nearly full', (tester) async {
      // Arrange & Act
      await pump(tester, TestProfiles.highStorageProfile);

      // Assert
      final color = (bar(tester).valueColor! as AlwaysStoppedAnimation<Color>).value;
      expect(color, AppPalette.light.accent);
    });

    test('should format gigabytes with one decimal below 100 GB', () {
      expect(StorageBar.formatGb(12.4, 'en'), '12.4 GB');
      expect(StorageBar.formatGb(12.4, 'es'), '12,4 GB');
      expect(StorageBar.formatGb(50, 'es'), '50 GB');
      expect(StorageBar.formatGb(1234.5, 'es'), '1.235 GB');
    });

    // ==================== BREAKDOWN TESTS ====================

    group('with the storage breakdown', () {
      UserProfile withStorage(StorageUsage storage) => UserProfile(
            id: '1',
            email: 'ana@example.com',
            name: 'Ana',
            hasProfileImage: false,
            storageUsedMb: storage.usedBytes / (1024 * 1024),
            storageTotalMb: storage.quotaBytes ~/ (1024 * 1024),
            fileCount: 0,
            folderCount: 0,
            deviceCount: 0,
            storage: storage,
          );

      const mb = 1024 * 1024;
      const storage = StorageUsage(
        photosBytes: 400 * mb,
        videosBytes: 200 * mb,
        trashBytes: 100 * mb,
        usedBytes: 700 * mb,
        quotaBytes: 1000 * mb,
      );

      Future<void> pumpSized(WidgetTester tester, UserProfile profile, {ThemeMode themeMode = ThemeMode.light}) {
        return tester.pumpWidget(makeTestableWidget(
          Scaffold(body: Center(child: SizedBox(width: 304, child: StorageBar(profile: profile)))),
          themeMode: themeMode,
        ));
      }

      List<ColoredBox> segments(WidgetTester tester) => tester
          .widgetList<ColoredBox>(find.descendant(of: find.byType(Row), matching: find.byType(ColoredBox)))
          .where((box) => box.child == null)
          .toList();

      testWidgets('should split the bar into photos, videos and trash over the quota', (tester) async {
        // Arrange & Act
        await pumpSized(tester, withStorage(storage));

        // Assert
        expect(find.byType(LinearProgressIndicator), findsNothing);
        const p = AppPalette.light;
        final parts = segments(tester);
        expect(parts.map((s) => s.color), [p.accent, p.review, p.ink3]);
        // 304 px minus two 2 px gaps = 300 px: 40 %, 20 % and 10 %.
        final widths = parts.map((s) => tester.getSize(find.byWidget(s)).width).toList();
        expect(widths, [120, 60, 30]);
      });

      testWidgets('should show the legend with the size of each type', (tester) async {
        // Arrange & Act
        await pumpSized(tester, withStorage(storage));

        // Assert
        expect(find.text('Photos 400 MB'), findsOneWidget);
        expect(find.text('Videos 200 MB'), findsOneWidget);
        expect(find.text('Trash 100 MB'), findsOneWidget);
        expect(find.bySemanticsLabel('Photos 400 MB, Videos 200 MB, Trash 100 MB'), findsOneWidget);
      });

      testWidgets('should leave out empty types from the bar but keep them in the legend', (tester) async {
        // Arrange & Act
        await pumpSized(tester, withStorage(const StorageUsage(
          photosBytes: 500 * mb,
          videosBytes: 0,
          trashBytes: 0,
          usedBytes: 500 * mb,
          quotaBytes: 1000 * mb,
        )));

        // Assert
        expect(segments(tester), hasLength(1));
        expect(tester.getSize(find.byWidget(segments(tester).single)).width, 152);
        expect(find.text('Videos 0 B'), findsOneWidget);
      });

      testWidgets('should show an empty bar with no usage', (tester) async {
        // Arrange & Act
        await pumpSized(tester, withStorage(const StorageUsage(
          photosBytes: 0,
          videosBytes: 0,
          trashBytes: 0,
          usedBytes: 0,
          quotaBytes: 1000 * mb,
        )));

        // Assert
        expect(segments(tester), isEmpty);
        expect(find.text('Photos 0 B'), findsOneWidget);
      });

      testWidgets('should use the dark palette colors', (tester) async {
        // Arrange & Act
        await pumpSized(tester, withStorage(storage), themeMode: ThemeMode.dark);

        // Assert
        const dark = AppPalette.dark;
        expect(segments(tester).map((s) => s.color), [dark.accent, dark.review, dark.ink3]);
      });

      test('should fill the bar when the use goes over the quota', () {
        const over = StorageUsage(photosBytes: 150, videosBytes: 0, trashBytes: 0, usedBytes: 150, quotaBytes: 100);
        expect(over.fractionOf(150), 1);
        expect(const StorageUsage(photosBytes: 0, videosBytes: 0, trashBytes: 0, usedBytes: 0, quotaBytes: 0).fractionOf(0), 0);
      });
    });
  });
}
