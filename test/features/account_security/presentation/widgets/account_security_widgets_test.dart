import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/recovery_phrase_use_cases.dart';
import 'package:photo_manager_app/features/account_security/presentation/pages/recovery_phrase_page.dart';
import 'package:photo_manager_app/features/account_security/presentation/widgets/recovery_reminder_listener.dart';
import 'package:photo_manager_app/features/account_security/presentation/widgets/recovery_words_input.dart';
import 'package:photo_manager_app/features/account_security/presentation/widgets/security_section.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockGetRecoveryWordsUseCase extends Mock implements GetRecoveryWordsUseCase {}

class MockRecoveryReminderUseCase extends Mock implements RecoveryReminderUseCase {}

void main() {
  setUpAll(() => registerFallbackValue(RecoveryPhraseLanguage.english));

  /// A router with the security routes by name; each shows its name.
  GoRouter routerWith(Widget home, {void Function(Object?)? onWordsExtra}) => GoRouter(routes: [
        GoRoute(path: '/', builder: (_, __) => Scaffold(body: home)),
        for (final name in [RouteNames.verifyRecoveryWords, RouteNames.forgotPassword, RouteNames.lockedPhotos])
          GoRoute(path: '/$name', name: name, builder: (_, __) => Scaffold(body: Text('page $name'))),
        GoRoute(
          path: '/${RouteNames.recoveryWords}',
          name: RouteNames.recoveryWords,
          builder: (_, state) {
            onWordsExtra?.call(state.extra);
            return const Scaffold(body: Text('page ${RouteNames.recoveryWords}'));
          },
        ),
      ]);

  group('RecoveryWordsInput.parse', () {
    test('should accept words separated by spaces, new lines or commas', () {
      expect(RecoveryWordsInput.parse(' abandon  ability,able\nabout '), ['abandon', 'ability', 'able', 'about']);
    });

    test('should drop the numbers of a pasted numbered list', () {
      expect(RecoveryWordsInput.parse('1. abandon\n2. ability\n10.able'), ['abandon', 'ability', 'able']);
    });

    test('should give no words for an empty text', () {
      expect(RecoveryWordsInput.parse('   \n '), isEmpty);
    });
  });

  group('SecuritySection', () {
    late MockGetRecoveryWordsUseCase getWords;
    final words = List.generate(24, (i) => 'word$i');

    setUp(() => getWords = MockGetRecoveryWordsUseCase());

    Future<void> pumpSection(WidgetTester tester, {void Function(Object?)? onWordsExtra}) async {
      setUpCustomScreenSize(tester, 390, 844);
      await tester.pumpWidget(makeTestableRouter(
        router: routerWith(
          SecuritySection(email: 'ana@example.com', getRecoveryWordsUseCase: getWords),
          onWordsExtra: onWordsExtra,
        ),
      ));
    }

    testWidgets('should show the four security options', (tester) async {
      await pumpSection(tester);

      expect(find.text('SECURITY'), findsOneWidget);
      expect(find.text('My 24 words'), findsOneWidget);
      expect(find.text('Verify my 24 words'), findsOneWidget);
      expect(find.text('I forgot my password'), findsOneWidget);
      expect(find.text('Recover locked photos'), findsOneWidget);
    });

    testWidgets('should open the words kept on this device only to view them', (tester) async {
      Object? extra;
      when(() => getWords(any())).thenAnswer((_) async => words);
      await pumpSection(tester, onWordsExtra: (value) => extra = value);

      await tester.tap(find.byKey(const ValueKey('security-recovery-words')));
      await tester.pumpAndSettle();

      expect(find.text('page ${RouteNames.recoveryWords}'), findsOneWidget);
      final args = extra as RecoveryPhraseArgs;
      expect(args.words, words);
      expect(args.flow, RecoveryPhraseFlow.view);
      expect(args.needsConfirmation, isFalse);
    });

    testWidgets('should send to the verification when this device has no copy of the words', (tester) async {
      when(() => getWords(any())).thenAnswer((_) async => null);
      await pumpSection(tester);

      await tester.tap(find.byKey(const ValueKey('security-recovery-words')));
      await tester.pumpAndSettle();

      expect(find.textContaining('This device has no copy of your 24 words'), findsOneWidget);
      expect(find.text('page ${RouteNames.verifyRecoveryWords}'), findsOneWidget);
    });

    for (final (key, route) in [
      ('security-verify-words', RouteNames.verifyRecoveryWords),
      ('security-forgot-password', RouteNames.forgotPassword),
      ('security-locked-photos', RouteNames.lockedPhotos),
    ]) {
      testWidgets('should open $route', (tester) async {
        await pumpSection(tester);

        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pumpAndSettle();

        expect(find.text('page $route'), findsOneWidget);
      });
    }
  });

  group('RecoveryReminderListener', () {
    late MockRecoveryReminderUseCase reminders;

    setUp(() {
      RecoveryReminderListener.checkedThisSession = false;
      reminders = MockRecoveryReminderUseCase();
      when(() => reminders.postpone()).thenAnswer((_) async {});
    });

    Future<void> pumpListener(WidgetTester tester) async {
      await tester.pumpWidget(makeTestableRouter(
        router: routerWith(RecoveryReminderListener(reminderUseCase: reminders, child: const Text('gallery'))),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('should ask whether the user still has the words when it is due', (tester) async {
      when(() => reminders.isDue()).thenAnswer((_) async => true);

      await pumpListener(tester);

      expect(find.text('Do you still have your 24 words?'), findsOneWidget);
    });

    testWidgets('should open the verification when the user checks now', (tester) async {
      when(() => reminders.isDue()).thenAnswer((_) async => true);
      await pumpListener(tester);

      await tester.tap(find.text('Check now'));
      await tester.pumpAndSettle();

      expect(find.text('page ${RouteNames.verifyRecoveryWords}'), findsOneWidget);
      verifyNever(() => reminders.postpone());
    });

    testWidgets('should postpone the reminder when the user answers later', (tester) async {
      when(() => reminders.isDue()).thenAnswer((_) async => true);
      await pumpListener(tester);

      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      verify(() => reminders.postpone()).called(1);
      expect(find.text('gallery'), findsOneWidget);
    });

    testWidgets('should not ask when the reminder is not due', (tester) async {
      when(() => reminders.isDue()).thenAnswer((_) async => false);

      await pumpListener(tester);

      expect(find.text('Do you still have your 24 words?'), findsNothing);
      expect(find.text('gallery'), findsOneWidget);
    });

    testWidgets('should check only once per app session', (tester) async {
      when(() => reminders.isDue()).thenAnswer((_) async => false);

      await pumpListener(tester);
      await tester.pumpWidget(const SizedBox());
      await pumpListener(tester);

      verify(() => reminders.isDue()).called(1);
    });
  });
}
