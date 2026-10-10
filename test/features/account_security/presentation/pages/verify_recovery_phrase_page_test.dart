import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/features/account_security/presentation/bloc/verify_recovery_phrase_bloc.dart';
import 'package:photo_manager_app/features/account_security/presentation/pages/verify_recovery_phrase_page.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockVerifyRecoveryPhraseBloc extends MockBloc<VerifyRecoveryPhraseEvent, VerifyRecoveryPhraseState>
    implements VerifyRecoveryPhraseBloc {}

class FakeVerifyRecoveryPhraseEvent extends Fake implements VerifyRecoveryPhraseEvent {}

void main() {
  late MockVerifyRecoveryPhraseBloc bloc;
  final words = List.generate(24, (i) => 'word$i');

  setUpAll(() => registerFallbackValue(FakeVerifyRecoveryPhraseEvent()));

  setUp(() => bloc = MockVerifyRecoveryPhraseBloc());

  Future<void> pumpPage(WidgetTester tester, VerifyRecoveryPhraseState state,
      {Stream<VerifyRecoveryPhraseState>? states, Locale locale = const Locale('en')}) async {
    setUpCustomScreenSize(tester, 390, 844);
    whenListen(bloc, states ?? const Stream<VerifyRecoveryPhraseState>.empty(), initialState: state);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('profile'))),
      GoRoute(
        path: '/verify',
        builder: (_, __) =>
            BlocProvider<VerifyRecoveryPhraseBloc>.value(value: bloc, child: const VerifyRecoveryPhrasePage()),
      ),
    ]);
    await tester.pumpWidget(makeTestableRouter(router: router, locale: locale));
    router.push('/verify');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const ValueKey('verify-submit')));
    await tester.tap(find.byKey(const ValueKey('verify-submit')));
    await tester.pump();
  }

  group('VerifyRecoveryPhrasePage', () {
    testWidgets('should ask for the words at the given positions and send them', (tester) async {
      // Arrange
      await pumpPage(tester, VerifyAskWords(const [1, 8, 20]), locale: const Locale('es'));
      expect(find.text('Palabra número 2'), findsOneWidget);

      // Act
      for (final position in [1, 8, 20]) {
        await tester.enterText(find.byKey(ValueKey('verify-word-$position')), words[position]);
      }
      await tapSubmit(tester);

      // Assert
      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(event, isA<VerifyWordsSubmitted>()
          .having((e) => e.typedByPosition, 'words', {1: 'word1', 8: 'word8', 20: 'word20'})
          .having((e) => e.language, 'language', RecoveryPhraseLanguage.spanish));
    });

    testWidgets('should tell that a word does not match', (tester) async {
      await pumpPage(tester, VerifyAskWords(const [1, 8, 20], wrong: true));

      expect(find.text('A word does not match. Check your copy.'), findsOneWidget);
    });

    testWidgets('should ask for the full phrase without a copy on this device', (tester) async {
      await pumpPage(tester, VerifyAskFullPhrase());
      expect(find.textContaining('a copy will be kept on this device'), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('recovery-words-input')), words.join('\n'));
      await tapSubmit(tester);

      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(event, isA<VerifyFullPhraseSubmitted>().having((e) => e.words, 'words', words));
    });

    testWidgets('should show why the full phrase was rejected', (tester) async {
      await pumpPage(tester, VerifyAskFullPhrase(failure: const RecoveryPhraseMismatchFailure()));

      expect(find.text('These 24 words do not match any key of your account.'), findsOneWidget);
      expect(find.byKey(const ValueKey('recovery-words-input')), findsOneWidget);
    });

    testWidgets('should go back with a message when the words are right', (tester) async {
      await pumpPage(tester, VerifyAskWords(const [1, 8, 20]), states: Stream.value(VerifyRecoveryPhraseSuccess()));
      await tester.pumpAndSettle();

      expect(find.text('Your words are right'), findsOneWidget);
      expect(find.text('profile'), findsOneWidget);
    });

    testWidgets('should show a spinner while starting', (tester) async {
      setUpCustomScreenSize(tester, 390, 844);
      whenListen(bloc, const Stream<VerifyRecoveryPhraseState>.empty(), initialState: VerifyRecoveryPhraseLoading());
      await tester.pumpWidget(makeTestableWidgetWithBloc<VerifyRecoveryPhraseBloc>(
          bloc: bloc, child: const VerifyRecoveryPhrasePage()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
