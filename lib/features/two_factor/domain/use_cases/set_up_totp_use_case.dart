import 'package:photo_manager_app/features/two_factor/domain/entities/totp_set_up.dart';
import 'package:photo_manager_app/features/two_factor/domain/repositories/two_factor_repository.dart';

/// First step of turning the authenticator app on: a secret for it, pending until a code confirms it.
class SetUpTotpUseCase {
  final TwoFactorRepository _repository;

  SetUpTotpUseCase(this._repository);

  Future<TotpSetUp> call() => _repository.setUpTotp();
}
