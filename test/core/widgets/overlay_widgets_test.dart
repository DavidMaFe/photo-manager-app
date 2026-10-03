import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/core/widgets/app_sheet.dart';
import 'package:photo_manager_app/core/widgets/modern_dialog.dart';

import '../../helpers/widget_test_helper.dart';

void main() {
  /// Pumps a button that runs [onPressed] with a context below the navigator.
  Future<void> pumpLauncher(WidgetTester tester, void Function(BuildContext) onPressed) {
    return tester.pumpWidget(makeTestableWidget(Scaffold(
      body: Builder(
        builder: (context) => TextButton(onPressed: () => onPressed(context), child: const Text('Open')),
      ),
    )));
  }

  group('AppDialog', () {
    testWidgets('should return true and call onPrimary on the primary action', (tester) async {
      // Arrange
      bool? result;
      var primaryCalls = 0;
      await pumpLauncher(tester, (context) async {
        result = await AppDialog.show(
          context: context,
          icon: Icons.logout,
          title: 'Sign out?',
          message: 'You can sign in again later.',
          primaryLabel: 'Sign out',
          secondaryLabel: 'Cancel',
          onPrimary: () => primaryCalls++,
        );
      });
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isTrue);
      expect(primaryCalls, 1);
      expect(find.text('Sign out?'), findsNothing);
    });

    testWidgets('should return false on the secondary action', (tester) async {
      // Arrange
      bool? result;
      await pumpLauncher(tester, (context) async {
        result = await AppDialog.show(
          context: context,
          title: 'Delete?',
          primaryLabel: 'Delete',
          secondaryLabel: 'Cancel',
          destructive: true,
        );
      });
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, isFalse);
    });

    testWidgets('should use the danger button when destructive', (tester) async {
      // Arrange
      await pumpLauncher(tester, (context) {
        AppDialog.show(context: context, title: 'Delete?', primaryLabel: 'Delete', destructive: true);
      });

      // Act
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Assert
      final button = tester.widget<AppButton>(find.widgetWithText(AppButton, 'Delete'));
      expect(button.variant, AppButtonVariant.danger);
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('should render extra content', (tester) async {
      // Arrange
      await pumpLauncher(tester, (context) {
        AppDialog.show(
          context: context,
          title: 'Heads up',
          primaryLabel: 'OK',
          content: const Text('Do not show again'),
        );
      });

      // Act
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Do not show again'), findsOneWidget);
    });
  });

  group('ModernDialog', () {
    final tones = {
      DialogType.success: AppDialogTone.safe,
      DialogType.danger: AppDialogTone.danger,
      DialogType.warning: AppDialogTone.review,
      DialogType.info: AppDialogTone.accent,
      DialogType.neutral: AppDialogTone.accent,
    };
    tones.forEach((type, tone) {
      test('should map $type to $tone', () {
        expect(ModernDialog.toneFor(type), tone);
      });
    });

    testWidgets('should keep the show API and render an AppDialog', (tester) async {
      // Arrange
      bool? result;
      var cancelCalls = 0;
      await pumpLauncher(tester, (context) async {
        result = await ModernDialog.show(
          context: context,
          type: DialogType.danger,
          icon: Icons.delete,
          title: 'Delete forever?',
          message: 'This cannot be undone.',
          cancelText: 'Cancel',
          confirmText: 'Delete',
          onCancel: () => cancelCalls++,
        );
      });
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Act
      final dialog = tester.widget<AppDialog>(find.byType(AppDialog));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(dialog.destructive, isTrue);
      expect(dialog.icon, Icons.delete);
      expect(result, isFalse);
      expect(cancelCalls, 1);
    });

    testWidgets('should hide the cancel button when cancelText is empty', (tester) async {
      // Arrange
      await pumpLauncher(tester, (context) {
        ModernDialog.show(
          context: context,
          type: DialogType.info,
          icon: Icons.info,
          title: 'Info',
          message: 'Message',
          confirmText: 'OK',
        );
      });

      // Act
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppButton), findsOneWidget);
    });
  });

  group('showAppSheet', () {
    testWidgets('should show the content and return the popped value', (tester) async {
      // Arrange
      String? result;
      await pumpLauncher(tester, (context) async {
        result = await showAppSheet<String>(
          context,
          builder: (sheetContext) => TextButton(
            onPressed: () => Navigator.of(sheetContext).pop('picked'),
            child: const Text('Pick'),
          ),
        );
      });
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Act
      expect(find.byType(AppSheetBody), findsOneWidget);
      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, 'picked');
    });
  });
}
