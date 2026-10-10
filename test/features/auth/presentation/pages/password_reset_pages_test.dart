import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/otp_field.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/auth/presentation/pages/request_password_reset_page.dart';
import 'package:photo_manager_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:photo_manager_app/features/auth/presentation/pages/validate_reset_code_page.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/step_indicator.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;
  const email = 'ana@example.com';

  setUpAll(() => registerFallbackValue(FakeAuthEvent()));

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(NotAuthenticated());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.close()).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester, Widget page, {AuthState? state}) async {
    setUpCustomScreenSize(tester, 390, 844);
    if (state != null) when(() => mockAuthBloc.state).thenReturn(state);
    await tester.pumpWidget(makeTestableWidgetWithBloc<AuthBloc>(bloc: mockAuthBloc, child: page));
  }

  AppButton primaryButton(WidgetTester tester) => tester.widget<AppButton>(find.byType(AppButton));

  group('RequestPasswordResetPage', () {
    testWidgets('should show step 1 of 3 with its headline', (tester) async {
      // Arrange
      await pump(tester, const RequestPasswordResetPage());

      // Assert
      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('Forgot your password?'), findsOneWidget);
      expect(tester.widget<StepIndicator>(find.byType(StepIndicator)).current, 1);
    });

    testWidgets('should validate the email before sending', (tester) async {
      // Arrange
      await pump(tester, const RequestPasswordResetPage());

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter an email address'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('should dispatch PasswordResetRequested with the trimmed email', (tester) async {
      // Arrange
      await pump(tester, const RequestPasswordResetPage());
      await tester.enterText(find.byType(TextFormField), ' $email ');

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      final event = verify(() => mockAuthBloc.add(captureAny())).captured.single;
      expect(event, isA<PasswordResetRequested>().having((e) => e.email, 'email', email));
    });

    testWidgets('should anchor the primary button at the bottom', (tester) async {
      // Arrange
      await pump(tester, const RequestPasswordResetPage());

      // Act
      final button = tester.getRect(find.byType(AppButton));

      // Assert
      expect(button.bottom, closeTo(844 - 32, 0.5));
    });
  });

  group('ValidateResetCodePage', () {
    testWidgets('should show step 2 with the email in the description', (tester) async {
      // Arrange
      await pump(tester, const ValidateResetCodePage(email: email));

      // Assert
      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.text('Check your email'), findsOneWidget);
      expect(find.textContaining(email, findRichText: true), findsOneWidget);
      expect(find.byType(OtpField), findsOneWidget);
    });

    testWidgets('should disable verify until the 6 digits are entered', (tester) async {
      // Arrange
      await pump(tester, const ValidateResetCodePage(email: email));
      expect(primaryButton(tester).onPressed, isNull);

      // Act
      await tester.enterText(find.byType(TextField), '12345');
      await tester.pump();
      final withFive = primaryButton(tester).onPressed;
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();

      // Assert
      expect(withFive, isNull);
      expect(primaryButton(tester).onPressed, isNotNull);
    });

    testWidgets('should dispatch the validation when the code is complete', (tester) async {
      // Arrange
      await pump(tester, const ValidateResetCodePage(email: email));

      // Act
      await tester.enterText(find.byType(TextField), '654321');
      await tester.pump();

      // Assert
      final event = verify(() => mockAuthBloc.add(captureAny())).captured.single;
      expect(
        event,
        isA<ResetCodeValidationRequested>()
            .having((e) => e.code, 'code', '654321')
            .having((e) => e.email, 'email', email),
      );
    });

    testWidgets('should count down 60 seconds before enabling resend', (tester) async {
      // Arrange
      await pump(tester, const ValidateResetCodePage(email: email));
      expect(find.text('Resend in 1:00'), findsOneWidget);

      // Act
      await tester.pump(const Duration(seconds: 18));
      final midway = find.text('Resend in 0:42');
      final midwayFound = midway.evaluate().length;
      await tester.pump(const Duration(seconds: 42));

      // Assert
      expect(midwayFound, 1);
      expect(find.text('Resend code'), findsOneWidget);
      final resend = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Resend code'));
      expect(resend.onPressed, isNotNull);
    });

    testWidgets('should resend the code and restart the countdown', (tester) async {
      // Arrange
      await pump(tester, const ValidateResetCodePage(email: email));
      await tester.pump(const Duration(seconds: 60));

      // Act
      await tester.tap(find.text('Resend code'));
      await tester.pump();

      // Assert
      final event = verify(() => mockAuthBloc.add(captureAny())).captured.single;
      expect(event, isA<PasswordResetCodeResendRequested>().having((e) => e.email, 'email', email));
      expect(find.text('Resend in 1:00'), findsOneWidget);
    });
  });

  group('ResetPasswordPage', () {
    const page = ResetPasswordPage(email: email, code: '123456');
    const newPassword = 'new password 1';
    final words = List.generate(24, (i) => 'word$i');

    Finder saveButton() => find.widgetWithText(AppButton, 'Save password');
    Finder passwordField(int index) => find.byType(TextFormField).at(index);

    Future<void> answer(WidgetTester tester, {required bool hasWords}) async {
      await tester.tap(find.byKey(ValueKey(hasWords ? 'reset-has-words-yes' : 'reset-has-words-no')));
      await tester.pump();
    }

    /// The two password fields are the last ones: the words field goes before them.
    Future<void> enterPasswords(WidgetTester tester, String password, [String? confirmation]) async {
      final fields = find.byType(TextFormField).evaluate().length;
      await tester.enterText(passwordField(fields - 2), password);
      await tester.enterText(passwordField(fields - 1), confirmation ?? password);
    }

    Future<void> save(WidgetTester tester) async {
      await tester.ensureVisible(saveButton());
      await tester.tap(saveButton());
      await tester.pumpAndSettle();
    }

    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should show step 3 with the words question and both password fields', (tester) async {
      // Arrange
      await pump(tester, page);

      // Assert
      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('Create a new password'), findsOneWidget);
      expect(find.text('Do you have your 24 recovery words?'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(saveButton(), findsOneWidget);
    });

    testWidgets('should submit the 24 words with the new password', (tester) async {
      // Arrange
      await pump(tester, page);
      await answer(tester, hasWords: true);
      await tester.enterText(passwordField(0), words.indexed.map((e) => '${e.$1 + 1}. ${e.$2}').join('\n'));
      await enterPasswords(tester, newPassword);

      // Act
      await save(tester);

      // Assert: the numbers of a pasted list are ignored
      final event = verify(() => mockAuthBloc.add(captureAny())).captured.single;
      expect(
        event,
        isA<NewPasswordSubmitted>()
            .having((e) => e.email, 'email', email)
            .having((e) => e.code, 'code', '123456')
            .having((e) => e.newPassword, 'password', newPassword)
            .having((e) => e.recoveryWords, 'words', words),
      );
    });

    testWidgets('should warn that the photos get locked and submit without words once accepted', (tester) async {
      // Arrange
      await pump(tester, page);
      await answer(tester, hasWords: false);
      await enterPasswords(tester, newPassword);

      // Act
      await save(tester);

      // Assert: the warning is shown on the page and in the dialog
      expect(find.text('Your photos will be locked'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));

      await tester.tap(find.text('Understood, continue'));
      await tester.pumpAndSettle();

      final event = verify(() => mockAuthBloc.add(captureAny())).captured.single;
      expect(event, isA<NewPasswordSubmitted>().having((e) => e.recoveryWords, 'words', isNull));
    });

    // ==================== BUSINESS LOGIC TESTS ====================

    testWidgets('should not submit without words when the warning is cancelled', (tester) async {
      await pump(tester, page);
      await answer(tester, hasWords: false);
      await enterPasswords(tester, newPassword);

      await save(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('should ask the words question before submitting', (tester) async {
      await pump(tester, page);
      await enterPasswords(tester, newPassword);

      await save(tester);

      // On the page and in the snackbar
      expect(find.text('Do you have your 24 recovery words?'), findsNWidgets(2));
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('should tell how to recover the photos when the account ends up locked', (tester) async {
      // Arrange: a router, because the page goes back to the login after the reset
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(PasswordResetSuccessful(accountLocked: true)));
      setUpCustomScreenSize(tester, 390, 844);
      final router = GoRouter(routes: [
        GoRoute(path: '/', builder: (_, __) => BlocProvider<AuthBloc>.value(value: mockAuthBloc, child: page)),
        GoRoute(path: RoutePaths.login, builder: (_, __) => const Text('login page')),
      ]);
      await tester.pumpWidget(makeTestableRouter(router: router));

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Password changed. When you log in you will see how to recover your locked photos.'),
          findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('login page'), findsOneWidget);
    });

    // ==================== VALIDATION ERROR TESTS ====================

    testWidgets('should reject mismatching passwords', (tester) async {
      await pump(tester, page);
      await answer(tester, hasWords: true);
      await tester.enterText(passwordField(0), words.join(' '));
      await enterPasswords(tester, newPassword, 'new password 2');

      await save(tester);

      expect(find.text('Passwords do not match'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('should reject passwords shorter than 10 characters', (tester) async {
      await pump(tester, page);
      await answer(tester, hasWords: false);
      await enterPasswords(tester, 'short');

      await save(tester);

      expect(find.text('The password must have at least 10 characters.'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));
    });

    // ==================== LOADING STATE TESTS ====================

    testWidgets('should show loading on the primary button', (tester) async {
      // Arrange
      await pump(tester, page, state: AuthLoading());

      // Assert: the primary button of the layout goes after the answer buttons
      expect(tester.widget<AppButton>(find.byType(AppButton).last).loading, isTrue);
    });
  });
}
