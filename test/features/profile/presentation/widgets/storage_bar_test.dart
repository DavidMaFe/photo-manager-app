import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/storage_bar.dart';
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

  group('StorageBar', () {
    testWidgets('should display storage used and total in GB', (tester) async {
      // Arrange
      final testProfile = UserProfile(
        id: '1',
        email: 'test@example.com',
        name: 'John',
        storageUsedMb: 512,  // 0.5 GB
        storageTotalMb: 1024, // 1.0 GB
        fileCount: 100,
        folderCount: 10,
        deviceCount: 2,
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(StorageBar(profile: testProfile)));

      // Assert
      expect(find.text('0.5 / 1 GB'), findsOneWidget);
    });

    testWidgets('should set correct progress value', (tester) async {
      // Arrange
      final testProfile = UserProfile(
        id: '1',
        email: 'test@example.com',
        name: 'John',
        storageUsedMb: 512,  // 50% of 1024
        storageTotalMb: 1024,
        fileCount: 100,
        folderCount: 10,
        deviceCount: 2,
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(StorageBar(profile: testProfile)));

      // Assert
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, closeTo(0.5, 0.01));
    });

    testWidgets('should show blue color for low usage (< 50%)', (tester) async {
      // Arrange
      final testProfile = UserProfile(
        id: '1',
        email: 'test@example.com',
        name: 'John',
        storageUsedMb: 256,  // 25% of 1024
        storageTotalMb: 1024,
        fileCount: 100,
        folderCount: 10,
        deviceCount: 2,
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(StorageBar(profile: testProfile)));

      // Assert
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, Colors.blue);
    });

    testWidgets('should show orange color for medium usage (50-75%)', (tester) async {
      // Arrange
      final testProfile = UserProfile(
        id: '1',
        email: 'test@example.com',
        name: 'John',
        storageUsedMb: 640,  // 62.5% of 1024
        storageTotalMb: 1024,
        fileCount: 100,
        folderCount: 10,
        deviceCount: 2,
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(StorageBar(profile: testProfile)));

      // Assert
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, Colors.orange);
    });

    testWidgets('should show deep orange color for high usage (75-90%)', (tester) async {
      // Arrange
      final testProfile = UserProfile(
        id: '1',
        email: 'test@example.com',
        name: 'John',
        storageUsedMb: 819,  // 80% of 1024
        storageTotalMb: 1024,
        fileCount: 100,
        folderCount: 10,
        deviceCount: 2,
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(StorageBar(profile: testProfile)));

      // Assert
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, Colors.deepOrange);
    });

    testWidgets('should show red color for very high usage (>= 90%)', (tester) async {
      // Arrange
      final testProfile = UserProfile(
        id: '1',
        email: 'test@example.com',
        name: 'John',
        storageUsedMb: 922,  // 90% of 1024
        storageTotalMb: 1024,
        fileCount: 100,
        folderCount: 10,
        deviceCount: 2,
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(StorageBar(profile: testProfile)));

      // Assert
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, Colors.red);
    });
  });
}
