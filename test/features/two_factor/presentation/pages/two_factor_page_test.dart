import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/secure_screen_guard.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/otp_field.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/totp_set_up.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/two_factor_status.dart';
import 'package:photo_manager_app/features/two_factor/domain/services/two_factor_exporter.dart';
import 'package:photo_manager_app/features/two_factor/presentation/bloc/two_factor_cubit.dart';
import 'package:photo_manager_app/features/two_factor/presentation/pages/two_factor_page.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockTwoFactorCubit extends MockCubit<TwoFactorState> implements TwoFactorCubit {}

class MockTwoFactorExporter extends Mock implements TwoFactorExporter {}

void main() {
  late MockTwoFactorCubit cubit;
  late MockTwoFactorExporter exporter;
  final clipboard = <String>[];

  const off = TwoFactorStatus(totpEnabled: false, backupCodesLeft: 0);
  const on = TwoFactorStatus(totpEnabled: true, backupCodesLeft: 7);
  const totpSetUp = TotpSetUp(secret: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ', otpauthUri: 'otpauth://totp/x');
  final codes = List.generate(10, (i) => 'abcd$i-efgh$i');

  setUp(() {
    cubit = MockTwoFactorCubit();
    exporter = MockTwoFactorExporter();
    clipboard.clear();
    when(() => cubit.startSetUp()).thenAnswer((_) async {});
    when(() => cubit.enable(any())).thenAnswer((_) async {});
    when(() => cubit.disable(password: any(named: 'password'), code: any(named: 'code'))).thenAnswer((_) async {});
    when(() => cubit.regenerate(password: any(named: 'password'), code: any(named: 'code')))
        .thenAnswer((_) async {});
    when(() => cubit.backupCodesSaved()).thenAnswer((_) async {});
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => exporter.shareBackupCodes(any())).thenAnswer((_) async {});
  });

  Future<void> pumpPage(WidgetTester tester, TwoFactorState state, {Stream<TwoFactorState>? states}) async {
    setUpCustomScreenSize(tester, 390, 844);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard.add((call.arguments as Map)['text'] as String);
      }
      return null;
    });
    whenListen(cubit, states ?? const Stream<TwoFactorState>.empty(), initialState: state);
    await tester.pumpWidget(makeTestableWidgetWithBlocs(
      providers: [BlocProvider<TwoFactorCubit>.value(value: cubit)],
      child: TwoFactorPage(exporter: exporter),
    ));
  }

  group('TwoFactorPage', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should explain the app and offer to turn it on when it is off', (tester) async {
      await pumpPage(tester, const TwoFactorState(view: TwoFactorView.status, status: off));

      expect(find.text('Off'), findsOneWidget);
      expect(find.textContaining('the code comes from the app instead'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('two-factor-enable')));
      await tester.pump();

      verify(() => cubit.startSetUp()).called(1);
      expect(find.byKey(const ValueKey('two-factor-disable')), findsNothing);
    });

    testWidgets('should say it is on with the backup codes left', (tester) async {
      await pumpPage(tester, const TwoFactorState(view: TwoFactorView.status, status: on));

      expect(find.text('On'), findsOneWidget);
      expect(find.text('7 unused backup codes'), findsOneWidget);
      expect(find.byKey(const ValueKey('two-factor-regenerate')), findsOneWidget);
      expect(find.byKey(const ValueKey('two-factor-disable')), findsOneWidget);
      expect(find.byKey(const ValueKey('two-factor-enable')), findsNothing);
      // Nothing secret on the status
      expect(find.byType(SecureScreenGuard), findsNothing);
    });

    testWidgets('should open the authenticator app with the secret, and copy the key', (tester) async {
      when(() => exporter.openInAuthenticator(any())).thenAnswer((_) async => true);
      await pumpPage(tester, const TwoFactorState(view: TwoFactorView.setUp, status: off, setUp: totpSetUp));

      expect(find.text('GEZD GNBV GY3T QOJQ GEZD GNBV GY3T QOJQ'), findsOneWidget);
      expect(find.byType(SecureScreenGuard), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('two-factor-open-app')));
      await tester.pump();
      verify(() => exporter.openInAuthenticator('otpauth://totp/x')).called(1);

      await tester.tap(find.byKey(const ValueKey('two-factor-copy-key')));
      await tester.pump();
      expect(clipboard, ['GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ']);
      expect(find.text('Key copied'), findsOneWidget);
    });

    testWidgets('should turn the app on once the 6 digits of its code are typed', (tester) async {
      await pumpPage(tester, const TwoFactorState(view: TwoFactorView.setUp, status: off, setUp: totpSetUp));

      await tester.enterText(find.byType(EditableText).last, '482913');
      await tester.pump();

      verify(() => cubit.enable('482913')).called(1);
    });

    testWidgets('should show the backup codes, copy and share them and confirm they are saved', (tester) async {
      await pumpPage(tester, TwoFactorState(view: TwoFactorView.backupCodes, status: off, backupCodes: codes));

      for (final code in codes) {
        expect(find.text(code), findsOneWidget);
      }
      expect(find.byType(SecureScreenGuard), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('two-factor-copy-codes')));
      await tester.pump();
      expect(clipboard.single, contains(codes.join('\n')));

      await tester.tap(find.byKey(const ValueKey('two-factor-share-codes')));
      await tester.pump();
      verify(() => exporter.shareBackupCodes(any(that: contains(codes.first)))).called(1);

      await tester.tap(find.byKey(const ValueKey('two-factor-codes-saved')));
      await tester.pump();
      verify(() => cubit.backupCodesSaved()).called(1);
    });

    testWidgets('should ask for the password and a code before turning the app off', (tester) async {
      await pumpPage(tester, const TwoFactorState(view: TwoFactorView.status, status: on));

      await tester.tap(find.byKey(const ValueKey('two-factor-disable')));
      await tester.pumpAndSettle();
      expect(find.text('Turn off the authenticator app'), findsOneWidget);
      await tester.enterText(find.descendant(of: find.byKey(const ValueKey('two-factor-password-field')),
          matching: find.byType(EditableText)), 'my password');
      await tester.enterText(find.descendant(of: find.byKey(const ValueKey('two-factor-code-field')),
          matching: find.byType(EditableText)), ' 123456 ');
      await tester.tap(find.widgetWithText(AppButton, 'Continue'));
      await tester.pumpAndSettle();

      verify(() => cubit.disable(password: 'my password', code: '123456')).called(1);
    });

    testWidgets('should not turn the app off when the dialog is cancelled', (tester) async {
      await pumpPage(tester, const TwoFactorState(view: TwoFactorView.status, status: on));

      await tester.tap(find.byKey(const ValueKey('two-factor-regenerate')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => cubit.regenerate(password: any(named: 'password'), code: any(named: 'code')));
    });

    // ==================== BUSINESS LOGIC TESTS ====================

    testWidgets('should say when no authenticator app opens the link', (tester) async {
      when(() => exporter.openInAuthenticator(any())).thenAnswer((_) async => false);
      await pumpPage(tester, const TwoFactorState(view: TwoFactorView.setUp, status: off, setUp: totpSetUp));

      await tester.tap(find.byKey(const ValueKey('two-factor-open-app')));
      await tester.pump();

      expect(find.textContaining('No authenticator app on this phone'), findsOneWidget);
    });

    testWidgets('should cancel the set-up when going back', (tester) async {
      await pumpPage(tester, const TwoFactorState(view: TwoFactorView.setUp, status: off, setUp: totpSetUp));

      await tester.binding.handlePopRoute();
      await tester.pump();

      verify(() => cubit.cancelSetUp()).called(1);
    });

    testWidgets('should say the app was turned off', (tester) async {
      await pumpPage(tester, const TwoFactorState(view: TwoFactorView.status, status: on),
          states: Stream.value(
              const TwoFactorState(view: TwoFactorView.status, status: off, notice: TwoFactorNotice.disabled)));
      await tester.pump();

      expect(find.text('Authenticator app turned off'), findsOneWidget);
      verify(() => cubit.feedbackShown()).called(1);
    });

    // ==================== ERROR TESTS ====================

    testWidgets('should mark the code of the set-up as wrong', (tester) async {
      await pumpPage(tester, const TwoFactorState(view: TwoFactorView.setUp, status: off, setUp: totpSetUp),
          states: Stream.value(const TwoFactorState(
              view: TwoFactorView.setUp, status: off, setUp: totpSetUp, failure: ValidationFailure())));
      await tester.pump();

      expect(tester.widget<OtpField>(find.byType(OtpField)).hasError, isTrue);
    });

    testWidgets('should offer to retry when the status cannot be loaded', (tester) async {
      await pumpPage(tester, const TwoFactorState(view: TwoFactorView.error, failure: ValidationFailure()));

      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pump(const Duration(seconds: 1));

      verify(() => cubit.load()).called(1);
    });

    // ==================== LOADING STATE TESTS ====================

    testWidgets('should wait while the status loads', (tester) async {
      await pumpPage(tester, const TwoFactorState());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
