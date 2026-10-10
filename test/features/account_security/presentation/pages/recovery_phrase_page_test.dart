import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/account_security/domain/services/recovery_phrase_exporter.dart';
import 'package:photo_manager_app/features/account_security/presentation/pages/recovery_phrase_page.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockRecoveryPhraseExporter extends Mock implements RecoveryPhraseExporter {}

class FakeRecoveryPhrasePdfTexts extends Fake implements RecoveryPhrasePdfTexts {}

void main() {
  late MockRecoveryPhraseExporter exporter;
  late GoRouter router;
  RecoveryPhraseArgs? confirmArgs;

  const email = 'ana@example.com';
  final user = User(id: '1', email: email, name: 'Ana');
  final words = List.generate(24, (i) => 'word$i');

  setUpAll(() => registerFallbackValue(FakeRecoveryPhrasePdfTexts()));

  setUp(() {
    exporter = MockRecoveryPhraseExporter();
    confirmArgs = null;
  });

  /// The page on top of a home route, so "Done" has somewhere to go back to.
  Future<void> pumpPage(WidgetTester tester, RecoveryPhraseFlow flow) async {
    setUpCustomScreenSize(tester, 390, 844);
    final args = RecoveryPhraseArgs(words: words, email: email, flow: flow, user: user);
    router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const Text('home')),
      GoRoute(path: '/words', builder: (_, __) => RecoveryPhrasePage(args: args, exporter: exporter)),
      GoRoute(path: RoutePaths.legalDocument, builder: (_, state) => Text('legal ${state.pathParameters['document']}')),
      GoRoute(path: RoutePaths.confirmRecoveryPhrase, builder: (_, state) {
        confirmArgs = state.extra as RecoveryPhraseArgs;
        return const Text('confirm page');
      }),
    ]);
    await tester.pumpWidget(makeTestableRouter(router: router));
    router.push('/words');
    await tester.pumpAndSettle();
  }

  Future<void> tapButton(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(ValueKey(key)));
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pumpAndSettle();
  }

  group('RecoveryPhrasePage', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should show the 24 words numbered and in order', (tester) async {
      await pumpPage(tester, RecoveryPhraseFlow.registration);

      for (var i = 0; i < 24; i++) {
        expect(tester.widget<Text>(find.byKey(ValueKey('recovery-word-$i'))).data, 'word$i');
      }
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('24.'), findsOneWidget);
      expect(find.text('Your 24 recovery words'), findsOneWidget);
    });

    testWidgets('should go to the confirmation after registering, with the same words', (tester) async {
      await pumpPage(tester, RecoveryPhraseFlow.registration);
      await tester.pump(RecoveryPhrasePage.minimumReadingTime);

      await tapButton(tester, 'recovery-phrase-continue');

      expect(find.text('confirm page'), findsOneWidget);
      expect(confirmArgs!.words, words);
      expect(confirmArgs!.user, user);
    });

    testWidgets('should just go back from the profile, without confirming', (tester) async {
      await pumpPage(tester, RecoveryPhraseFlow.view);

      expect(find.text('My 24 words'), findsOneWidget);
      await tapButton(tester, 'recovery-phrase-continue');

      expect(find.text('home'), findsOneWidget);
      expect(confirmArgs, isNull);
    });

    // ==================== BUSINESS LOGIC TESTS ====================

    testWidgets('should not let the user continue for 10 seconds after registering', (tester) async {
      // Arrange
      await pumpPage(tester, RecoveryPhraseFlow.registration);
      AppButton continueButton() => tester.widget<AppButton>(find.byKey(const ValueKey('recovery-phrase-continue')));

      // Assert: disabled with a countdown
      expect(continueButton().onPressed, isNull);
      expect(find.text('Read carefully (10)'), findsOneWidget);

      await tester.pump(const Duration(seconds: 6));
      expect(continueButton().onPressed, isNull);
      expect(find.text('Read carefully (4)'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      expect(continueButton().onPressed, isNotNull);
      expect(find.text('I have saved them'), findsOneWidget);
    });

    testWidgets('should wait 10 seconds as well for the words of a new key', (tester) async {
      await pumpPage(tester, RecoveryPhraseFlow.newKey);

      expect(tester.widget<AppButton>(find.byKey(const ValueKey('recovery-phrase-continue'))).onPressed, isNull);
      expect(find.byKey(const ValueKey('recovery-phrase-importance')), findsOneWidget);
    });

    testWidgets('should explain why the words matter before showing them', (tester) async {
      await pumpPage(tester, RecoveryPhraseFlow.registration);

      final importance = tester.getRect(find.byKey(const ValueKey('recovery-phrase-importance')));
      final firstWord = tester.getRect(find.byKey(const ValueKey('recovery-word-0')));
      expect(find.text('Read this before you continue'), findsOneWidget);
      expect(find.text('If you forget your password, these 24 words are the only way to recover your photos.'),
          findsOneWidget);
      expect(importance.bottom, lessThan(firstWord.top));
    });

    testWidgets('should not make the user wait when only viewing the words', (tester) async {
      await pumpPage(tester, RecoveryPhraseFlow.view);

      expect(tester.widget<AppButton>(find.byKey(const ValueKey('recovery-phrase-continue'))).onPressed, isNotNull);
      expect(find.byKey(const ValueKey('recovery-phrase-importance')), findsNothing);
    });

    testWidgets('should open the information about the 24 words', (tester) async {
      await pumpPage(tester, RecoveryPhraseFlow.registration);

      await tapButton(tester, 'recovery-phrase-learn-more');

      expect(find.text('legal recovery-words'), findsOneWidget);
    });

    testWidgets('should not let the user leave before confirming the words of a new account', (tester) async {
      await pumpPage(tester, RecoveryPhraseFlow.registration);

      expect(find.byType(SecondaryTopBar), findsNothing);
      expect(tester.widget<PopScope>(find.byType(PopScope).last).canPop, isFalse);
    });

    testWidgets('should let the user go back when only viewing the words', (tester) async {
      await pumpPage(tester, RecoveryPhraseFlow.view);

      expect(find.byType(SecondaryTopBar), findsOneWidget);
      expect(tester.widget<PopScope>(find.byType(PopScope).last).canPop, isTrue);
    });

    testWidgets('should save the words to the password manager under the account', (tester) async {
      when(() => exporter.saveToPasswordManager(account: any(named: 'account'), words: any(named: 'words')))
          .thenAnswer((_) async => true);
      await pumpPage(tester, RecoveryPhraseFlow.registration);

      await tapButton(tester, 'save-password-manager');

      verify(() => exporter.saveToPasswordManager(account: 'Photo Manager recovery key ($email)', words: words))
          .called(1);
      // On the button and in the snackbar
      expect(find.text('Saved to the password manager'), findsNWidgets(2));
    });

    testWidgets('should suggest the PDF when the password manager is not available', (tester) async {
      when(() => exporter.saveToPasswordManager(account: any(named: 'account'), words: any(named: 'words')))
          .thenAnswer((_) async => false);
      await pumpPage(tester, RecoveryPhraseFlow.registration);

      await tapButton(tester, 'save-password-manager');

      expect(find.text('They could not be saved to the password manager. Download the PDF or write them down.'),
          findsOneWidget);
      expect(find.text('Save to the password manager'), findsOneWidget);
    });

    testWidgets('should share a PDF with the words and the translated texts', (tester) async {
      when(() => exporter.sharePdf(email: any(named: 'email'), words: any(named: 'words'), texts: any(named: 'texts')))
          .thenAnswer((_) async {});
      await pumpPage(tester, RecoveryPhraseFlow.registration);

      await tapButton(tester, 'download-pdf');

      final texts = verify(() => exporter.sharePdf(email: email, words: words, texts: captureAny(named: 'texts')))
          .captured
          .single as RecoveryPhrasePdfTexts;
      expect(texts.title, 'Photo Manager recovery key');
      expect(texts.fileName, endsWith('.pdf'));
    });
  });
}
