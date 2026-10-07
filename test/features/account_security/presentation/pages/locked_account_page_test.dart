import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/locked_account_use_cases.dart';
import 'package:photo_manager_app/features/account_security/presentation/bloc/locked_account_bloc.dart';
import 'package:photo_manager_app/features/account_security/presentation/pages/locked_account_page.dart';
import 'package:photo_manager_app/features/account_security/presentation/pages/recovery_phrase_page.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';

import '../../../../fixtures/e2ee_test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

class MockLockedAccountBloc extends MockBloc<LockedAccountEvent, LockedAccountState> implements LockedAccountBloc {}

class MockAuthBloc extends Mock implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

class FakeLockedAccountEvent extends Fake implements LockedAccountEvent {}

void main() {
  late MockLockedAccountBloc bloc;
  late MockAuthBloc authBloc;
  RecoveryPhraseArgs? phraseArgs;

  final user = User(id: '1', email: 'ana@example.com', name: 'Ana');
  final words = List.generate(24, (i) => 'word$i');

  LockedAccountStatus status({bool accountLocked = true, List<int> held = const [], bool anyLocked = true}) =>
      LockedAccountStatus(
        keys: AccountKeys(accountLocked: accountLocked, versions: [
          if (anyLocked) E2eeTestData.keyVersion(version: 1, state: KeyState.locked),
          if (!accountLocked) E2eeTestData.keyVersion(version: 2),
        ]),
        versionsHeldOnDevice: held,
      );

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeLockedAccountEvent());
  });

  setUp(() {
    bloc = MockLockedAccountBloc();
    authBloc = MockAuthBloc();
    phraseArgs = null;
    when(() => authBloc.state).thenReturn(AuthAccountLocked(user));
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Future<void> pumpPage(WidgetTester tester, LockedAccountState state,
      {bool afterLogin = true, Stream<LockedAccountState>? states}) async {
    setUpCustomScreenSize(tester, 390, 844);
    whenListen(bloc, states ?? const Stream<LockedAccountState>.empty(), initialState: state);
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider<LockedAccountBloc>.value(value: bloc),
            BlocProvider<AuthBloc>.value(value: authBloc),
          ],
          child: LockedAccountPage(user: user, afterLogin: afterLogin),
        ),
      ),
      GoRoute(path: RoutePaths.recoveryPhrase, builder: (_, state) {
        phraseArgs = state.extra as RecoveryPhraseArgs;
        return const Text('recovery phrase page');
      }),
    ]);
    await tester.pumpWidget(makeTestableRouter(router: router));
    await tester.pump();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(ValueKey(key)));
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pumpAndSettle();
  }

  Future<void> typePasswordAndContinue(WidgetTester tester) async {
    await tester.enterText(find.byKey(const ValueKey('password-prompt-field')), 'the password');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  group('LockedAccountPage', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should explain that the photos are kept and offer every way out', (tester) async {
      await pumpPage(tester, LockedAccountLoaded(status(held: [1])));

      expect(find.text('Your earlier photos are locked'), findsOneWidget);
      expect(find.textContaining('Your photos have not been deleted'), findsOneWidget);
      expect(find.byKey(const ValueKey('locked-use-words')), findsOneWidget);
      expect(find.byKey(const ValueKey('locked-use-device')), findsOneWidget);
      expect(find.byKey(const ValueKey('locked-new-key')), findsOneWidget);
      expect(find.byKey(const ValueKey('locked-logout')), findsOneWidget);
    });

    testWidgets('should show a spinner while loading', (tester) async {
      await pumpPage(tester, LockedAccountLoading());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should unlock with the 24 words and the current password', (tester) async {
      // Arrange
      await pumpPage(tester, LockedAccountLoaded(status()));
      await tapKey(tester, 'locked-use-words');

      // Act
      await tester.enterText(find.byKey(const ValueKey('recovery-words-input')), words.join(' '));
      await typePasswordAndContinue(tester);

      // Assert
      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(event, isA<UnlockWithWordsRequested>()
          .having((e) => e.password, 'password', 'the password')
          .having((e) => e.words, 'words', words));
    });

    testWidgets('should unlock with the keys of this device and the current password', (tester) async {
      await pumpPage(tester, LockedAccountLoaded(status(held: [1])));
      await tapKey(tester, 'locked-use-device');

      await typePasswordAndContinue(tester);

      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(event, isA<UnlockWithDeviceRequested>().having((e) => e.password, 'password', 'the password'));
    });

    testWidgets('should create a new key after warning that the old photos stay locked', (tester) async {
      // Arrange
      await pumpPage(tester, LockedAccountLoaded(status()));
      await tapKey(tester, 'locked-new-key');
      expect(find.text('Start with a new key?'), findsOneWidget);

      // Act
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await typePasswordAndContinue(tester);

      // Assert
      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(event, isA<NewKeyRequested>()
          .having((e) => e.password, 'password', 'the password')
          .having((e) => e.language, 'language', RecoveryPhraseLanguage.english));
    });

    // ==================== BUSINESS LOGIC TESTS ====================

    testWidgets('should not offer the device without locked keys on it', (tester) async {
      await pumpPage(tester, LockedAccountLoaded(status()));

      expect(find.byKey(const ValueKey('locked-use-device')), findsNothing);
    });

    testWidgets('should not offer a new key when the account is usable', (tester) async {
      await pumpPage(tester, LockedAccountLoaded(status(accountLocked: false)), afterLogin: false);

      expect(find.byKey(const ValueKey('locked-new-key')), findsNothing);
      expect(find.byKey(const ValueKey('locked-use-words')), findsOneWidget);
    });

    testWidgets('should tell from the profile that there is nothing locked', (tester) async {
      await pumpPage(tester, LockedAccountLoaded(status(accountLocked: false, anyLocked: false)), afterLogin: false);

      expect(find.byKey(const ValueKey('locked-none')), findsOneWidget);
      expect(find.byKey(const ValueKey('locked-use-words')), findsNothing);
      expect(find.byKey(const ValueKey('locked-logout')), findsNothing);
    });

    testWidgets('should do nothing when the password dialog is cancelled', (tester) async {
      await pumpPage(tester, LockedAccountLoaded(status(held: [1])));
      await tapKey(tester, 'locked-use-device');

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => bloc.add(any()));
    });

    testWidgets('should open the gallery when the account becomes usable after logging in', (tester) async {
      await pumpPage(tester, LockedAccountLoaded(status()),
          states: Stream.value(LockedAccountUnlocked(const [1], accountUsable: true)));

      expect(find.text('Photos recovered'), findsOneWidget);
      final event = verify(() => authBloc.add(captureAny())).captured.single;
      expect(event, isA<AccountUnlocked>().having((e) => e.user, 'user', user));
    });

    testWidgets('should reload the status when some photos are still locked', (tester) async {
      await pumpPage(tester, LockedAccountLoaded(status()), afterLogin: false,
          states: Stream.value(LockedAccountUnlocked(const [1], accountUsable: true)));

      verify(() => bloc.add(any(that: isA<LockedAccountStatusRequested>()))).called(1);
      verifyNever(() => authBloc.add(any()));
    });

    testWidgets('should show the 24 words of the new key, to be confirmed', (tester) async {
      await pumpPage(tester, LockedAccountLoaded(status()), states: Stream.value(LockedAccountNewKeyCreated(words)));
      await tester.pumpAndSettle();

      expect(find.text('recovery phrase page'), findsOneWidget);
      expect(phraseArgs!.words, words);
      expect(phraseArgs!.flow, RecoveryPhraseFlow.newKey);
      expect(phraseArgs!.user, user);
    });

    testWidgets('should log out from a locked account', (tester) async {
      await pumpPage(tester, LockedAccountLoaded(status()));

      await tapKey(tester, 'locked-logout');

      verify(() => authBloc.add(any(that: isA<LogoutRequested>()))).called(1);
    });
  });
}
