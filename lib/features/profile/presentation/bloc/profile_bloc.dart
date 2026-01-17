import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/update_user_profile_use_case.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/change_password_use_case.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {

  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final AppEventBus eventBus;

  StreamSubscription<FileUpdatedEvent>? _fileUpdateSubscription;
  StreamSubscription<FolderUpdatedEvent>? _folderUpdateSubscription;
  StreamSubscription<SyncCompletedEvent>? _syncCompletedSubscription;

  ProfileBloc(
    this.getUserProfileUseCase,
    this.updateUserProfileUseCase,
    this.changePasswordUseCase,
    this.eventBus,
  ) : super(ProfileInitial()) {
    on<LoadProfileRequested>(_onLoadProfile);
    on<RefreshProfileRequested>(_onRefreshProfile);
    on<UpdateProfileRequested>(_onUpdateProfile);
    on<ChangePasswordRequested>(_onChangePassword);

    // Listen to file updates and auto-refresh stats
    _fileUpdateSubscription = eventBus.on<FileUpdatedEvent>().listen((_) {
      add(RefreshProfileRequested());
    });

    // Listen to folder updates and auto-refresh stats
    _folderUpdateSubscription = eventBus.on<FolderUpdatedEvent>().listen((_) {
      add(RefreshProfileRequested());
    });

    // Listen to sync completion and auto-refresh stats
    _syncCompletedSubscription = eventBus.on<SyncCompletedEvent>().listen((_) {
      add(RefreshProfileRequested());
    });
  }

  @override
  Future<void> close() {
    _fileUpdateSubscription?.cancel();
    _folderUpdateSubscription?.cancel();
    _syncCompletedSubscription?.cancel();
    return super.close();
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

  Future<void> _onUpdateProfile(UpdateProfileRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileUpdating());

    try {
      final updatedProfile = await updateUserProfileUseCase(
        name: event.name,
        surname: event.surname,
        profileImage: event.profileImage,
      );
      emit(ProfileUpdateSuccess(updatedProfile));
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      final failure = ErrorHandler.handleError(e);
      emit(ProfileUpdateError(failure));
    }
  }

  Future<void> _onChangePassword(ChangePasswordRequested event, Emitter<ProfileState> emit) async {
    emit(PasswordChanging());

    try {
      await changePasswordUseCase(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(PasswordChangeSuccess());
    } catch (e) {
      final failure = ErrorHandler.handleError(e);
      emit(PasswordChangeError(failure));
    }
  }
}