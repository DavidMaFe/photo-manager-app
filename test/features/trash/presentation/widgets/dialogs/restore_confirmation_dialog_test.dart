import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/dialogs/restore_confirmation_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class MockVoidCallback extends Mock {
  void call();
}

void main() {
  late MockVoidCallback mockOnConfirm;

  setUp(() {
    mockOnConfirm = MockVoidCallback();
  });

  Widget createTestApp({required Widget child}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  group('RestoreConfirmationDialog', () {
    testWidgets('should display dialog when show is called', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  RestoreConfirmationDialog.show(
                    context: context,
                    fileCount: 1,
                    onConfirm: mockOnConfirm,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(ModernDialog), findsOneWidget);
    });

    testWidgets('should show restore icon for single file', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  RestoreConfirmationDialog.show(
                    context: context,
                    fileCount: 1,
                    onConfirm: mockOnConfirm,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.restore), findsOneWidget);
    });

    testWidgets('should show correct title for single file', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  RestoreConfirmationDialog.show(
                    context: context,
                    fileCount: 1,
                    onConfirm: mockOnConfirm,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Restore'), findsWidgets);
    });

    testWidgets('should show correct title for multiple files',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  RestoreConfirmationDialog.show(
                    context: context,
                    fileCount: 5,
                    onConfirm: mockOnConfirm,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Restore 5 files'), findsOneWidget);
    });

    testWidgets('should call onConfirm when confirmed', (tester) async {
      when(() => mockOnConfirm()).thenReturn(null);

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  RestoreConfirmationDialog.show(
                    context: context,
                    fileCount: 1,
                    onConfirm: mockOnConfirm,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap the confirm button (second "Restore" button)
      final confirmButtons = find.text('Restore');
      await tester.tap(confirmButtons.last);
      await tester.pumpAndSettle();

      verify(() => mockOnConfirm()).called(1);
    });

    testWidgets('should not call onConfirm when cancelled', (tester) async {
      when(() => mockOnConfirm()).thenReturn(null);

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  RestoreConfirmationDialog.show(
                    context: context,
                    fileCount: 1,
                    onConfirm: mockOnConfirm,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => mockOnConfirm());
    });

    testWidgets('should use success dialog type', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  RestoreConfirmationDialog.show(
                    context: context,
                    fileCount: 1,
                    onConfirm: mockOnConfirm,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      final dialog = tester.widget<ModernDialog>(find.byType(ModernDialog));
      expect(dialog.type, DialogType.success);
    });

    testWidgets('should handle large file count', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  RestoreConfirmationDialog.show(
                    context: context,
                    fileCount: 999,
                    onConfirm: mockOnConfirm,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Restore 999 files'), findsOneWidget);
    });

    testWidgets('build method returns SizedBox.shrink', (tester) async {
      final dialog = RestoreConfirmationDialog(
        fileCount: 1,
        onConfirm: mockOnConfirm,
      );

      await tester.pumpWidget(
        createTestApp(child: dialog),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}
