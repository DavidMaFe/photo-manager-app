import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
    testWidgets('should show step 3 with both password fields', (tester) async {
      // Arrange
      await pump(tester, const ResetPasswordPage(email: email, code: '123456'));

      // Assert
      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('Create a new password'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Save password'), findsOneWidget);
    });

    testWidgets('should reject mismatching passwords', (tester) async {
      // Arrange
      await pump(tester, const ResetPasswordPage(email: email, code: '123456'));
      await tester.enterText(find.byType(TextFormField).first, 'newpass1');
      await tester.enterText(find.byType(TextFormField).last, 'newpass2');

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      expect(find.text('Passwords do not match'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('should submit the new password with email and code', (tester) async {
      // Arrange
      await pump(tester, const ResetPasswordPage(email: email, code: '123456'));
      await tester.enterText(find.byType(TextFormField).first, 'newpass1');
      await tester.enterText(find.byType(TextFormField).last, 'newpass1');

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      final event = verify(() => mockAuthBloc.add(captureAny())).captured.single;
      expect(
        event,
        isA<NewPasswordSubmitted>()
            .having((e) => e.newPassword, 'password', 'newpass1')
            .having((e) => e.code, 'code', '123456'),
      );
    });

    testWidgets('should show loading on the primary button', (tester) async {
      // Arrange
      await pump(tester, const ResetPasswordPage(email: email, code: '123456'), state: AuthLoading());

      // Assert
      expect(primaryButton(tester).loading, isTrue);
    });
  });
}
