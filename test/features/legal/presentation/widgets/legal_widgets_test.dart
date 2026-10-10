import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/legal/presentation/widgets/legal_acceptance_checkbox.dart';
import 'package:photo_manager_app/features/legal/presentation/widgets/legal_info_link.dart';

import '../../../../helpers/widget_test_helper.dart';

void main() {
  late GlobalKey<FormState> formKey;
  late List<bool> changes;

  setUp(() {
    formKey = GlobalKey<FormState>();
    changes = [];
  });

  /// [home] on a router with the legal routes, each showing its location.
  Future<GoRouter> pumpWith(WidgetTester tester, Widget home) async {
    setUpCustomScreenSize(tester, 390, 844);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => Scaffold(body: Form(key: formKey, child: home))),
      GoRoute(path: RoutePaths.legal, builder: (_, __) => const Scaffold(body: Text('legal index'))),
      GoRoute(
        path: RoutePaths.legalDocument,
        builder: (_, state) => Scaffold(body: Text('legal ${state.pathParameters['document']}')),
      ),
    ]);
    await tester.pumpWidget(makeTestableRouter(router: router));
    return router;
  }

  group('LegalAcceptanceCheckbox', () {
    testWidgets('should not validate until it is ticked', (tester) async {
      // Arrange
      await pumpWith(tester, LegalAcceptanceCheckbox(onChanged: changes.add));

      // Act / Assert: not ticked
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('You must accept the terms of use and the privacy policy'), findsOneWidget);

      // Act / Assert: ticked
      await tester.tap(find.byKey(const ValueKey('legal-accept-checkbox')));
      await tester.pump();
      expect(formKey.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.text('You must accept the terms of use and the privacy policy'), findsNothing);
      expect(changes, [true]);
    });

    testWidgets('should open the terms of use and the privacy policy', (tester) async {
      final router = await pumpWith(tester, const LegalAcceptanceCheckbox());

      await tester.tap(find.byKey(const ValueKey('legal-terms-link')));
      await tester.pumpAndSettle();
      expect(find.text('legal terms'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('legal-privacy-link')));
      await tester.pumpAndSettle();
      expect(find.text('legal privacy'), findsOneWidget);
    });

    testWidgets('should not change while disabled', (tester) async {
      await pumpWith(tester, LegalAcceptanceCheckbox(enabled: false, onChanged: changes.add));

      await tester.tap(find.byKey(const ValueKey('legal-accept-checkbox')));
      await tester.pump();

      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
      expect(changes, isEmpty);
    });
  });

  group('LegalInfoLink', () {
    testWidgets('should open the information and the legal texts', (tester) async {
      await pumpWith(tester, const LegalInfoLink());

      expect(find.text('How it works, terms and privacy'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('legal-info-link')));
      await tester.pumpAndSettle();

      expect(find.text('legal index'), findsOneWidget);
    });
  });
}
