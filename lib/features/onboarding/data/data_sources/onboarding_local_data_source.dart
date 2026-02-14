import 'package:photo_manager_app/core/utils/onboarding_preferences.dart';

/// Local data source for onboarding status
///
/// Uses SharedPreferences to persist onboarding completion status
abstract class OnboardingLocalDataSource {
  /// Check if onboarding has been completed
  Future<bool> hasCompletedOnboarding();

  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted();

  /// Reset onboarding status
  Future<void> resetOnboarding();
}

/// Implementation of OnboardingLocalDataSource using SharedPreferences
class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final OnboardingPreferences _preferences;

  OnboardingLocalDataSourceImpl(this._preferences);

  @override
  Future<bool> hasCompletedOnboarding() async {
    return await _preferences.hasCompletedOnboarding();
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await _preferences.setOnboardingCompleted();
  }

  @override
  Future<void> resetOnboarding() async {
    await _preferences.resetOnboarding();
  }
}
