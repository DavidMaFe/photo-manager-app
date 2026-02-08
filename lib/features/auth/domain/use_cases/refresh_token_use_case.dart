
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';


class RefreshTokenUseCase {

  final AuthRepository _authRepository;

  RefreshTokenUseCase(this._authRepository);

  Future<void> call() async {
    await _authRepository.refreshToken();
  }
}
