import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/totp_set_up.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/two_factor_status.dart';

enum TwoFactorView {
  loading,

  /// Whether the app is on, and what can be done with it.
  status,

  /// Setting the app up: the secret and the code that confirms it.
  setUp,

  /// The backup codes just issued, shown once.
  backupCodes,

  /// The status could not be loaded.
  error,
}

/// One-time notices of the page.
enum TwoFactorNotice { disabled }

/// [working] while an action runs; [failure] of the last action (or of the load, in [TwoFactorView.error]).
class TwoFactorState {
  final TwoFactorView view;
  final TwoFactorStatus? status;
  final TotpSetUp? setUp;
  final List<String> backupCodes;
  final bool working;
  final Failure? failure;
  final TwoFactorNotice? notice;

  const TwoFactorState({
    this.view = TwoFactorView.loading,
    this.status,
    this.setUp,
    this.backupCodes = const [],
    this.working = false,
    this.failure,
    this.notice,
  });

  /// [failure] and [notice] are not kept: they are shown once.
  TwoFactorState copyWith({
    TwoFactorView? view,
    TwoFactorStatus? status,
    TotpSetUp? setUp,
    List<String>? backupCodes,
    bool? working,
    Failure? failure,
    TwoFactorNotice? notice,
  }) {
    return TwoFactorState(
      view: view ?? this.view,
      status: status ?? this.status,
      setUp: setUp ?? this.setUp,
      backupCodes: backupCodes ?? this.backupCodes,
      working: working ?? this.working,
      failure: failure,
      notice: notice,
    );
  }
}
