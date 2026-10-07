import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/navigation/auth_notifier.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;
  late StreamController<AuthState> states;
  late AuthNotifier notifier;
  final user = User(id: '1', email: 'ana@example.com', name: 'Ana');

  setUp(() {
    authBloc = MockAuthBloc();
    states = StreamController<AuthState>.broadcast();
    when(() => authBloc.stream).thenAnswer((_) => states.stream);
    notifier = AuthNotifier(authBloc);
  });

  tearDown(() => states.close());

  group('AuthNotifier', () {
    test('should keep the user out of the gallery until the 24 words are confirmed', () {
      when(() => authBloc.state).thenReturn(RecoveryPhraseRequired(user, const []));

      expect(notifier.isRecoveryPhrasePending, isTrue);
      expect(notifier.isAuthenticated, isFalse);
      expect(notifier.isAccountLocked, isFalse);
    });

    test('should send a locked account to the locked account page before the gallery', () {
      when(() => authBloc.state).thenReturn(AuthAccountLocked(user));

      expect(notifier.isAccountLocked, isTrue);
      expect(notifier.isAuthenticated, isFalse);
      expect(notifier.isRecoveryPhrasePending, isFalse);
    });

    test('should ask for the terms in force before the session starts', () {
      when(() => authBloc.state).thenReturn(AuthLegalAcceptanceRequired(user, accountLocked: false));

      expect(notifier.isLegalAcceptancePending, isTrue);
      expect(notifier.isAuthenticated, isFalse);
      expect(notifier.isAccountLocked, isFalse);
    });

    test('should be authenticated only with a usable session', () {
      when(() => authBloc.state).thenReturn(AuthSuccessful(user));

      expect(notifier.isAuthenticated, isTrue);
      expect(notifier.isAccountLocked, isFalse);
      expect(notifier.isRecoveryPhrasePending, isFalse);
    });

    test('should notify the router on every state change', () async {
      var notifications = 0;
      notifier.addListener(() => notifications++);

      states
        ..add(RecoveryPhraseRequired(user, const []))
        ..add(AuthSuccessful(user));
      await Future<void>.delayed(Duration.zero);

      expect(notifications, 2);
    });
  });
}
