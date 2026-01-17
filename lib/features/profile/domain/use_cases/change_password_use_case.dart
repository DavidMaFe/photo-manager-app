import 'package:photo_manager_app/features/profile/domain/repositories/profile_repository.dart';

class ChangePasswordUseCase {
  final ProfileRepository _profileRepository;

  ChangePasswordUseCase(this._profileRepository);

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _profileRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
