import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_switch.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/core/widgets/filter_pill.dart';
import 'package:photo_manager_app/core/widgets/otp_field.dart';
import 'package:photo_manager_app/core/widgets/segmented_control.dart';

import '../../helpers/widget_test_helper.dart';

void main() {
  const p = AppPalette.light;

  group('AppTextField', () {
    testWidgets('should show label, trailing widget and forward changes', (tester) async {
      // Arrange
      String? changed;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: AppTextField(
          label: 'Password',
          labelTrailing: const Text('Forgot it?'),
          onChanged: (v) => changed = v,
        ),
      )));

      // Act
      await tester.enterText(find.byType(TextFormField), 'secret');

      // Assert
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot it?'), findsOneWidget);
      expect(changed, 'secret');
    });

    testWidgets('should switch to surface fill and halo when focused', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(body: AppTextField(label: 'Email'))));
      InputDecoration decoration() =>
          tester.widget<TextField>(find.byType(TextField)).decoration!;
      expect(decoration().fillColor, p.surface2);

      // Act
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      // Assert
      expect(decoration().fillColor, p.surface);
      final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      final shadows = (container.decoration as BoxDecoration).boxShadow!;
      expect(shadows.single.color, p.accentSoft);
    });

    testWidgets('should show validation errors from the validator', (tester) async {
      // Arrange
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: Form(
          key: formKey,
          child: AppTextField(validator: (v) => (v ?? '').isEmpty ? 'Required' : null),
        ),
      )));

      // Act
      formKey.currentState!.validate();
      await tester.pump();

      // Assert
      expect(find.text('Required'), findsOneWidget);
    });
  });

  group('OtpField', () {
    testWidgets('should render one box per digit', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(body: OtpField())));

      // Assert
      expect(find.byType(AnimatedContainer), findsNWidgets(6));
    });

    testWidgets('should keep only digits and call onCompleted with a pasted code', (tester) async {
      // Arrange
      String? completed;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: OtpField(onCompleted: (v) => completed = v),
      )));

      // Act
      await tester.enterText(find.byType(TextField), '12a3456');
      await tester.pump();

      // Assert
      expect(completed, '123456');
      for (final digit in ['1', '2', '3', '4', '5', '6']) {
        expect(find.text(digit), findsOneWidget);
      }
    });

    testWidgets('should not complete before all digits are entered', (tester) async {
      // Arrange
      String? completed;
      String? changed;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: OtpField(onCompleted: (v) => completed = v, onChanged: (v) => changed = v),
      )));

      // Act
      await tester.enterText(find.byType(TextField), '123');
      await tester.pump();

      // Assert
      expect(changed, '123');
      expect(completed, isNull);
    });
  });

  group('FilterPillBar', () {
    testWidgets('should highlight the selected pill and report taps', (tester) async {
      // Arrange
      String? tapped;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: FilterPillBar<String>(
          items: const [
            FilterPillItem(value: 'all', label: 'All'),
            FilterPillItem(value: 'pending', label: 'To review', count: 4),
          ],
          selected: 'all',
          onSelected: (v) => tapped = v,
        ),
      )));

      // Act
      await tester.tap(find.text('To review'));
      final pills = tester.widgetList<FilterPill>(find.byType(FilterPill)).toList();
      final selectedMaterial = tester.widget<Material>(
        find.descendant(of: find.byWidget(pills.first), matching: find.byType(Material)),
      );

      // Assert
      expect(tapped, 'pending');
      expect(pills.first.selected, isTrue);
      expect(selectedMaterial.color, p.ink);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('should hide the counter when it is zero', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(
        body: FilterPill(label: 'To review', selected: false, count: 0),
      )));

      // Assert
      expect(find.text('0'), findsNothing);
    });
  });

  group('SegmentedControl', () {
    testWidgets('should report the tapped segment and bold the selected one', (tester) async {
      // Arrange
      int? tapped;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: SegmentedControl<int>(
          segments: const [
            SegmentItem(value: 0, label: 'Daily'),
            SegmentItem(value: 1, label: 'Weekly'),
          ],
          selected: 0,
          onChanged: (v) => tapped = v,
        ),
      )));

      // Act
      await tester.tap(find.text('Weekly'));
      final daily = tester.widget<Text>(find.text('Daily'));
      final weekly = tester.widget<Text>(find.text('Weekly'));

      // Assert
      expect(tapped, 1);
      expect(daily.style!.fontWeight, FontWeight.w700);
      expect(daily.style!.color, p.ink);
      expect(weekly.style!.color, p.ink2);
    });

    testWidgets('should move the indicator to the selected segment', (tester) async {
      // Arrange
      Widget build(int selected) => makeTestableWidget(Scaffold(
            body: SegmentedControl<int>(
              segments: const [
                SegmentItem(value: 0, label: 'A'),
                SegmentItem(value: 1, label: 'B'),
              ],
              selected: selected,
              onChanged: (_) {},
            ),
          ));
      await tester.pumpWidget(build(0));

      // Act
      await tester.pumpWidget(build(1));
      await tester.pumpAndSettle();

      // Assert
      final align = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(align.alignment, const Alignment(1, 0));
    });
  });

  group('AppSwitch', () {
    testWidgets('should toggle and expose its semantic label', (tester) async {
      // Arrange
      bool? value;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: AppSwitch(value: false, semanticLabel: 'Auto backup', onChanged: (v) => value = v),
      )));

      // Act
      await tester.tap(find.byType(Switch));

      // Assert
      expect(value, isTrue);
      expect(find.bySemanticsLabel('Auto backup'), findsOneWidget);
    });
  });
}
