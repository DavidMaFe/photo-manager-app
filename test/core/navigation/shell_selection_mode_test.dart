import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/navigation/shell_selection_mode.dart';

void main() {
  group('ReportSelectionMode', () {
    late ValueNotifier<bool> notifier;

    setUp(() => notifier = ValueNotifier(false));
    tearDown(() => notifier.dispose());

    Widget build({required bool active, bool show = true}) {
      return ShellSelectionMode(
        notifier: notifier,
        child: show ? ReportSelectionMode(active: active, child: const SizedBox()) : const SizedBox(),
      );
    }

    testWidgets('should report selection mode to the shell', (tester) async {
      // Arrange
      await tester.pumpWidget(build(active: false));
      await tester.pump();
      expect(notifier.value, isFalse);

      // Act
      await tester.pumpWidget(build(active: true));
      await tester.pump();

      // Assert
      expect(notifier.value, isTrue);
    });

    testWidgets('should clear the flag when selection ends', (tester) async {
      // Arrange
      await tester.pumpWidget(build(active: true));
      await tester.pump();

      // Act
      await tester.pumpWidget(build(active: false));
      await tester.pump();

      // Assert
      expect(notifier.value, isFalse);
    });

    testWidgets('should clear the flag when the page is removed while selecting', (tester) async {
      // Arrange
      await tester.pumpWidget(build(active: true));
      await tester.pump();

      // Act
      await tester.pumpWidget(build(active: true, show: false));
      await tester.pump();

      // Assert
      expect(notifier.value, isFalse);
    });

    testWidgets('should do nothing outside the shell', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(const ReportSelectionMode(active: true, child: SizedBox()));
      await tester.pump();

      // Assert: no exception without a ShellSelectionMode above.
      expect(tester.takeException(), isNull);
    });
  });
}
