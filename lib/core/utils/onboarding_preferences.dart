import 'package:shared_preferences/shared_preferences.dart';

/// Helper class to manage onboarding completion status in SharedPreferences
class OnboardingPreferences {
  static const String _hasCompletedOnboardingKey =
      'HAS_COMPLETED_ONBOARDING_PERMISSIONS';

  final SharedPreferences _sharedPreferences;

  OnboardingPreferences(this._sharedPreferences);

  /// Check if the user has completed the onboarding permission flow
  Future<bool> hasCompletedOnboarding() async {
    return _sharedPreferences.getBool(_hasCompletedOnboardingKey) ?? false;
  }

  /// Mark the onboarding permission flow as completed
  Future<void> setOnboardingCompleted() async {
    await _sharedPreferences.setBool(_hasCompletedOnboardingKey, true);
  }

  /// Reset onboarding status (useful for testing or debugging)
  Future<void> resetOnboarding() async {
    await _sharedPreferences.remove(_hasCompletedOnboardingKey);
  }
}
