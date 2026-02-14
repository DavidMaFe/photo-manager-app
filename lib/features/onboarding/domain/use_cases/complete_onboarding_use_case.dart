import 'package:photo_manager_app/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case to mark the onboarding flow as completed
class CompleteOnboardingUseCase {
  final OnboardingRepository _repository;

  CompleteOnboardingUseCase(this._repository);

  /// Mark onboarding as completed
  ///
  /// This prevents the onboarding flow from showing again on subsequent logins
  Future<void> call() async {
    await _repository.setOnboardingCompleted();
  }
}
