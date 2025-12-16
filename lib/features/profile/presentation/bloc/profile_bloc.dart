import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {

  final GetUserProfileUseCase getUserProfileUseCase;

  ProfileBloc(this.getUserProfileUseCase) : super(ProfileInitial()) {
    on<LoadProfileRequested>(_onLoadProfile);
    on<RefreshProfileRequested>(_onRefreshProfile);
  }

  Future<void> _onLoadProfile(LoadProfileRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    try {
      final profile = await getUserProfileUseCase();
      emit(ProfileLoaded(profile));
    } catch (e) {
      final failure = ErrorHandler.handleError(e);
      emit(ProfileError(failure));
    }
  }

  Future<void> _onRefreshProfile(RefreshProfileRequested event, Emitter<ProfileState> emit) async {
    try {
      final profile = await getUserProfileUseCase();
      emit(ProfileLoaded(profile));
    } catch (e) {
      final failure = ErrorHandler.handleError(e);
      emit(ProfileError(failure));
    }
  }
}