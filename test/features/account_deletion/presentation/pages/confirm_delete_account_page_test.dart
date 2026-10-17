import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failure_codes.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/account_deletion/presentation/bloc/delete_account_bloc.dart';
import 'package:photo_manager_app/features/account_deletion/presentation/pages/confirm_delete_account_page.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockDeleteAccountBloc extends MockBloc<DeleteAccountEvent, DeleteAccountState> implements DeleteAccountBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeDeleteAccountEvent extends Fake implements DeleteAccountEvent {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockDeleteAccountBloc bloc;
  late MockAuthBloc authBloc;
  late StreamController<DeleteAccountState> states;

  setUpAll(() {
    registerFallbackValue(FakeDeleteAccountEvent());
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() {
    bloc = MockDeleteAccountBloc();
    authBloc = MockAuthBloc();
    states = StreamController<DeleteAccountState>.broadcast();
    whenListen(authBloc, const Stream<AuthState>.empty(), initialState: NotAuthenticated());
  });

  tearDown(() => states.close());

  Future<void> pumpPage(WidgetTester tester, {DeleteAccountState? state, Locale locale = const Locale('en')}) async {
    setUpCustomScreenSize(tester, 390, 900);
    whenListen(bloc, states.stream, initialState: state ?? DeleteAccountInitial());
    final router = GoRouter(routes: [
      GoRoute(path: '/', name: RouteNames.profile, builder: (_, __) => const Scaffold(body: Text('profile'))),
      GoRoute(
        path: '/confirm',
        builder: (_, __) => MultiBlocProvider(
          providers: [
            BlocProvider<DeleteAccountBloc>.value(value: bloc),
            BlocProvider<AuthBloc>.value(value: authBloc),
          ],
          child: const ConfirmDeleteAccountPage(),
        ),
      ),
    ]);
    await tester.pumpWidget(makeTestableRouter(router: router, locale: locale));
    router.push('/confirm');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> fill(WidgetTester tester, {String password = 'the account password', String word = 'DELETE'}) async {
    await tester.enterText(find.byKey(const ValueKey('delete-account-password')), password);
    await tester.enterText(find.byKey(const ValueKey('delete-account-word')), word);
    await tester.pump();
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const ValueKey('delete-account-submit')));
    await tester.tap(find.byKey(const ValueKey('delete-account-submit')));
    await tester.pump();
  }

  group('ConfirmDeleteAccountPage', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should send the password once it is filled in and the word is typed', (tester) async {
      await pumpPage(tester);
      expect(find.text('Confirm it\'s you'), findsOneWidget);
      expect(find.text('Step 2 of 2'), findsOneWidget);

      await fill(tester);
      await tapSubmit(tester);

      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(event, isA<DeleteAccountSubmitted>().having((e) => e.password, 'password', 'the account password'));
    });

    testWidgets('should accept the word in lowercase and with spaces', (tester) async {
      await pumpPage(tester);

      await fill(tester, word: ' delete ');
      await tapSubmit(tester);

      verify(() => bloc.add(any(that: isA<DeleteAccountSubmitted>()))).called(1);
    });

    testWidgets('should ask for the Spanish word in Spanish', (tester) async {
      await pumpPage(tester, locale: const Locale('es'));
      expect(find.text('Escribe ELIMINAR'), findsOneWidget);

      await fill(tester, word: 'ELIMINAR');
      await tapSubmit(tester);

      verify(() => bloc.add(any(that: isA<DeleteAccountSubmitted>()))).called(1);
    });

    testWidgets('should say the account was deleted and go back to the login', (tester) async {
      await pumpPage(tester);

      states.add(DeleteAccountSuccess());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Your account has been deleted'), findsOneWidget);
      verify(() => authBloc.add(any(that: isA<AccountDeleted>()))).called(1);
    });

    // ==================== VALIDATION ERROR TESTS ====================

    testWidgets('should not send anything without the confirmation word', (tester) async {
      await pumpPage(tester);

      await fill(tester, word: 'DELET');
      await tapSubmit(tester);

      verifyNever(() => bloc.add(any()));
    });

    testWidgets('should not send anything without a password', (tester) async {
      await pumpPage(tester);

      await fill(tester, password: '');
      await tapSubmit(tester);

      verifyNever(() => bloc.add(any()));
    });

    testWidgets('should mark the password when the server rejects it, until it changes', (tester) async {
      await pumpPage(tester);
      await fill(tester);

      states.add(DeleteAccountError(const InvalidCredentialsFailure(code: FailureCodes.incorrectPassword)));
      await tester.pump();
      expect(find.text('The password is not correct'), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('delete-account-password')), 'another password');
      await tester.pump();
      expect(find.text('The password is not correct'), findsNothing);
      verifyNever(() => authBloc.add(any()));
    });

    testWidgets('should show other errors in a message', (tester) async {
      await pumpPage(tester);

      states.add(DeleteAccountError(const NetworkFailure()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('The password is not correct'), findsNothing);
    });

    // ==================== EDGE CASE TESTS ====================

    testWidgets('should not let anything be sent or changed while the account is deleted', (tester) async {
      await pumpPage(tester, state: DeleteAccountLoading());

      await tester.ensureVisible(find.byKey(const ValueKey('delete-account-submit')));
      await tester.tap(find.byKey(const ValueKey('delete-account-submit')));
      await tester.pump();

      verifyNever(() => bloc.add(any()));
    });

    testWidgets('should go back to the profile on Keep my account', (tester) async {
      await pumpPage(tester);

      await tester.ensureVisible(find.byKey(const ValueKey('delete-account-keep')));
      await tester.tap(find.byKey(const ValueKey('delete-account-keep')));
      await tester.pumpAndSettle();

      expect(find.text('profile'), findsOneWidget);
    });
  });
}
