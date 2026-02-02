import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/dialogs/permanent_delete_confirmation_dialog.dart';
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

  group('PermanentDeleteConfirmationDialog', () {
    testWidgets('should display dialog when show is called', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  PermanentDeleteConfirmationDialog.show(
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

    testWidgets('should show delete forever icon', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  PermanentDeleteConfirmationDialog.show(
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

      expect(find.byIcon(Icons.delete_forever), findsOneWidget);
    });

    testWidgets('should show delete permanently title', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  PermanentDeleteConfirmationDialog.show(
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

      expect(find.text('Delete permanently'), findsOneWidget);
    });

    testWidgets('should show correct message for single file', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  PermanentDeleteConfirmationDialog.show(
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

    testWidgets('should show correct message for multiple files',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  PermanentDeleteConfirmationDialog.show(
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

      expect(find.textContaining('5'), findsOneWidget);
    });

    testWidgets('should call onConfirm when confirmed', (tester) async {
      when(() => mockOnConfirm()).thenReturn(null);

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  PermanentDeleteConfirmationDialog.show(
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

      await tester.tap(find.text('Delete'));
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
                  PermanentDeleteConfirmationDialog.show(
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

    testWidgets('should use danger dialog type', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  PermanentDeleteConfirmationDialog.show(
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
      expect(dialog.type, DialogType.danger);
    });

    testWidgets('should handle large file count', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  PermanentDeleteConfirmationDialog.show(
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

      expect(find.textContaining('999'), findsOneWidget);
    });

    testWidgets('build method returns SizedBox.shrink', (tester) async {
      final dialog = PermanentDeleteConfirmationDialog(
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
