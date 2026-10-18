import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_thumbnail_strip.dart';

import '../../../helpers/widget_test_helper.dart';

void main() {
  Future<void> pump(WidgetTester tester, {int currentIndex = 1, ValueChanged<int>? onSelected}) async {
    await tester.pumpWidget(makeTestableWidget(Scaffold(
      body: MediaViewerThumbnailStrip(
        itemCount: 3,
        currentIndex: currentIndex,
        thumbnailBuilder: (_, index) => ColoredBox(key: ValueKey('thumb-$index'), color: Colors.green),
        onSelected: onSelected ?? (_) {},
      ),
    )));
    await tester.pumpAndSettle();
  }

  AnimatedContainer frame(WidgetTester tester, int index) => tester.widget<AnimatedContainer>(
        find.ancestor(of: find.byKey(ValueKey('thumb-$index')), matching: find.byType(AnimatedContainer)),
      );

  group('MediaViewerThumbnailStrip', () {
    testWidgets('should draw the border of the current thumbnail over the photo', (tester) async {
      // Arrange & Act
      await pump(tester);

      // Assert: on top of the photo, so the photo never covers its corners
      final current = frame(tester, 1);
      final palette = tester.element(find.byKey(const ValueKey('thumb-1'))).palette;
      final over = current.foregroundDecoration! as BoxDecoration;
      expect((over.border! as Border).top.color, palette.onMedia);
      expect(over.borderRadius, BorderRadius.circular(8));
      expect((current.decoration! as BoxDecoration).border, isNull);
    });

    testWidgets('should not show a border on the other thumbnails', (tester) async {
      // Arrange & Act
      await pump(tester);

      // Assert
      final other = frame(tester, 0).foregroundDecoration! as BoxDecoration;
      expect((other.border! as Border).top.color.a, 0);
    });

    testWidgets('should select the tapped thumbnail', (tester) async {
      // Arrange
      int? selected;
      await pump(tester, onSelected: (index) => selected = index);

      // Act
      await tester.tap(find.byKey(const ValueKey('thumb-2')));

      // Assert
      expect(selected, 2);
    });
  });
}
