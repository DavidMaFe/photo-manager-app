import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/album_mosaic.dart';

import '../../../../helpers/widget_test_helper.dart';

void main() {
  /// A labelled box per photo, instead of the network thumbnail.
  Widget photo(BuildContext context, String fileId) => ColoredBox(
        key: ValueKey('photo-$fileId'),
        color: const Color(0xFF888888),
      );

  Future<void> pump(WidgetTester tester, List<String> ids, {double size = 182}) {
    return tester.pumpWidget(makeTestableWidget(Scaffold(
      body: Center(
        child: SizedBox.square(
          dimension: size,
          child: AlbumMosaic(fileIds: ids, radius: 22, imageBuilder: photo),
        ),
      ),
    )));
  }

  Rect rectOf(WidgetTester tester, String id) => tester.getRect(find.byKey(ValueKey('photo-$id')));

  group('AlbumMosaic', () {
    testWidgets('should show the album icon without photos', (tester) async {
      // Arrange & Act
      await pump(tester, const []);

      // Assert
      expect(find.byIcon(Symbols.photo_album_rounded), findsOneWidget);
      expect(tester.widget<Icon>(find.byIcon(Symbols.photo_album_rounded)).size, 36);
    });

    testWidgets('should fill the cover with a single photo', (tester) async {
      // Arrange & Act
      await pump(tester, const ['a']);

      // Assert
      expect(rectOf(tester, 'a').size, const Size(182, 182));
      expect(find.byIcon(Symbols.photo_album_rounded), findsNothing);
    });

    testWidgets('should split two photos in equal columns with a 2 px gap', (tester) async {
      // Arrange & Act
      await pump(tester, const ['a', 'b']);

      // Assert
      expect(rectOf(tester, 'a').size, const Size(90, 182));
      expect(rectOf(tester, 'b').size, const Size(90, 182));
      expect(rectOf(tester, 'b').left - rectOf(tester, 'a').right, 2);
    });

    testWidgets('should show one big photo and two small ones stacked for three photos', (tester) async {
      // Arrange & Act
      await pump(tester, const ['a', 'b', 'c']);

      // Assert: 180 px of width split 2fr / 1fr
      expect(rectOf(tester, 'a').size, const Size(120, 182));
      expect(rectOf(tester, 'b').size, const Size(60, 90));
      expect(rectOf(tester, 'c').size, const Size(60, 90));
      expect(rectOf(tester, 'b').left, rectOf(tester, 'c').left);
      expect(rectOf(tester, 'c').top - rectOf(tester, 'b').bottom, 2);
    });

    testWidgets('should use only the first three photos', (tester) async {
      // Arrange & Act
      await pump(tester, const ['a', 'b', 'c', 'd']);

      // Assert
      expect(find.byKey(const ValueKey('photo-d')), findsNothing);
    });

    testWidgets('should round the corners with the given radius', (tester) async {
      // Arrange & Act
      await pump(tester, const ['a']);

      // Assert
      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clip.borderRadius, BorderRadius.circular(22));
    });
  });
}
