import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_stats.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('ProfileStats', () {
    final testProfile = UserProfile(
      id: '1',
      email: 'test@example.com',
      name: 'John',
      surname: 'Doe',
      storageUsedMb: 500,
      storageTotalMb: 1024,
      fileCount: 100,
      folderCount: 10,
      deviceCount: 2,
    );

    testWidgets('should have three stat items', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(ProfileStats(profile: testProfile)));

      // Assert
      final inkWells = find.byType(InkWell);
      expect(inkWells, findsNWidgets(3)); // Files, Folders, Devices
    });

    testWidgets('should have dividers between stats', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(ProfileStats(profile: testProfile)));

      // Assert
      final containers = tester.widgetList<Container>(find.byType(Container));
      final dividers = containers.where((c) => c.constraints?.maxHeight == 40 && c.constraints?.maxWidth == 1);
      expect(dividers.length, 2); // Two dividers between three stats
    });

    testWidgets('should format large numbers', (tester) async {
      // Arrange
      final profileWithLargeNumbers = UserProfile(
        id: '1',
        email: 'test@example.com',
        name: 'John',
        surname: 'Doe',
        storageUsedMb: 500,
        storageTotalMb: 1024,
        fileCount: 1000,
        folderCount: 10,
        deviceCount: 2,
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(ProfileStats(profile: profileWithLargeNumbers)));

      // Assert
      expect(find.text('1000'), findsOneWidget); // Number formatting
    });

    testWidgets('should have proper spacing between stats', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(ProfileStats(profile: testProfile)));

      // Assert
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceAround);
    });

    testWidgets('should display zero values correctly', (tester) async {
      // Arrange
      final profileWithZeros = UserProfile(
        id: '1',
        email: 'test@example.com',
        name: 'John',
        surname: 'Doe',
        storageUsedMb: 500,
        storageTotalMb: 1024,
        fileCount: 0,
        folderCount: 0,
        deviceCount: 0,
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(ProfileStats(profile: profileWithZeros)));

      // Assert
      expect(find.text('0'), findsNWidgets(3)); // All three stats are 0
    });
  });
}
