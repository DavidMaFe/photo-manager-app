import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/legal/presentation/widgets/legal_info_link.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/auth/presentation/pages/login_page.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/otp_field.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/features/auth/domain/entities/second_factor_challenge.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/login/login_second_factor_step.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(NotAuthenticated());
    when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(NotAuthenticated()));
    when(() => mockAuthBloc.close()).thenAnswer((_) async => {});
  });

  Widget makeLoginPage() {
    return makeTestableWidgetWithBloc<AuthBloc>(bloc: mockAuthBloc, child: const LoginPage());
  }

  group('LoginPage', () {
    testWidgets('should link to the information and the legal texts without a session', (tester) async {
      setUpScreenSize(tester);

      await tester.pumpWidget(makeLoginPage());

      expect(find.byType(LegalInfoLink), findsOneWidget);
      expect(find.text('How it works, terms and privacy'), findsOneWidget);
    });

    testWidgets('should validate empty email', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeLoginPage());

      // Act
      final loginButton = find.byType(AppButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter an email address'), findsOneWidget);
    });

    testWidgets('should validate invalid email format', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeLoginPage());

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('The email format is invalid.'), findsOneWidget);
    });

    testWidgets('should validate empty password', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeLoginPage());

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('should dispatch LoginRequested event when form is valid', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeLoginPage());

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      verify(() => mockAuthBloc.add(any())).called(1);
    });

    testWidgets('should show loading indicator when AuthLoading state', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthLoading()));

      // Act
      await tester.pumpWidget(makeLoginPage());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should disable input fields when loading', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthLoading()));

      // Act
      await tester.pumpWidget(makeLoginPage());

      // Assert
      final emailField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      final passwordField = tester.widget<TextFormField>(find.byType(TextFormField).last);

      expect(emailField.enabled, false);
      expect(passwordField.enabled, false);
    });

    testWidgets('should disable login button when loading', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthLoading()));

      // Act
      await tester.pumpWidget(makeLoginPage());

      // Assert
      final loginButton = tester.widget<AppButton>(find.byType(AppButton));
      expect(loginButton.loading, isTrue);
    });

    testWidgets('should show error snackbar when AuthError state', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      const failure = NetworkFailure();
      when(() => mockAuthBloc.state).thenReturn(NotAuthenticated());
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthError(failure)),
      );

      // Act
      await tester.pumpWidget(makeLoginPage());
      await tester.pump(); // Trigger the stream
      await tester.pump(); // Build the snackbar

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeLoginPage());

      // Assert initial state - visibility_off icon should be visible
      expect(find.byIcon(Symbols.visibility_off_rounded), findsOneWidget);

      // Act - Tap the visibility toggle icon
      await tester.tap(find.byIcon(Symbols.visibility_off_rounded));
      await tester.pump();

      // Assert - visibility icon should now be visible
      expect(find.byIcon(Symbols.visibility_rounded), findsOneWidget);

      // Act - Tap again to hide
      await tester.tap(find.byIcon(Symbols.visibility_rounded));
      await tester.pump();

      // Assert - back to visibility_off icon
      expect(find.byIcon(Symbols.visibility_off_rounded), findsOneWidget);
    });

    testWidgets('should trim email before dispatching event', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeLoginPage());

      // Act
      await tester.enterText(find.byType(TextFormField).first, '  test@example.com  ');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockAuthBloc.add(any())).called(1);
    });

    group('second factor', () {
      const challenge = SecondFactorChallenge(
          challengeToken: 'challenge-token', method: 'EMAIL', emailHint: 't***@example.com');

      Future<void> pumpSecondFactor(WidgetTester tester, AuthSecondFactorRequired state,
          {Stream<AuthState>? states}) async {
        setUpCustomScreenSize(tester, 390, 844);
        when(() => mockAuthBloc.state).thenReturn(state);
        // The listener and the builder of the page both listen to the bloc
        final broadcast = (states ?? const Stream<AuthState>.empty()).asBroadcastStream();
        when(() => mockAuthBloc.stream).thenAnswer((_) => broadcast);
        await tester.pumpWidget(makeLoginPage());
      }

      // ==================== HAPPY PATH TESTS ====================

      testWidgets('should ask for the code emailed to the masked address instead of the form', (tester) async {
        await pumpSecondFactor(tester, AuthSecondFactorRequired(challenge));

        expect(find.byType(LoginSecondFactorStep), findsOneWidget);
        expect(find.text("Confirm it's you"), findsOneWidget);
        expect(find.textContaining('t***@example.com', findRichText: true), findsOneWidget);
        expect(find.byType(OtpField), findsOneWidget);
        expect(find.byType(TextFormField), findsNothing);
      });

      testWidgets('should send the code once its 6 digits are typed', (tester) async {
        await pumpSecondFactor(tester, AuthSecondFactorRequired(challenge));

        await tester.enterText(find.byType(EditableText), '482913');
        await tester.pump();

        final event = verify(() => mockAuthBloc.add(captureAny())).captured.single;
        expect(event, isA<LoginSecondFactorSubmitted>().having((e) => e.code, 'code', '482913'));
      });

      testWidgets('should go back to the form, cancelling the login', (tester) async {
        await pumpSecondFactor(tester, AuthSecondFactorRequired(challenge));

        await tester.tap(find.byKey(const ValueKey('login-second-factor-back')));
        await tester.pump();

        expect(verify(() => mockAuthBloc.add(captureAny())).captured.single, isA<LoginSecondFactorCancelled>());
      });

      testWidgets('should cancel the login with the system back', (tester) async {
        await pumpSecondFactor(tester, AuthSecondFactorRequired(challenge));

        await tester.binding.handlePopRoute();
        await tester.pump();

        expect(verify(() => mockAuthBloc.add(captureAny())).captured.single, isA<LoginSecondFactorCancelled>());
      });

      // ==================== BUSINESS LOGIC TESTS ====================

      testWidgets('should not send another code until a minute has passed', (tester) async {
        await pumpSecondFactor(tester, AuthSecondFactorRequired(challenge));

        final resend = find.byKey(const ValueKey('login-second-factor-resend'));
        expect(tester.widget<TextButton>(resend).onPressed, isNull);

        await tester.pump(const Duration(seconds: LoginSecondFactorStep.resendCooldownSeconds));
        await tester.tap(resend);
        await tester.pump();

        expect(verify(() => mockAuthBloc.add(captureAny())).captured.single,
            isA<LoginSecondFactorResendRequested>());
      });

      testWidgets('should say that a new code was sent', (tester) async {
        await pumpSecondFactor(tester, AuthSecondFactorRequired(challenge),
            states: Stream.value(AuthSecondFactorRequired(challenge, codeResent: true)));
        await tester.pump();

        expect(find.text('Code resent successfully'), findsOneWidget);
        expect(verify(() => mockAuthBloc.add(captureAny())).captured.single, isA<LoginSecondFactorResentShown>());
      });

      // ==================== ERROR TESTS ====================

      testWidgets('should show the error of a wrong code on the field', (tester) async {
        final failure = ValidationFailure(code: 'INVALID_SECOND_FACTOR_CODE', errorResponse: ErrorResponseModel(
            code: 'INVALID_SECOND_FACTOR_CODE', message: 'The code is not valid', timestamp: '2026-10-20T10:00:00'));
        await pumpSecondFactor(tester, AuthSecondFactorRequired(challenge),
            states: Stream.value(AuthSecondFactorRequired(challenge, failure: failure)));
        await tester.pump();

        expect(find.text('The code is not valid'), findsOneWidget);
        expect(tester.widget<OtpField>(find.byType(OtpField)).hasError, isTrue);
      });

      testWidgets('should show the form again with the error when the verification expired', (tester) async {
        await pumpSecondFactor(tester, AuthSecondFactorRequired(challenge),
            states: Stream.value(AuthError(const SecondFactorExpiredFailure())));
        await tester.pump();

        expect(find.byType(LoginSecondFactorStep), findsNothing);
        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.text('The verification expired. Sign in again.'), findsOneWidget);
      });

      // ==================== AUTHENTICATOR APP TESTS ====================

      const totpChallenge = SecondFactorChallenge(
          challengeToken: 'challenge-token', method: 'TOTP', emailHint: 't***@example.com');

      testWidgets('should ask for the code of the authenticator app, with nothing to resend', (tester) async {
        await pumpSecondFactor(tester, AuthSecondFactorRequired(totpChallenge));

        expect(find.text('Code of your authenticator app'), findsOneWidget);
        expect(find.textContaining('6-digit code of your authenticator app'), findsOneWidget);
        expect(find.byKey(const ValueKey('login-second-factor-resend')), findsNothing);
        expect(find.byType(OtpField), findsOneWidget);
      });

      testWidgets('should log in with a backup code instead', (tester) async {
        await pumpSecondFactor(tester, AuthSecondFactorRequired(totpChallenge));

        await tester.tap(find.byKey(const ValueKey('login-second-factor-backup-code')));
        await tester.pump();
        expect(find.byType(OtpField), findsNothing);
        expect(find.text('Use the code of the app'), findsOneWidget);

        await tester.enterText(find.descendant(of: find.byKey(const ValueKey('login-backup-code-field')),
            matching: find.byType(EditableText)), ' abcde-fghjk ');
        await tester.pump();
        await tester.tap(find.widgetWithText(AppButton, 'Verify code'));
        await tester.pump();

        final event = verify(() => mockAuthBloc.add(captureAny())).captured.single;
        expect(event, isA<LoginSecondFactorSubmitted>().having((e) => e.code, 'code', 'abcde-fghjk'));
      });

      testWidgets('should go back to the code of the app', (tester) async {
        await pumpSecondFactor(tester, AuthSecondFactorRequired(totpChallenge));

        await tester.tap(find.byKey(const ValueKey('login-second-factor-backup-code')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('login-second-factor-backup-code')));
        await tester.pump();

        expect(find.byType(OtpField), findsOneWidget);
      });

      // ==================== LOADING STATE TESTS ====================

      testWidgets('should wait while the code is checked', (tester) async {
        await pumpSecondFactor(tester, AuthSecondFactorRequired(challenge, working: true));

        expect(tester.widget<AppButton>(find.byType(AppButton)).loading, isTrue);
        expect(tester.widget<TextButton>(find.byKey(const ValueKey('login-second-factor-back'))).onPressed, isNull);
      });
    });
  });
}
