import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/reset_password_from_device_use_case.dart';
import 'package:photo_manager_app/features/account_security/presentation/bloc/device_reset_password_bloc.dart';

class MockResetPasswordFromDeviceUseCase extends Mock implements ResetPasswordFromDeviceUseCase {}

void main() {
  late MockResetPasswordFromDeviceUseCase useCase;

  setUp(() => useCase = MockResetPasswordFromDeviceUseCase());

  DeviceResetPasswordBloc build() => DeviceResetPasswordBloc(resetPasswordFromDeviceUseCase: useCase);

  group('DeviceResetPasswordBloc', () {
    test('initial state should be DeviceResetPasswordInitial', () {
      expect(build().state, isA<DeviceResetPasswordInitial>());
    });

    blocTest<DeviceResetPasswordBloc, DeviceResetPasswordState>(
      'should emit [Loading, Success] when the password is reset',
      build: () {
        when(() => useCase(newPassword: 'new password', reason: 'Confirm')).thenAnswer((_) async {});
        return build();
      },
      act: (bloc) => bloc.add(DeviceResetPasswordSubmitted(newPassword: 'new password', reason: 'Confirm')),
      expect: () => [isA<DeviceResetPasswordLoading>(), isA<DeviceResetPasswordSuccess>()],
    );

    blocTest<DeviceResetPasswordBloc, DeviceResetPasswordState>(
      'should emit [Loading, Error] when the device lock is not passed',
      build: () {
        when(() => useCase(newPassword: any(named: 'newPassword'), reason: any(named: 'reason')))
            .thenThrow(const DeviceAuthenticationFailure());
        return build();
      },
      act: (bloc) => bloc.add(DeviceResetPasswordSubmitted(newPassword: 'new password', reason: 'Confirm')),
      expect: () => [
        isA<DeviceResetPasswordLoading>(),
        isA<DeviceResetPasswordError>().having((s) => s.failure, 'failure', isA<DeviceAuthenticationFailure>()),
      ],
    );
  });
}
