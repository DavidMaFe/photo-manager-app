
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/features/profile/domain/repositories/profile_repository.dart';

class GetUserProfileUseCase {

  final ProfileRepository _profileRepository;

  GetUserProfileUseCase(this._profileRepository);

  Future<UserProfile> call() async {
    return await _profileRepository.getUserProfile();
  }
}