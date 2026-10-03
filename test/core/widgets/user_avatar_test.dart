import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/widgets/media_grid_skeleton.dart';
import 'package:photo_manager_app/core/widgets/user_avatar.dart';

import '../../helpers/widget_test_helper.dart';

void main() {
  group('UserAvatar', () {
    group('initialsOf', () {
      test('should combine name and surname initials', () {
        expect(UserAvatar.initialsOf('ana', 'lópez'), 'AL');
      });

      test('should use the first two words of the name without surname', () {
        expect(UserAvatar.initialsOf('María José'), 'MJ');
        expect(UserAvatar.initialsOf('Ana'), 'A');
      });

      test('should fall back to a question mark for blank names', () {
        expect(UserAvatar.initialsOf('  '), '?');
      });
    });

    testWidgets('should keep a 44 px touch target and call onTap', (tester) async {
      // Arrange
      var taps = 0;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: Center(child: UserAvatar(name: 'Ana', size: 36, semanticLabel: 'Open profile', onTap: () => taps++)),
      )));

      // Act
      await tester.tap(find.byType(UserAvatar));

      // Assert
      expect(tester.getSize(find.byType(UserAvatar)).width, greaterThanOrEqualTo(44));
      expect(find.byTooltip('Open profile'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(taps, 1);
    });
  });

  group('MediaGridSkeleton', () {
    testWidgets('should render the placeholder tiles', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(body: MediaGridSkeleton(itemCount: 6))));

      // Assert
      expect(find.byType(DecoratedBox), findsWidgets);
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
