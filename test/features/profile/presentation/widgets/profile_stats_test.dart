import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_stats.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  Future<void> pump(WidgetTester tester, UserProfile profile, {Locale locale = const Locale('en')}) {
    return tester.pumpWidget(makeTestableWidget(Scaffold(body: ProfileStats(profile: profile)), locale: locale));
  }

  group('ProfileStats', () {
    testWidgets('should show items, albums and devices', (tester) async {
      // Arrange & Act
      await pump(tester, TestProfiles.johnDoeProfile);

      // Assert
      expect(find.text('150'), findsOneWidget);
      expect(find.text('items'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('albums'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('devices'), findsOneWidget);
    });

    testWidgets('should use singular labels for one', (tester) async {
      // Arrange & Act
      await pump(tester, TestProfiles.emptyStorageProfile);

      // Assert
      expect(find.text('device'), findsOneWidget);
    });

    testWidgets('should group thousands in the user locale', (tester) async {
      // Arrange & Act
      final profile = UserProfile(
        id: '9',
        email: 'a@b.com',
        name: 'Ana',
        hasProfileImage: false,
        storageUsedMb: 0,
        storageTotalMb: 1024,
        fileCount: 1248,
        folderCount: 12,
        deviceCount: 3,
      );
      await pump(tester, profile, locale: const Locale('es'));

      // Assert
      expect(find.text('1.248'), findsOneWidget);
      expect(find.text('elementos'), findsOneWidget);
    });

    testWidgets('should not draw vertical dividers', (tester) async {
      // Arrange & Act
      await pump(tester, TestProfiles.johnDoeProfile);

      // Assert
      expect(find.byType(VerticalDivider), findsNothing);
    });
  });
}
