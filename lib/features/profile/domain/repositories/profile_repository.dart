import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';


abstract class ProfileRepository {
  Future<UserProfile> getUserProfile();
  Future<UserProfile?> getCachedProfile();
  Future<UserProfile> updateUserProfile({
    String? name,
    String? surname,
    String? profileImage,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}