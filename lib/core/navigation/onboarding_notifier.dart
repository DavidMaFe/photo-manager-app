import 'package:flutter/material.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/onboarding/domain/use_cases/check_onboarding_status_use_case.dart';

/// Notifier that tracks whether the onboarding flow is required for the current user
///
/// Listens to [AuthBloc] state changes and checks onboarding status whenever
/// the user successfully authenticates.
class OnboardingNotifier extends ChangeNotifier {
  final AuthBloc _authBloc;
  final CheckOnboardingStatusUseCase _checkOnboardingStatusUseCase;

  bool _onboardingRequired = false;
  bool _isCheckingStatus = false;

  OnboardingNotifier({
    required AuthBloc authBloc,
    required CheckOnboardingStatusUseCase checkOnboardingStatusUseCase,
  })  : _authBloc = authBloc,
        _checkOnboardingStatusUseCase = checkOnboardingStatusUseCase {
    // Listen to auth state changes
    _authBloc.stream.listen(_onAuthStateChanged);
  }

  /// Whether onboarding is required for the current user
  bool get isOnboardingRequired => _onboardingRequired;

  /// Whether we're currently checking the onboarding status
  bool get isCheckingStatus => _isCheckingStatus;

  /// Called when the auth state changes
  Future<void> _onAuthStateChanged(dynamic state) async {
    if (state is AuthSuccessful) {
      // User just logged in, check if onboarding is needed
      _isCheckingStatus = true;
      notifyListeners();

      try {
        final hasCompleted = await _checkOnboardingStatusUseCase();
        _onboardingRequired = !hasCompleted;
      } catch (_) {
        // If check fails, assume onboarding is not required to avoid blocking the user
        _onboardingRequired = false;
      } finally {
        _isCheckingStatus = false;
        notifyListeners();
      }
    } else if (state is NotAuthenticated) {
      // User logged out, reset state
      _onboardingRequired = false;
      notifyListeners();
    }
  }

  /// Mark onboarding as no longer required
  ///
  /// Call this after the user completes the onboarding flow
  void markOnboardingComplete() {
    _onboardingRequired = false;
    notifyListeners();
  }
}
