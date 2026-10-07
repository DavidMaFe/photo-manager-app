import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/legal/presentation/pages/legal_acceptance_page.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc authBloc;
  final user = User(id: '1', email: 'ana@example.com', name: 'Ana');

  setUpAll(() => registerFallbackValue(FakeAuthEvent()));

  setUp(() => authBloc = MockAuthBloc());

  Future<void> pumpPage(WidgetTester tester, AuthState state, {Stream<AuthState>? states}) async {
    setUpCustomScreenSize(tester, 390, 844);
    whenListen(authBloc, states ?? const Stream<AuthState>.empty(), initialState: state);
    await tester.pumpWidget(makeTestableWidgetWithBloc<AuthBloc>(bloc: authBloc, child: const LegalAcceptancePage()));
    await tester.pump();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pump();
  }

  group('LegalAcceptancePage', () {
    testWidgets('should explain why the terms must be accepted', (tester) async {
      await pumpPage(tester, AuthLegalAcceptanceRequired(user, accountLocked: false));

      expect(find.text('Terms of use and privacy'), findsOneWidget);
      expect(find.textContaining('read and accept the terms of use and the privacy policy'), findsOneWidget);
      expect(find.byKey(const ValueKey('legal-terms-link')), findsOneWidget);
      expect(find.byKey(const ValueKey('legal-privacy-link')), findsOneWidget);
    });

    testWidgets('should accept the terms once ticked', (tester) async {
      await pumpPage(tester, AuthLegalAcceptanceRequired(user, accountLocked: false));

      await tapKey(tester, 'legal-accept-checkbox');
      await tapKey(tester, 'legal-accept-button');

      verify(() => authBloc.add(any(that: isA<LegalTermsAccepted>()))).called(1);
    });

    testWidgets('should not accept without ticking', (tester) async {
      await pumpPage(tester, AuthLegalAcceptanceRequired(user, accountLocked: false));

      await tapKey(tester, 'legal-accept-button');

      expect(find.text('You must accept the terms of use and the privacy policy'), findsOneWidget);
      verifyNever(() => authBloc.add(any()));
    });

    testWidgets('should not let the user go back without accepting', (tester) async {
      await pumpPage(tester, AuthLegalAcceptanceRequired(user, accountLocked: false));

      expect(tester.widget<PopScope>(find.byType(PopScope).last).canPop, isFalse);
    });

    testWidgets('should let the user log out instead', (tester) async {
      await pumpPage(tester, AuthLegalAcceptanceRequired(user, accountLocked: false));

      await tapKey(tester, 'legal-logout');

      verify(() => authBloc.add(any(that: isA<LogoutRequested>()))).called(1);
    });

    testWidgets('should show loading while the acceptance is saved', (tester) async {
      await pumpPage(tester, AuthLegalAcceptanceRequired(user, accountLocked: false, working: true));

      expect(tester.widget<AppButton>(find.byKey(const ValueKey('legal-accept-button'))).loading, isTrue);
    });

    testWidgets('should show the error when the acceptance cannot be saved', (tester) async {
      await pumpPage(tester, AuthLegalAcceptanceRequired(user, accountLocked: false),
          states: Stream.value(AuthLegalAcceptanceRequired(user, accountLocked: false,
              failure: const NetworkFailure())));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
