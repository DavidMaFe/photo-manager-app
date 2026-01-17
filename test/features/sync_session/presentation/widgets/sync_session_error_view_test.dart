import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/presentation/widgets/sync_session_error_view.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest({String message = 'Test error message'}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SyncSessionErrorView(
          message: message,
          onRetry: () {},
        ),
      ),
    );
  }

  group('SyncSessionErrorView', () {
    testWidgets('should display error icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display error message', (tester) async {
      // Arrange
      const errorMessage = 'Network connection failed';

      // Act
      await tester.pumpWidget(createWidgetUnderTest(message: errorMessage));

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should display try again button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('should display go back button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Return'), findsOneWidget);
    });

    testWidgets('should have two buttons', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('should call onRetry when try again button tapped', (tester) async {
      // Arrange
      bool retryCalled = false;
      final widget = MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SyncSessionErrorView(
            message: 'Test error',
            onRetry: () => retryCalled = true,
          ),
        ),
      );
      await tester.pumpWidget(widget);

      // Act
      await tester.tap(find.text('Try again'));
      await tester.pump();

      // Assert
      expect(retryCalled, isTrue);
    });
  });
}
