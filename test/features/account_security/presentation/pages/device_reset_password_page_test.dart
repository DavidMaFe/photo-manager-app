import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/account_security/presentation/bloc/device_reset_password_bloc.dart';
import 'package:photo_manager_app/features/account_security/presentation/pages/device_reset_password_page.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockDeviceResetPasswordBloc extends MockBloc<DeviceResetPasswordEvent, DeviceResetPasswordState>
    implements DeviceResetPasswordBloc {}

class FakeDeviceResetPasswordEvent extends Fake implements DeviceResetPasswordEvent {}

void main() {
  late MockDeviceResetPasswordBloc bloc;

  setUpAll(() => registerFallbackValue(FakeDeviceResetPasswordEvent()));

  setUp(() => bloc = MockDeviceResetPasswordBloc());

  Future<void> pumpPage(WidgetTester tester, DeviceResetPasswordState state,
      {Stream<DeviceResetPasswordState>? states}) async {
    setUpCustomScreenSize(tester, 390, 844);
    whenListen(bloc, states ?? const Stream<DeviceResetPasswordState>.empty(), initialState: state);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('profile'))),
      GoRoute(
        path: '/forgot',
        builder: (_, __) =>
            BlocProvider<DeviceResetPasswordBloc>.value(value: bloc, child: const DeviceResetPasswordPage()),
      ),
    ]);
    await tester.pumpWidget(makeTestableRouter(router: router));
    router.push('/forgot');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> submit(WidgetTester tester, String password, [String? confirmation]) async {
    await tester.enterText(find.byKey(const ValueKey('device-reset-password')), password);
    await tester.enterText(find.byKey(const ValueKey('device-reset-confirm')), confirmation ?? password);
    await tester.tap(find.byKey(const ValueKey('device-reset-submit')));
    await tester.pump();
  }

  group('DeviceResetPasswordPage', () {
    testWidgets('should explain that nothing is lost and send the new password with the prompt text', (tester) async {
      await pumpPage(tester, DeviceResetPasswordInitial());
      expect(find.textContaining('without losing anything'), findsOneWidget);

      await submit(tester, 'a brand new password');

      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(event, isA<DeviceResetPasswordSubmitted>()
          .having((e) => e.newPassword, 'password', 'a brand new password')
          .having((e) => e.reason, 'reason', 'Confirm it is you to change the password'));
    });

    testWidgets('should reject passwords shorter than 10 characters', (tester) async {
      await pumpPage(tester, DeviceResetPasswordInitial());

      await submit(tester, 'short');

      expect(find.text('The password must have at least 10 characters.'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('should reject mismatching passwords', (tester) async {
      await pumpPage(tester, DeviceResetPasswordInitial());

      await submit(tester, 'a brand new password', 'another new password');

      expect(find.text('Passwords do not match'), findsOneWidget);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('should go back to the profile once the password is changed', (tester) async {
      await pumpPage(tester, DeviceResetPasswordInitial(), states: Stream.value(DeviceResetPasswordSuccess()));
      await tester.pumpAndSettle();

      expect(find.text('Password changed'), findsOneWidget);
      expect(find.text('profile'), findsOneWidget);
    });

    testWidgets('should show loading on the button', (tester) async {
      await pumpPage(tester, DeviceResetPasswordLoading());

      expect(tester.widget<AppButton>(find.byKey(const ValueKey('device-reset-submit'))).loading, isTrue);
    });
  });
}
