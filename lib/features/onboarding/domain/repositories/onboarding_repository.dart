/// Repository interface for managing onboarding status
///
/// This repository handles the persistence of the user's onboarding completion status
abstract class OnboardingRepository {
  /// Check if the user has completed the onboarding flow
  Future<bool> hasCompletedOnboarding();

  /// Mark the onboarding flow as completed
  Future<void> setOnboardingCompleted();

  /// Reset onboarding status (useful for testing)
  Future<void> resetOnboarding();
}
