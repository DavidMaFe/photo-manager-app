import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';

import '../../helpers/widget_test_helper.dart';

void main() {
  Future<void> open(WidgetTester tester,
      {required double width, required String primary, String secondary = 'Cancelar', double textScale = 1}) async {
    setUpCustomScreenSize(tester, width, 800);
    await tester.pumpWidget(makeTestableWidget(MediaQuery(
      data: MediaQueryData(size: Size(width, 800), textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => AppDialog.show(
              context: context,
              title: 'Salir',
              message: '¿Seguro que quieres cerrar sesión?',
              primaryLabel: primary,
              secondaryLabel: secondary,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Offset buttonOf(WidgetTester tester, String label) =>
      tester.getTopLeft(find.descendant(of: find.byType(Dialog), matching: find.text(label)));

  group('AppDialog', () {
    group('buttons', () {
      testWidgets('should put the buttons one above the other when a label does not fit in half the width',
          (tester) async {
        // A phone of 360 dp, the width of the S23
        await open(tester, width: 360, primary: 'Desvincular y cerrar sesión');

        expect(buttonOf(tester, 'Desvincular y cerrar sesión').dy, lessThan(buttonOf(tester, 'Cancelar').dy));
      });

      testWidgets('should put «Cerrar sesión» above when the system font is big', (tester) async {
        await open(tester, width: 360, primary: 'Cerrar sesión', textScale: 1.3);

        expect(buttonOf(tester, 'Cerrar sesión').dy, lessThan(buttonOf(tester, 'Cancelar').dy));
      });

      testWidgets('should keep the buttons side by side when both labels fit', (tester) async {
        // The fonts of the tests draw every letter as wide as it is tall: short labels
        await open(tester, width: 360, primary: 'Sí', secondary: 'No');

        expect(buttonOf(tester, 'Sí').dy, buttonOf(tester, 'No').dy);
        expect(buttonOf(tester, 'No').dx, lessThan(buttonOf(tester, 'Sí').dx));
      });

      testWidgets('should never cut a label', (tester) async {
        await open(tester, width: 360, primary: 'Cerrar sesión');

        final text = tester.widget<Text>(find.descendant(of: find.byType(Dialog), matching: find.text('Cerrar sesión')).last);
        final painter = TextPainter(
          text: TextSpan(text: text.data, style: DefaultTextStyle.of(tester.element(find.byType(Dialog))).style
              .merge(text.style)),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        final shown = tester.getSize(find.descendant(of: find.byType(Dialog), matching: find.text('Cerrar sesión')).last);
        expect(painter.width, lessThanOrEqualTo(shown.width + 0.5));
      });
    });
  });
}
