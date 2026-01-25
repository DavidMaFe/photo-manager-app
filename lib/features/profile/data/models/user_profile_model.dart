
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {

  UserProfileModel({
    required super.id,
    required super.email,
    required super.name,
    super.surname,
    required super.hasProfileImage,
    required super.storageUsedMb,
    required super.storageTotalMb,
    required super.fileCount,
    required super.folderCount,
    required super.deviceCount
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};

    return UserProfileModel(
      id: json['id'].toString(),
      email: json['email'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String?,
      hasProfileImage: json['hasProfileImage'] as bool,
      storageUsedMb: (json['storageUsedMb'] as num?)?.toDouble() ?? 0.0,
      storageTotalMb: json['storageTotalMb'] as int,
      fileCount: stats['fileCount'] as int? ?? 0,
      folderCount: stats['folderCount'] as int? ?? 0,
      deviceCount: stats['deviceCount'] as int? ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'surname': surname,
      'hasProfileImage': hasProfileImage,
      'storageUsedMb': storageUsedMb,
      'storageTotalMb': storageTotalMb,
      'stats': {
        'fileCount': fileCount,
        'folderCount': folderCount,
        'deviceCount': deviceCount
      }
    };
  }

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      email: profile.email,
      name: profile.name,
      surname: profile.surname,
      hasProfileImage: profile.hasProfileImage,
      storageUsedMb: profile.storageUsedMb,
      storageTotalMb: profile.storageTotalMb,
      fileCount: profile.fileCount,
      folderCount: profile.folderCount,
      deviceCount: profile.deviceCount
    );
  }
}