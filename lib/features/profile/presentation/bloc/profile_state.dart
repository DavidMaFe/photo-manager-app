

import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';

abstract class ProfileState {}


class ProfileInitial extends ProfileState {}


class ProfileLoading extends ProfileState {}


class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;
  ProfileLoaded(this.userProfile);
}


class ProfileError extends ProfileState {
  final String errorMessage;
  ProfileError(this.errorMessage);
}