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
