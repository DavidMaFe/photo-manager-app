import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/totp_set_up.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/disable_totp_use_case.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/enable_totp_use_case.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/get_two_factor_status_use_case.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/regenerate_backup_codes_use_case.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/set_up_totp_use_case.dart';
import 'package:photo_manager_app/features/two_factor/presentation/bloc/two_factor_state.dart';

export 'package:photo_manager_app/features/two_factor/presentation/bloc/two_factor_state.dart';

/// The authenticator app page: its status, the set-up, the backup codes and turning it off.
class TwoFactorCubit extends Cubit<TwoFactorState> {
  static const int minimumLoadingDuration = 800;

  final GetTwoFactorStatusUseCase getStatus;
  final SetUpTotpUseCase setUpTotp;
  final EnableTotpUseCase enableTotp;
  final DisableTotpUseCase disableTotp;
  final RegenerateBackupCodesUseCase regenerateBackupCodes;

  TwoFactorCubit({
    required this.getStatus,
    required this.setUpTotp,
    required this.enableTotp,
    required this.disableTotp,
    required this.regenerateBackupCodes,
  }) : super(const TwoFactorState());

  Future<void> load() async {
    emit(const TwoFactorState());
    try {
      final status = await _withMinimumDuration(getStatus);
      emit(TwoFactorState(view: TwoFactorView.status, status: status));
    } catch (e) {
      emit(TwoFactorState(view: TwoFactorView.error, failure: ErrorHandler.handleError(e)));
    }
  }

  Future<void> startSetUp() => _run(() async {
        final TotpSetUp setUp = await setUpTotp();
        return TwoFactorState(view: TwoFactorView.setUp, status: state.status, setUp: setUp);
      });

  void cancelSetUp() => emit(TwoFactorState(view: TwoFactorView.status, status: state.status));

  Future<void> enable(String code) => _run(() async {
        final codes = await enableTotp(code);
        return TwoFactorState(view: TwoFactorView.backupCodes, status: state.status, backupCodes: codes);
      });

  Future<void> disable({required String password, required String code}) => _run(() async {
        await disableTotp(password: password, code: code);
        final status = await getStatus();
        return TwoFactorState(view: TwoFactorView.status, status: status, notice: TwoFactorNotice.disabled);
      });

  Future<void> regenerate({required String password, required String code}) => _run(() async {
        final codes = await regenerateBackupCodes(password: password, code: code);
        return TwoFactorState(view: TwoFactorView.backupCodes, status: state.status, backupCodes: codes);
      });

  /// The user saved the backup codes: they are forgotten and the status is shown again.
  Future<void> backupCodesSaved() => load();

  /// The failure or the notice was shown.
  void feedbackShown() => emit(state.copyWith());

  /// Runs [action] showing [TwoFactorState.working] for at least [minimumLoadingDuration], then emits the state it
  /// returns. A failure keeps the view, with the failure.
  Future<void> _run(Future<TwoFactorState> Function() action) async {
    if (state.working) return;
    emit(state.copyWith(working: true));
    try {
      emit(await _withMinimumDuration(action));
    } catch (e) {
      emit(state.copyWith(working: false, failure: ErrorHandler.handleError(e)));
    }
  }

  /// A failure waits too, so the loading never flickers.
  Future<T> _withMinimumDuration<T>(Future<T> Function() action) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      await _waitRest(stopwatch);
    }
  }

  Future<void> _waitRest(Stopwatch stopwatch) async {
    final remaining = minimumLoadingDuration - stopwatch.elapsedMilliseconds;
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }
  }
}
