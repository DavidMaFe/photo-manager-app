

abstract class ProfileEvent {}


class LoadProfileRequested extends ProfileEvent {}


class RefreshProfileRequested extends ProfileEvent {}


class UpdateProfileRequested extends ProfileEvent {
  final String? name;
  final String? surname;
  final String? profileImage;

  UpdateProfileRequested({
    this.name,
    this.surname,
    this.profileImage,
  });
}


class ChangePasswordRequested extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });
}