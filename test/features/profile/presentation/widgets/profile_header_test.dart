import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_header.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  Future<void> pump(WidgetTester tester, UserProfile profile, {VoidCallback? onEdit}) {
    return tester.pumpWidget(makeTestableWidget(Scaffold(body: ProfileHeader(profile: profile, onEdit: onEdit))));
  }

  group('ProfileHeader', () {
    testWidgets('should show initials, full name and email', (tester) async {
      // Arrange & Act
      await pump(tester, TestProfiles.emptyStorageProfile);

      // Assert
      expect(find.text('NU'), findsOneWidget);
      expect(find.text('New User'), findsOneWidget);
      expect(find.text('new.user@example.com'), findsOneWidget);
    });

    testWidgets('should show the email in secondary ink, not as a link', (tester) async {
      // Arrange & Act
      await pump(tester, TestProfiles.emptyStorageProfile);

      // Assert
      final email = tester.widget<Text>(find.text('new.user@example.com'));
      expect(email.style!.color, AppPalette.light.ink2);
    });

    testWidgets('should call onEdit from the Edit button', (tester) async {
      // Arrange
      var edits = 0;
      await pump(tester, TestProfiles.emptyStorageProfile, onEdit: () => edits++);

      // Act
      await tester.tap(find.text('Edit'));

      // Assert
      expect(edits, 1);
    });

    testWidgets('should hide the Edit button without callback', (tester) async {
      // Arrange & Act
      await pump(tester, TestProfiles.emptyStorageProfile);

      // Assert
      expect(find.text('Edit'), findsNothing);
    });
  });
}
