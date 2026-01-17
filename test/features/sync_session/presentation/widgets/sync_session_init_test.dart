import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/presentation/widgets/sync_session_init.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SyncSessionInit()),
    );
  }

  group('SyncSessionInit', () {
    testWidgets('should display circular progress indicator', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display initializing message', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Starting synchronization...'), findsOneWidget);
    });

    testWidgets('should display connecting message', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Connecting with the server'), findsOneWidget);
    });

    testWidgets('should be centered', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Center), findsOneWidget);
    });
  });
}
