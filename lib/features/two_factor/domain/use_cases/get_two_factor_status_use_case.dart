import 'package:photo_manager_app/features/two_factor/domain/entities/two_factor_status.dart';
import 'package:photo_manager_app/features/two_factor/domain/repositories/two_factor_repository.dart';

class GetTwoFactorStatusUseCase {
  final TwoFactorRepository _repository;

  GetTwoFactorStatusUseCase(this._repository);

  Future<TwoFactorStatus> call() => _repository.getStatus();
}
