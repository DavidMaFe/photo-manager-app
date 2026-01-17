import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';
import 'package:photo_manager_app/features/sync_session/presentation/widgets/sync_session_success_view.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest(SyncResult result) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SyncSessionSuccessView(result: result)),
    );
  }

  group('SyncSessionSuccessView', () {
    testWidgets('should display success icon when all files uploaded', (tester) async {
      // Arrange
      final result = SyncResult(totalFiles: 10, uploadedFiles: 10, failedFiles: 0);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(result));

      // Assert
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should display info icon when some files failed', (tester) async {
      // Arrange
      final result = SyncResult(totalFiles: 10, uploadedFiles: 8, failedFiles: 2);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(result));

      // Assert
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should display completed title when all files uploaded', (tester) async {
      // Arrange
      final result = SyncResult(totalFiles: 10, uploadedFiles: 10, failedFiles: 0);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(result));

      // Assert
      expect(find.text('Synchronization completed'), findsOneWidget);
    });

    testWidgets('should display finished title when some files failed', (tester) async {
      // Arrange
      final result = SyncResult(totalFiles: 10, uploadedFiles: 8, failedFiles: 2);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(result));

      // Assert
      expect(find.text('Synchronization finished'), findsOneWidget);
    });

    testWidgets('should display total files count', (tester) async {
      // Arrange
      final result = SyncResult(totalFiles: 15, uploadedFiles: 12, failedFiles: 3);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(result));

      // Assert
      expect(find.text('15 files'), findsOneWidget);
    });

    testWidgets('should display uploaded files count', (tester) async {
      // Arrange
      final result = SyncResult(totalFiles: 15, uploadedFiles: 12, failedFiles: 3);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(result));

      // Assert
      expect(find.text('12 files'), findsOneWidget);
    });

    testWidgets('should display failed files count when failures exist', (tester) async {
      // Arrange
      final result = SyncResult(totalFiles: 15, uploadedFiles: 12, failedFiles: 3);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(result));

      // Assert
      expect(find.text('3 files'), findsOneWidget);
    });

    testWidgets('should not display failed files row when no failures', (tester) async {
      // Arrange
      final result = SyncResult(totalFiles: 10, uploadedFiles: 10, failedFiles: 0);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(result));

      // Assert
      // Should only have 2 stat rows (total and uploaded), not 3
      final statRows = tester.widgetList<Row>(find.byWidgetPredicate(
        (widget) => widget is Row && widget.mainAxisAlignment == MainAxisAlignment.spaceBetween
      ));
      expect(statRows.length, equals(2));
    });

    testWidgets('should display go back button', (tester) async {
      // Arrange
      final result = SyncResult(totalFiles: 10, uploadedFiles: 10, failedFiles: 0);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(result));

      // Assert
      expect(find.text('Return'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
