import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/legal/data/repositories/bundled_legal_document_repository.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';
import 'package:photo_manager_app/features/legal/presentation/pages/legal_document_page.dart';
import 'package:photo_manager_app/features/legal/presentation/pages/legal_index_page.dart';

import '../../../../helpers/widget_test_helper.dart';

void main() {
  const repository = BundledLegalDocumentRepository();

  /// The legal routes as the app defines them, with a login page to go back to.
  Future<GoRouter> pumpRouter(WidgetTester tester, String location, {Locale locale = const Locale('en')}) async {
    setUpCustomScreenSize(tester, 390, 844);
    final router = GoRouter(initialLocation: location, routes: [
      GoRoute(path: RoutePaths.login, builder: (_, __) => const Scaffold(body: Text('login page'))),
      GoRoute(
        path: RoutePaths.legal,
        builder: (_, __) => const LegalIndexPage(repository: repository),
        routes: [
          GoRoute(
            path: ':document',
            builder: (_, state) => LegalDocumentPage(
              type: LegalDocumentType.fromSlug(state.pathParameters['document']) ?? LegalDocumentType.protection,
              repository: repository,
            ),
          ),
        ],
      ),
    ]);
    await tester.pumpWidget(makeTestableRouter(router: router, locale: locale));
    await tester.pumpAndSettle();
    return router;
  }

  group('LegalIndexPage', () {
    testWidgets('should list the information pages and the legal texts', (tester) async {
      await pumpRouter(tester, RoutePaths.legal);

      expect(find.text('Information and legal'), findsOneWidget);
      for (final title in ['How we protect your photos', 'If you forget your password', 'The 24 words',
          'Terms of use', 'Privacy policy']) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
    });

    testWidgets('should show the titles in Spanish when the app is in Spanish', (tester) async {
      await pumpRouter(tester, RoutePaths.legal, locale: const Locale('es'));

      expect(find.text('Información y legal'), findsOneWidget);
      expect(find.text('Política de privacidad'), findsOneWidget);
    });

    testWidgets('should open a document and come back', (tester) async {
      await pumpRouter(tester, RoutePaths.legal);

      await tester.tap(find.byKey(const ValueKey('legal-forgot-password')));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.byKey(const ValueKey('legal-document-title'))).data,
          'If you forget your password');

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Information and legal'), findsOneWidget);
    });

    testWidgets('should go to the login when opened directly without a page behind', (tester) async {
      await pumpRouter(tester, RoutePaths.legal);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('login page'), findsOneWidget);
    });
  });

  group('LegalDocumentPage', () {
    testWidgets('should show the terms with their version and date', (tester) async {
      await pumpRouter(tester, RoutePaths.legalDocumentOf('terms'));

      expect(tester.widget<Text>(find.byKey(const ValueKey('legal-document-title'))).data, 'Terms of use');
      expect(tester.widget<Text>(find.byKey(const ValueKey('legal-document-version'))).data,
          'Version 1.0 · in force since October 7, 2026');
      expect(find.text('5. Locked files and disclaimer'), findsOneWidget);
    });

    testWidgets('should show the date in Spanish', (tester) async {
      await pumpRouter(tester, RoutePaths.legalDocumentOf('privacy'), locale: const Locale('es'));

      expect(tester.widget<Text>(find.byKey(const ValueKey('legal-document-version'))).data,
          'Versión 1.0 · vigente desde el 7 de octubre de 2026');
    });

    testWidgets('should show the information pages without a version, with paragraphs and lists', (tester) async {
      await pumpRouter(tester, RoutePaths.legalDocumentOf('protection'));

      expect(find.byKey(const ValueKey('legal-document-version')), findsNothing);
      expect(find.text('What we cannot see'), findsOneWidget);
      expect(find.text('The original names of the files.'), findsOneWidget);
    });

    testWidgets('should fall back to the protection page for an unknown document', (tester) async {
      await pumpRouter(tester, RoutePaths.legalDocumentOf('cookies'));

      expect(tester.widget<Text>(find.byKey(const ValueKey('legal-document-title'))).data, 'How we protect your photos');
    });
  });
}
