import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/dialogs/empty_trash_confirmation_dialog.dart';
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

  group('EmptyTrashConfirmationDialog', () {
    testWidgets('should display dialog when show is called', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  EmptyTrashConfirmationDialog.show(
                    context: context,
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

    testWidgets('should show delete sweep icon', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  EmptyTrashConfirmationDialog.show(
                    context: context,
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

      expect(find.byIcon(Icons.delete_sweep), findsOneWidget);
    });

    testWidgets('should show empty trash title', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  EmptyTrashConfirmationDialog.show(
                    context: context,
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

      expect(find.text('Empty'), findsWidgets);
    });

    testWidgets('should call onConfirm when confirmed', (tester) async {
      when(() => mockOnConfirm()).thenReturn(null);

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  EmptyTrashConfirmationDialog.show(
                    context: context,
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

      // Tap the confirm button (second "Empty trash" button)
      final confirmButtons = find.text('Empty');
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
                  EmptyTrashConfirmationDialog.show(
                    context: context,
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
                  EmptyTrashConfirmationDialog.show(
                    context: context,
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

    testWidgets('should show cancel button', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  EmptyTrashConfirmationDialog.show(
                    context: context,
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

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('build method returns SizedBox.shrink', (tester) async {
      final dialog = EmptyTrashConfirmationDialog(
        onConfirm: mockOnConfirm,
      );

      await tester.pumpWidget(
        createTestApp(child: dialog),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should close dialog on cancel', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  EmptyTrashConfirmationDialog.show(
                    context: context,
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

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(ModernDialog), findsNothing);
    });

    testWidgets('should close dialog on confirm', (tester) async {
      when(() => mockOnConfirm()).thenReturn(null);

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  EmptyTrashConfirmationDialog.show(
                    context: context,
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

      final confirmButtons = find.text('Empty');
      await tester.tap(confirmButtons.last);
      await tester.pumpAndSettle();

      expect(find.byType(ModernDialog), findsNothing);
    });
  });
}
