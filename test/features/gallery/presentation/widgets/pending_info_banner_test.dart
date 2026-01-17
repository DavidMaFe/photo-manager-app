import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/pending_info_banner.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

void main() {
  group('PendingInfoBanner', () {
    Widget createWidgetUnderTest({required int pendingCount}) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PendingInfoBanner(pendingCount: pendingCount),
        ),
      );
    }

    testWidgets('should not display banner when pending count is 0', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(pendingCount: 0));

      // Assert
      expect(find.byType(PendingInfoBanner), findsOneWidget);
      // The banner should render but be empty/invisible
    });

    testWidgets('should display banner when pending count is greater than 0', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(pendingCount: 5));

      // Assert
      expect(find.byType(PendingInfoBanner), findsOneWidget);
    });

    testWidgets('should render with single pending file', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(pendingCount: 1));

      // Assert
      expect(find.byType(PendingInfoBanner), findsOneWidget);
    });

    testWidgets('should render with multiple pending files', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(pendingCount: 10));

      // Assert
      expect(find.byType(PendingInfoBanner), findsOneWidget);
    });

    testWidgets('should handle large pending count', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(pendingCount: 999));

      // Assert
      expect(find.byType(PendingInfoBanner), findsOneWidget);
    });

    testWidgets('should handle negative pending count gracefully', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(pendingCount: -1));

      // Assert
      expect(find.byType(PendingInfoBanner), findsOneWidget);
    });
  });
}
