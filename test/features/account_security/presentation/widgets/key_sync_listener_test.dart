import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/key_sync_use_cases.dart';
import 'package:photo_manager_app/features/account_security/presentation/widgets/key_sync_listener.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockCheckKeysUpToDateUseCase extends Mock implements CheckKeysUpToDateUseCase {}

class MockRefreshKeysWithPasswordUseCase extends Mock implements RefreshKeysWithPasswordUseCase {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockCheckKeysUpToDateUseCase checkKeys;
  late MockRefreshKeysWithPasswordUseCase refreshKeys;
  late MockAuthBloc authBloc;
  late AppEventBus eventBus;

  setUpAll(() => registerFallbackValue(FakeAuthEvent()));

  setUp(() {
    KeySyncListener.checkedThisSession = false;
    checkKeys = MockCheckKeysUpToDateUseCase();
    refreshKeys = MockRefreshKeysWithPasswordUseCase();
    authBloc = MockAuthBloc();
    eventBus = AppEventBus();
    whenListen(authBloc, const Stream<AuthState>.empty(),
        initialState: AuthSuccessful(User(id: '1', email: 'ana@example.com', name: 'Ana')));
  });

  Future<void> pumpListener(WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidgetWithBloc<AuthBloc>(
      bloc: authBloc,
      child: Scaffold(
        body: KeySyncListener(
          checkKeys: checkKeys,
          refreshKeys: refreshKeys,
          eventBus: eventBus,
          child: const Text('gallery'),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> typePassword(WidgetTester tester, String password) async {
    await tester.enterText(find.byKey(const ValueKey('password-prompt-field')), password);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  group('KeySyncListener', () {
    testWidgets('should do nothing when this device holds the current key', (tester) async {
      when(() => checkKeys()).thenAnswer((_) async => KeySyncStatus.upToDate);

      await pumpListener(tester);

      expect(find.text('Your keys changed on another device'), findsNothing);
      expect(find.text('gallery'), findsOneWidget);
      verify(() => checkKeys()).called(1);
    });

    testWidgets('should ask for the current password and refresh the keys', (tester) async {
      when(() => checkKeys()).thenAnswer((_) async => KeySyncStatus.passwordRequired);
      when(() => refreshKeys(password: any(named: 'password'))).thenAnswer((_) async {});

      await pumpListener(tester);
      expect(find.text('Your keys changed on another device'), findsOneWidget);

      await typePassword(tester, 'the new password');

      verify(() => refreshKeys(password: 'the new password')).called(1);
      expect(find.text('Keys updated'), findsOneWidget);
    });

    testWidgets('should tell when the password is not the current one', (tester) async {
      when(() => checkKeys()).thenAnswer((_) async => KeySyncStatus.passwordRequired);
      when(() => refreshKeys(password: any(named: 'password'))).thenThrow(const KeyUnlockFailure());

      await pumpListener(tester);
      await typePassword(tester, 'the old password');

      expect(find.text('Keys updated'), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should let the user leave it for later', (tester) async {
      when(() => checkKeys()).thenAnswer((_) async => KeySyncStatus.passwordRequired);

      await pumpListener(tester);
      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      verifyNever(() => refreshKeys(password: any(named: 'password')));
      expect(find.text('gallery'), findsOneWidget);
    });

    testWidgets('should start the locked account flow when the account is locked', (tester) async {
      when(() => checkKeys()).thenAnswer((_) async => KeySyncStatus.accountLocked);

      await pumpListener(tester);

      verify(() => authBloc.add(any(that: isA<AccountLockDetected>()))).called(1);
    });

    testWidgets('should check again when an upload is rejected for outdated keys', (tester) async {
      when(() => checkKeys()).thenAnswer((_) async => KeySyncStatus.upToDate);
      await pumpListener(tester);

      eventBus.fire(const KeysOutdatedEvent());
      await tester.pumpAndSettle();

      verify(() => checkKeys()).called(2);
    });

    testWidgets('should check only once per app session when it opens', (tester) async {
      when(() => checkKeys()).thenAnswer((_) async => KeySyncStatus.upToDate);

      await pumpListener(tester);
      await tester.pumpWidget(const SizedBox());
      await pumpListener(tester);

      verify(() => checkKeys()).called(1);
    });

    testWidgets('should stay quiet when the check fails (offline)', (tester) async {
      when(() => checkKeys()).thenThrow(Exception('offline'));

      await pumpListener(tester);

      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('gallery'), findsOneWidget);
    });
  });
}
