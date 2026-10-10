import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/account_security/presentation/pages/confirm_recovery_phrase_page.dart';
import 'package:photo_manager_app/features/account_security/presentation/pages/recovery_phrase_page.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc authBloc;
  final user = User(id: '1', email: 'ana@example.com', name: 'Ana');
  // Spanish words with accents, as the official list has them
  final words = List.generate(24, (i) => i.isEven ? 'ábaco$i' : 'canción$i');

  setUpAll(() => registerFallbackValue(FakeAuthEvent()));

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(RecoveryPhraseRequired(user, words));
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Future<void> pumpPage(WidgetTester tester, {int seed = 1}) async {
    setUpCustomScreenSize(tester, 390, 844);
    await tester.pumpWidget(makeTestableWidgetWithBloc<AuthBloc>(
      bloc: authBloc,
      child: ConfirmRecoveryPhrasePage(
        args: RecoveryPhraseArgs(words: words, email: user.email, flow: RecoveryPhraseFlow.registration, user: user),
        random: Random(seed),
      ),
    ));
  }

  /// The positions asked by the page, read from the keys of its fields.
  List<int> askedPositions(WidgetTester tester) => find
      .byWidgetPredicate((widget) => widget.key is ValueKey<String> &&
          (widget.key as ValueKey<String>).value.startsWith('confirm-word-'))
      .evaluate()
      .map((element) => int.parse((element.widget.key as ValueKey<String>).value.split('-').last))
      .toList();

  Future<void> check(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('confirm-phrase-check')));
    await tester.pump();
  }

  group('ConfirmRecoveryPhrasePage', () {
    testWidgets('should ask for 3 different words in order', (tester) async {
      for (final seed in [1, 2, 3]) {
        await pumpPage(tester, seed: seed);

        final positions = askedPositions(tester);
        expect(positions, hasLength(3));
        expect(positions.toSet(), hasLength(3));
        expect(positions, orderedEquals([...positions]..sort()));
        expect(find.text('Word number ${positions.first + 1}'), findsOneWidget);
      }
    });

    testWidgets('should start the session when the words match, ignoring case and accents', (tester) async {
      // Arrange
      await pumpPage(tester);
      for (final position in askedPositions(tester)) {
        final typed = words[position].replaceAll('á', 'a').replaceAll('ó', 'o').toUpperCase();
        await tester.enterText(find.byKey(ValueKey('confirm-word-$position')), ' $typed ');
      }

      // Act
      await check(tester);

      // Assert
      final event = verify(() => authBloc.add(captureAny())).captured.single;
      expect(event, isA<RecoveryPhraseConfirmed>().having((e) => e.user, 'user', user));
    });

    testWidgets('should tell that a word does not match and not start the session', (tester) async {
      // Arrange
      await pumpPage(tester);
      final positions = askedPositions(tester);
      for (final position in positions) {
        await tester.enterText(find.byKey(ValueKey('confirm-word-$position')), words[position]);
      }
      await tester.enterText(find.byKey(ValueKey('confirm-word-${positions.last}')), 'wrong');

      // Act
      await check(tester);

      // Assert
      expect(find.text('A word does not match. Check your copy.'), findsOneWidget);
      verifyNever(() => authBloc.add(any()));
    });

    testWidgets('should hide the error when the user types again', (tester) async {
      await pumpPage(tester);
      await check(tester);
      expect(find.text('A word does not match. Check your copy.'), findsOneWidget);

      await tester.enterText(find.byKey(ValueKey('confirm-word-${askedPositions(tester).first}')), 'a');
      await tester.pump();

      expect(find.text('A word does not match. Check your copy.'), findsNothing);
    });
  });
}
