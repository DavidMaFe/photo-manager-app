import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/features/profile/domain/repositories/profile_repository.dart';

class UpdateUserProfileUseCase {
  final ProfileRepository _profileRepository;

  UpdateUserProfileUseCase(this._profileRepository);

  Future<UserProfile> call({
    String? name,
    String? surname,
    String? profileImage,
  }) async {
    return await _profileRepository.updateUserProfile(
      name: name,
      surname: surname,
      profileImage: profileImage,
    );
  }
}
