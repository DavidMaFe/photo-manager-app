import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/core/widgets/empty_state.dart';
import 'package:photo_manager_app/core/widgets/icon_circle_button.dart';
import 'package:photo_manager_app/core/widgets/list_row.dart';
import 'package:photo_manager_app/core/widgets/screen_header.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/core/widgets/section_label.dart';
import 'package:photo_manager_app/core/widgets/status_chip.dart';

import '../../helpers/widget_test_helper.dart';

void main() {
  const p = AppPalette.light;

  group('AppCard', () {
    testWidgets('should use the surface color and call onTap', (tester) async {
      // Arrange
      var taps = 0;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: AppCard(onTap: () => taps++, child: const Text('Card')),
      )));

      // Act
      await tester.tap(find.text('Card'));
      final material = tester.widget<Material>(
        find.descendant(of: find.byType(AppCard), matching: find.byType(Material)),
      );

      // Assert
      expect(material.color, p.surface);
      expect(taps, 1);
    });

    testWidgets('should use the dark surface in dark mode', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(
        const Scaffold(body: AppCard(child: Text('Card'))),
        themeMode: ThemeMode.dark,
      ));

      // Act
      final material = tester.widget<Material>(
        find.descendant(of: find.byType(AppCard), matching: find.byType(Material)),
      );

      // Assert
      expect(material.color, AppPalette.dark.surface);
    });
  });

  group('SectionLabel', () {
    testWidgets('should render the text in uppercase', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(body: SectionLabel('Copia y espacio'))));

      // Assert
      expect(find.text('COPIA Y ESPACIO'), findsOneWidget);
    });
  });

  group('ListRow', () {
    testWidgets('should show title, subtitle, value and chevron when tappable', (tester) async {
      // Arrange
      var taps = 0;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: ListRow(
          icon: Icons.devices,
          title: 'Devices',
          subtitle: '3 linked',
          value: 'On',
          onTap: () => taps++,
        ),
      )));

      // Act
      await tester.tap(find.text('Devices'));

      // Assert
      expect(find.text('3 linked'), findsOneWidget);
      expect(find.text('On'), findsOneWidget);
      expect(find.byType(Icon), findsNWidgets(2));
      expect(taps, 1);
    });

    testWidgets('should hide the chevron when not tappable', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(body: ListRow(title: 'Plain'))));

      // Assert
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('should place indented dividers between grouped rows', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(
        body: ListRowGroup(children: [ListRow(title: 'A'), ListRow(title: 'B'), ListRow(title: 'C')]),
      )));

      // Act
      final dividers = tester.widgetList<Divider>(find.byType(Divider));

      // Assert
      expect(dividers.length, 2);
      expect(dividers.first.indent, ListRow.dividerIndent);
    });
  });

  group('IconCircleButton', () {
    testWidgets('should be 44x44 with a tooltip and call onPressed', (tester) async {
      // Arrange
      var taps = 0;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: Center(
          child: IconCircleButton(icon: Icons.share, tooltip: 'Share', onPressed: () => taps++),
        ),
      )));

      // Act
      await tester.tap(find.byType(IconCircleButton));

      // Assert
      expect(tester.getSize(find.byType(InkWell)), const Size(44, 44));
      expect(find.byTooltip('Share'), findsOneWidget);
      expect(taps, 1);
    });
  });

  group('SecondaryTopBar', () {
    testWidgets('should show the title and pop on back', (tester) async {
      // Arrange
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(makeTestableWidget(
        const Scaffold(body: Text('Home')),
        navigatorKey: navigatorKey,
      ));
      navigatorKey.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(appBar: SecondaryTopBar(title: 'Trash'), body: SizedBox()),
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(IconCircleButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Trash'), findsNothing);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('should render actions and hide back when showBack is false', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(
        appBar: SecondaryTopBar(title: 'Settings', showBack: false, actions: [Text('Act')]),
      )));

      // Assert
      expect(find.byType(IconCircleButton), findsNothing);
      expect(find.text('Act'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('ScreenHeader', () {
    testWidgets('should use the headlineMedium style and show actions', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(
        body: ScreenHeader(title: 'Photos', actions: [Text('Avatar')]),
      )));

      // Act
      final text = tester.widget<Text>(find.text('Photos'));

      // Assert
      expect(text.style!.fontSize, 30);
      expect(find.text('Avatar'), findsOneWidget);
    });
  });

  group('StatusChip', () {
    final cases = {
      StatusChipVariant.safe: (p.safeSoft, p.safeInk),
      StatusChipVariant.review: (p.reviewSoft, p.reviewInk),
      StatusChipVariant.danger: (p.dangerSoft, p.dangerInk),
      StatusChipVariant.neutral: (p.surface2, p.ink),
      StatusChipVariant.accent: (p.accentSoft, p.accentInk),
    };
    cases.forEach((variant, colors) {
      testWidgets('should use soft background and ink text for $variant', (tester) async {
        // Arrange
        await tester.pumpWidget(makeTestableWidget(Scaffold(
          body: Center(child: StatusChip(label: 'Up to date', icon: Icons.cloud_done, variant: variant)),
        )));

        // Act
        final material = tester.widget<Material>(
          find.descendant(of: find.byType(StatusChip), matching: find.byType(Material)),
        );
        final text = tester.widget<Text>(find.text('Up to date'));

        // Assert
        expect(material.color, colors.$1);
        expect(text.style!.color, colors.$2);
      });
    });

    testWidgets('should be 30 high when compact', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(
        body: Center(child: StatusChip(label: 'WiFi', compact: true)),
      )));

      // Assert
      expect(tester.getSize(find.byType(StatusChip)).height, 30);
    });
  });

  group('EmptyState', () {
    testWidgets('should show icon, texts and call the action', (tester) async {
      // Arrange
      var taps = 0;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: EmptyState(
          icon: Icons.photo,
          title: 'No photos yet',
          message: 'Sync your phone',
          actionLabel: 'Back up now',
          onAction: () => taps++,
        ),
      )));

      // Act
      await tester.tap(find.text('Back up now'));

      // Assert
      expect(find.byIcon(Icons.photo), findsOneWidget);
      expect(find.text('No photos yet'), findsOneWidget);
      expect(find.text('Sync your phone'), findsOneWidget);
      expect(taps, 1);
    });

    testWidgets('should hide the button without an action', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(
        body: EmptyState(icon: Icons.photo, title: 'Empty'),
      )));

      // Assert
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });
  });
}
