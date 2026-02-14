import 'package:photo_manager_app/features/onboarding/data/data_sources/onboarding_local_data_source.dart';
import 'package:photo_manager_app/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Data layer implementation of OnboardingRepository
class OnboardingDataRepository implements OnboardingRepository {
  final OnboardingLocalDataSource _localDataSource;

  OnboardingDataRepository(this._localDataSource);

  @override
  Future<bool> hasCompletedOnboarding() async {
    return await _localDataSource.hasCompletedOnboarding();
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await _localDataSource.setOnboardingCompleted();
  }

  @override
  Future<void> resetOnboarding() async {
    await _localDataSource.resetOnboarding();
  }
}
