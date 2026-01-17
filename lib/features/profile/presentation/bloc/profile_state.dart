import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';

abstract class ProfileState {}


class ProfileInitial extends ProfileState {}


class ProfileLoading extends ProfileState {}


class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;
  ProfileLoaded(this.userProfile);
}


class ProfileError extends ProfileState {
  final Failure failure;
  ProfileError(this.failure);
}


class ProfileUpdating extends ProfileState {}


class ProfileUpdateSuccess extends ProfileState {
  final UserProfile userProfile;
  ProfileUpdateSuccess(this.userProfile);
}


class ProfileUpdateError extends ProfileState {
  final Failure failure;
  ProfileUpdateError(this.failure);
}


class PasswordChanging extends ProfileState {}


class PasswordChangeSuccess extends ProfileState {}


class PasswordChangeError extends ProfileState {
  final Failure failure;
  PasswordChangeError(this.failure);
}