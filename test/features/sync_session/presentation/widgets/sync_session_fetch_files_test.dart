import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/presentation/widgets/sync_session_fetch_files.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SyncSessionFetchFiles()),
    );
  }

  group('SyncSessionFetchFiles', () {
    testWidgets('should display circular progress indicator', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display fetching files message', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Fetching files from the gallery...'), findsOneWidget);
    });

    testWidgets('should display wait warning', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('This may take a few seconds'), findsOneWidget);
    });

    testWidgets('should be centered', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Center), findsOneWidget);
    });
  });
}
