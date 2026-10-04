import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_nav_bar.dart';
import 'package:photo_manager_app/core/widgets/media_grid.dart';
import 'package:photo_manager_app/core/widgets/media_thumbnail.dart';

import '../../helpers/widget_test_helper.dart';

void main() {
  const p = AppPalette.light;
  const image = ColoredBox(color: Color(0xFF888888));

  Widget thumb(MediaThumbnail child) => makeTestableWidget(
        Scaffold(body: Center(child: SizedBox.square(dimension: 120, child: child))),
      );

  group('MediaThumbnail', () {
    testWidgets('should show the review dot when pending', (tester) async {
      // Arrange
      await tester.pumpWidget(thumb(const MediaThumbnail(image: image, isPending: true)));

      // Act
      final dots = tester.widgetList<Container>(find.byType(Container)).where((c) {
        final d = c.decoration;
        return d is BoxDecoration && d.color == p.review;
      });

      // Assert
      expect(dots, hasLength(1));
    });

    testWidgets('should show the play icon and formatted duration for videos', (tester) async {
      // Arrange
      await tester.pumpWidget(thumb(const MediaThumbnail(
        image: image,
        isVideo: true,
        videoDuration: Duration(seconds: 75),
      )));

      // Assert
      expect(find.byIcon(Symbols.play_arrow_rounded), findsOneWidget);
      expect(find.text('1:15'), findsOneWidget);
    });

    testWidgets('should show the check and shrink the image when selected', (tester) async {
      // Arrange
      await tester.pumpWidget(thumb(const MediaThumbnail(image: image, selectable: true, selected: true)));
      await tester.pumpAndSettle();

      // Act
      final padding = tester.widget<AnimatedPadding>(find.byType(AnimatedPadding));

      // Assert
      expect(find.byIcon(Symbols.check_circle_rounded), findsOneWidget);
      expect(padding.padding, const EdgeInsets.all(7));
    });

    testWidgets('should hide the review dot in selection mode', (tester) async {
      // Arrange
      await tester.pumpWidget(thumb(const MediaThumbnail(image: image, isPending: true, selectable: true)));

      // Act
      final dots = tester.widgetList<Container>(find.byType(Container)).where((c) {
        final d = c.decoration;
        return d is BoxDecoration && d.color == p.review;
      });

      // Assert
      expect(dots, isEmpty);
      expect(find.byIcon(Symbols.check_circle_rounded), findsNothing);
    });

    // ==================== FAVORITE TESTS ====================

    Icon heart(WidgetTester tester) => tester.widget<Icon>(find.byIcon(Symbols.favorite_rounded));
    Offset heartOffset(WidgetTester tester) =>
        tester.getBottomLeft(find.byIcon(Symbols.favorite_rounded)) - tester.getBottomLeft(find.byType(MediaThumbnail));

    testWidgets('should show a white filled heart at the bottom left of favorites', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(thumb(const MediaThumbnail(image: image, isFavorite: true)));

      // Assert
      expect(heart(tester).color, p.onMedia);
      expect(heart(tester).fill, 1);
      expect(heart(tester).size, 18);
      expect(heart(tester).shadows, isNotEmpty);
      expect(heartOffset(tester), const Offset(6, -6));
    });

    testWidgets('should hide the heart when the file is not a favorite', (tester) async {
      await tester.pumpWidget(thumb(const MediaThumbnail(image: image)));
      expect(find.byIcon(Symbols.favorite_rounded), findsNothing);
    });

    testWidgets('should use a bigger heart on the large tile', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(thumb(const MediaThumbnail(image: image, isFavorite: true, large: true)));

      // Assert
      expect(heart(tester).size, 20);
      expect(heartOffset(tester), const Offset(8, -8));
    });

    testWidgets('should move the heart in with the image when selected, without overlapping', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(thumb(const MediaThumbnail(
        image: image,
        isFavorite: true,
        isVideo: true,
        videoDuration: Duration(seconds: 5),
        selectable: true,
        selected: true,
      )));
      await tester.pumpAndSettle();

      // Assert
      expect(heartOffset(tester), const Offset(13, -13));
      final heartRect = tester.getRect(find.byIcon(Symbols.favorite_rounded));
      final playRect = tester.getRect(find.byIcon(Symbols.play_arrow_rounded));
      final checkRect = tester.getRect(find.byIcon(Symbols.check_circle_rounded));
      expect(heartRect.overlaps(playRect), isFalse);
      expect(heartRect.overlaps(checkRect), isFalse);
    });

    testWidgets('should let the trash badge take the bottom left corner', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(thumb(const MediaThumbnail(
        image: image,
        isFavorite: true,
        bottomLeftBadge: Text('12 d'),
      )));

      // Assert
      expect(find.text('12 d'), findsOneWidget);
      expect(find.byIcon(Symbols.favorite_rounded), findsNothing);
    });

    // ==================== COVER BADGE TESTS ====================

    testWidgets('should show the cover badge at the top left', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(thumb(const MediaThumbnail(image: image, coverLabel: 'Cover')));

      // Assert
      expect(find.text('Cover'), findsOneWidget);
      final badge = tester.getRect(find.ancestor(of: find.text('Cover'), matching: find.byType(Container)).first);
      final thumbnail = tester.getRect(find.byType(MediaThumbnail));
      expect(badge.topLeft - thumbnail.topLeft, const Offset(6, 6));
      expect(badge.height, 22);
      final icon = tester.widget<Icon>(find.byIcon(Symbols.auto_awesome_mosaic_rounded));
      expect(icon.size, 14);
      expect(icon.color, p.accentInk);
    });

    testWidgets('should shrink the cover badge in selection mode, clear of the selection circle', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(thumb(const MediaThumbnail(image: image, coverLabel: 'Cover', selectable: true)));

      // Assert
      final badge = tester.getRect(find.ancestor(of: find.text('Cover'), matching: find.byType(Container)).first);
      expect(badge.height, 20);
      expect(tester.widget<Icon>(find.byIcon(Symbols.auto_awesome_mosaic_rounded)).size, 12);
      final circle = tester.getRect(find.ancestor(of: find.byType(MediaThumbnail), matching: find.byType(Center)));
      expect(badge.right, lessThan(circle.right - 30));
    });

    testWidgets('should fit favorite, cover, video and selection together without overlapping', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(thumb(const MediaThumbnail(
        image: image,
        isFavorite: true,
        coverLabel: 'Cover',
        isVideo: true,
        videoDuration: Duration(seconds: 75),
        selectable: true,
        selected: true,
      )));
      await tester.pumpAndSettle();

      // Assert
      final rects = [
        tester.getRect(find.ancestor(of: find.text('Cover'), matching: find.byType(Container)).first),
        tester.getRect(find.byIcon(Symbols.favorite_rounded)),
        tester.getRect(find.ancestor(of: find.text('1:15'), matching: find.byType(Container)).first),
        tester.getRect(find.byIcon(Symbols.check_circle_rounded)),
      ];
      for (var i = 0; i < rects.length; i++) {
        for (var j = i + 1; j < rects.length; j++) {
          expect(rects[i].overlaps(rects[j]), isFalse, reason: 'indicators $i and $j overlap');
        }
      }
    });

    testWidgets('should keep the indicators inside the thumbnail label, not as separate nodes', (tester) async {
      // Arrange
      final handle = tester.ensureSemantics();

      // Act
      await tester.pumpWidget(thumb(const MediaThumbnail(
        image: image,
        isFavorite: true,
        coverLabel: 'Cover',
        semanticLabel: 'Image, Favorite, Cover',
      )));

      // Assert
      expect(find.bySemanticsLabel('Image, Favorite, Cover'), findsOneWidget);
      expect(find.bySemanticsLabel('Cover'), findsNothing);
      handle.dispose();
    });

    testWidgets('should take the cover badge colors from the dark palette', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(
        const Scaffold(
          body: Center(child: SizedBox.square(dimension: 120, child: MediaThumbnail(image: image, coverLabel: 'Cover'))),
        ),
        themeMode: ThemeMode.dark,
      ));

      // Assert
      const dark = AppPalette.dark;
      final badge = tester.widget<Container>(find.ancestor(of: find.text('Cover'), matching: find.byType(Container)).first);
      expect((badge.decoration! as BoxDecoration).color, dark.coverBadgeBg);
      expect(tester.widget<Text>(find.text('Cover')).style!.color, dark.accentInk);
    });

    testWidgets('should not show the cover badge by default', (tester) async {
      await tester.pumpWidget(thumb(const MediaThumbnail(image: image)));
      expect(find.byIcon(Symbols.auto_awesome_mosaic_rounded), findsNothing);
    });

    testWidgets('should forward taps and long presses', (tester) async {
      // Arrange
      var taps = 0;
      var longPresses = 0;
      await tester.pumpWidget(thumb(MediaThumbnail(
        image: image,
        onTap: () => taps++,
        onLongPress: () => longPresses++,
      )));

      // Act
      await tester.tap(find.byType(MediaThumbnail));
      await tester.longPress(find.byType(MediaThumbnail));

      // Assert
      expect(taps, 1);
      expect(longPresses, 1);
    });

    test('should format durations with hours when needed', () {
      expect(MediaThumbnail.formatDuration(const Duration(seconds: 5)), '0:05');
      expect(MediaThumbnail.formatDuration(const Duration(hours: 1, minutes: 2, seconds: 3)), '1:02:03');
    });
  });

  group('MediaGrid', () {
    group('rowCount', () {
      test('should fit up to three items in the first row', () {
        expect(MediaGrid.rowCount(0), 0);
        expect(MediaGrid.rowCount(1), 1);
        expect(MediaGrid.rowCount(3), 1);
        expect(MediaGrid.rowCount(4), 2);
        expect(MediaGrid.rowCount(6), 2);
        expect(MediaGrid.rowCount(7), 3);
      });
    });

    testWidgets('should render headers and make the first item 2x2', (tester) async {
      // Arrange
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var actions = 0;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: CustomScrollView(slivers: [
          MediaGrid(
            groups: [
              MediaGridGroup(
                title: 'Today',
                subtitle: 'Thu, 1 Oct',
                itemCount: 5,
                actionLabel: 'Select',
                onAction: () => actions++,
              ),
            ],
            itemBuilder: (_, g, i) => ColoredBox(key: ValueKey('item-$i'), color: p.surface2),
          ),
        ]),
      )));

      // Act
      await tester.tap(find.text('Select'));
      final big = tester.getSize(find.byKey(const ValueKey('item-0')));
      final small = tester.getSize(find.byKey(const ValueKey('item-1')));
      final row2 = tester.getSize(find.byKey(const ValueKey('item-3')));

      // Assert
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Thu, 1 Oct'), findsOneWidget);
      expect(actions, 1);
      expect(big.width, closeTo(small.width * 2 + 3, 0.01));
      expect(big.height, big.width);
      expect(row2.width, closeTo(small.width, 0.01));
      expect(find.byKey(const ValueKey('item-4')), findsOneWidget);
    });
  });

  group('AppNavBar', () {
    const destinations = [
      AppNavDestination(icon: Symbols.photo_library_rounded, label: 'Photos'),
      AppNavDestination(icon: Symbols.photo_album_rounded, label: 'Albums'),
      AppNavDestination(icon: Symbols.cloud_sync_rounded, label: 'Backup'),
      AppNavDestination(icon: Symbols.person_rounded, label: 'Profile'),
    ];

    testWidgets('should show every label and report taps', (tester) async {
      // Arrange
      int? tapped;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        bottomNavigationBar: AppNavBar(
          destinations: destinations,
          currentIndex: 0,
          onTap: (i) => tapped = i,
        ),
      )));

      // Act
      await tester.tap(find.text('Backup'));

      // Assert
      for (final d in destinations) {
        expect(find.text(d.label), findsOneWidget);
      }
      expect(tapped, 2);
    });

    testWidgets('should fill and color the active icon', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        bottomNavigationBar: AppNavBar(destinations: destinations, currentIndex: 1, onTap: (_) {}),
      )));

      // Act
      final active = tester.widget<Icon>(find.byIcon(Symbols.photo_album_rounded));
      final inactive = tester.widget<Icon>(find.byIcon(Symbols.photo_library_rounded));
      final activeLabel = tester.widget<Text>(find.text('Albums'));

      // Assert
      expect(active.fill, 1);
      expect(active.color, p.accentInk);
      expect(inactive.fill, 0);
      expect(inactive.color, p.ink2);
      expect(activeLabel.style!.fontWeight, FontWeight.w800);
    });
  });
}
