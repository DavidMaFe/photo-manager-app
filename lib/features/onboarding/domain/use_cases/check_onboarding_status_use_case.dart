import 'package:photo_manager_app/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case to check if the user has completed the onboarding flow
class CheckOnboardingStatusUseCase {
  final OnboardingRepository _repository;

  CheckOnboardingStatusUseCase(this._repository);

  /// Check if the user has completed onboarding
  ///
  /// Returns true if onboarding was completed, false otherwise
  Future<bool> call() async {
    return await _repository.hasCompletedOnboarding();
  }
}
