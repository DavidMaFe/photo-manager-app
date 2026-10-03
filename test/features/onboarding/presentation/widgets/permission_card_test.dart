import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/permissions/permission_access.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/onboarding/presentation/widgets/permission_card.dart';

import '../../../../helpers/widget_test_helper.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    PermissionAccess access, {
    bool recommended = false,
    VoidCallback? onAllow,
    VoidCallback? onSettings,
  }) {
    return tester.pumpWidget(makeTestableWidget(Scaffold(
      body: PermissionCard(
        icon: Symbols.photo_library_rounded,
        title: 'Photos and videos',
        description: 'To back them up and free up space',
        access: access,
        recommended: recommended,
        onAllow: onAllow ?? () {},
        onOpenSettings: onSettings ?? () {},
      ),
    )));
  }

  AppButton button(WidgetTester tester) => tester.widget<AppButton>(find.byType(AppButton));

  group('PermissionCard', () {
    testWidgets('should show the title and description', (tester) async {
      // Arrange & Act
      await pump(tester, PermissionAccess.pending);

      // Assert
      expect(find.text('Photos and videos'), findsOneWidget);
      expect(find.text('To back them up and free up space'), findsOneWidget);
    });

    testWidgets('should ask for the recommended permission with the primary button', (tester) async {
      // Arrange
      var allowed = 0;
      await pump(tester, PermissionAccess.pending, recommended: true, onAllow: () => allowed++);

      // Act
      await tester.tap(find.text('Allow'));

      // Assert
      expect(button(tester).variant, AppButtonVariant.primary);
      expect(allowed, 1);
    });

    testWidgets('should use a neutral button for the other permissions', (tester) async {
      // Arrange & Act
      await pump(tester, PermissionAccess.pending);

      // Assert
      expect(button(tester).variant, AppButtonVariant.neutral);
    });

    testWidgets('should show done once granted', (tester) async {
      // Arrange & Act
      await pump(tester, PermissionAccess.granted);

      // Assert
      expect(find.text('Done'), findsOneWidget);
      expect(find.byType(AppButton), findsNothing);
    });

    testWidgets('should send a blocked permission to the settings', (tester) async {
      // Arrange
      var opened = 0;
      await pump(tester, PermissionAccess.blocked, onSettings: () => opened++);

      // Act
      await tester.tap(find.text('Settings'));

      // Assert
      expect(opened, 1);
      expect(find.text('Allow'), findsNothing);
    });
  });
}
