
class UserProfile {

  final String id;
  final String email;
  final String name;
  final String? surname;
  final String? profileImage;
  final double storageUsedMb;
  final int storageTotalMb;
  final int fileCount;
  final int folderCount;
  final int deviceCount;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.surname,
    this.profileImage,
    required this.storageUsedMb,
    required this.storageTotalMb,
    required this.fileCount,
    required this.folderCount,
    required this.deviceCount
  });

  String get fullName => '$name${surname != null ? " $surname" : ''}';

  double get storageUsedGb => storageUsedMb / 1024;
  double get storageTotalGb => storageTotalMb / 1024;

  double get storageUsedPercentage => storageTotalMb > 0
      ? (storageUsedMb/storageTotalMb) : 0;

  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;
}