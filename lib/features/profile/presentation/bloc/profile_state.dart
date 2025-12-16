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