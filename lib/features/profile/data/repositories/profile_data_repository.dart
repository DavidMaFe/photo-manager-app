import 'package:photo_manager_app/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/features/profile/domain/repositories/profile_repository.dart';


class ProfileDataRepository implements ProfileRepository {

  final ProfileRemoteDataSource profileRemoteDatasource;
  final ProfileLocalDataSource profileLocalDataSource;

  ProfileDataRepository({
    required this.profileRemoteDatasource,
    required this.profileLocalDataSource
  });

  @override
  Future<UserProfile> getUserProfile() async {

    try {

      final profileModel = await profileRemoteDatasource.getUserProfile();
      await profileLocalDataSource.cacheProfile(profileModel);
      return profileModel;
    } catch (e) {

      final cachedProfile = await profileLocalDataSource.getCachedProfile();
      if (cachedProfile != null) {
        return cachedProfile;
      }

      rethrow;
    }
  }

  @override
  Future<UserProfile?> getCachedProfile() async {
    return await profileLocalDataSource.getCachedProfile();
  }
}