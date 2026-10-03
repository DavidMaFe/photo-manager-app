import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
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
  });
}
