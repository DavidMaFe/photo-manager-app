import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/onboarding/domain/use_cases/complete_onboarding_use_case.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_state.dart';

/// BLoC for managing the onboarding permission flow
///
/// This BLoC manages the state of the onboarding flow.
/// Permission requests are handled by the UI layer using PermissionHelper.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final CompleteOnboardingUseCase _completeOnboardingUseCase;

  OnboardingBloc({
    required CompleteOnboardingUseCase completeOnboardingUseCase,
  })  : _completeOnboardingUseCase = completeOnboardingUseCase,
        super(const OnboardingInitial()) {
    on<OnboardingStarted>(_onOnboardingStarted);
    on<PermissionsRequested>(_onPermissionsRequested);
    on<PermissionsGranted>(_onPermissionsGranted);
    on<RetryPermissionsRequested>(_onRetryPermissionsRequested);
    on<OnboardingCompleted>(_onOnboardingCompleted);
  }

  /// Handle onboarding started event
  void _onOnboardingStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) {
    emit(const OnboardingWelcome());
  }

  /// Handle permissions requested event
  void _onPermissionsRequested(
    PermissionsRequested event,
    Emitter<OnboardingState> emit,
  ) {
    // Emit state indicating we're requesting permissions
    // The actual permission requests are handled by the UI layer
    emit(const OnboardingRequestingPermissions());
  }

  /// Handle permissions granted event
  Future<void> _onPermissionsGranted(
    PermissionsGranted event,
    Emitter<OnboardingState> emit,
  ) async {
    // Check if all permissions were granted
    final allGranted = event.photoGranted &&
        event.notificationGranted &&
        event.backgroundGranted;

    if (allGranted) {
      // All permissions granted, complete onboarding
      await _completeOnboardingUseCase();
      emit(const OnboardingComplete(allPermissionsGranted: true));
    } else {
      // Some permissions denied, show warning
      emit(OnboardingPermissionsPartiallyDenied(
        photoGranted: event.photoGranted,
        notificationGranted: event.notificationGranted,
        backgroundGranted: event.backgroundGranted,
      ));
    }
  }

  /// Handle retry permissions requested event
  void _onRetryPermissionsRequested(
    RetryPermissionsRequested event,
    Emitter<OnboardingState> emit,
  ) {
    // Go back to requesting permissions
    emit(const OnboardingRequestingPermissions());
  }

  /// Handle onboarding completed event
  Future<void> _onOnboardingCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    // Mark onboarding as complete even if not all permissions granted
    await _completeOnboardingUseCase();
    emit(const OnboardingComplete(allPermissionsGranted: false));
  }
}
