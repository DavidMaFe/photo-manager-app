import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/devices/presentation/widgets/devices_empty_state.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  group('DevicesEmptyState', () {
    testWidgets('should display empty device icon', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const DevicesEmptyState(),
      ));

      expect(find.byIcon(Icons.devices_outlined), findsOneWidget);
    });

    testWidgets('should display empty state title', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const DevicesEmptyState(),
      ));

      // Check for text widgets (actual text depends on localization)
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should center content on screen', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const DevicesEmptyState(),
      ));

      // DevicesEmptyState returns a Center widget
      expect(find.byType(DevicesEmptyState), findsOneWidget);
      final emptyState = tester.widget<Center>(find.descendant(
        of: find.byType(DevicesEmptyState),
        matching: find.byType(Center),
      ).first);
      expect(emptyState.alignment, Alignment.center);
    });

    testWidgets('should have proper spacing between elements',
        (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const DevicesEmptyState(),
      ));

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('should display icon with appropriate size', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const DevicesEmptyState(),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.devices_outlined));
      expect(icon.size, 80);
    });

    testWidgets('should display description text', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const DevicesEmptyState(),
      ));

      // There should be at least 2 text widgets: title and description
      expect(find.byType(Text), findsAtLeastNWidgets(2));
    });

    testWidgets('should use Column layout', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const DevicesEmptyState(),
      ));

      final columnFinder = find.descendant(
        of: find.byType(Center),
        matching: find.byType(Column),
      );
      expect(columnFinder, findsWidgets);
      final column = tester.widget<Column>(columnFinder.first);
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('should have padding around content', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const DevicesEmptyState(),
      ));

      expect(find.byType(Padding), findsWidgets);
    });
  });
}
