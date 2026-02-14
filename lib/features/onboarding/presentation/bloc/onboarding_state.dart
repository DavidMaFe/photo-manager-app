import 'package:equatable/equatable.dart';

/// Base class for onboarding states
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// Showing welcome dialog
class OnboardingWelcome extends OnboardingState {
  const OnboardingWelcome();
}

/// Requesting permissions
class OnboardingRequestingPermissions extends OnboardingState {
  const OnboardingRequestingPermissions();
}

/// Some permissions were denied
class OnboardingPermissionsPartiallyDenied extends OnboardingState {
  final bool photoGranted;
  final bool notificationGranted;
  final bool backgroundGranted;

  const OnboardingPermissionsPartiallyDenied({
    required this.photoGranted,
    required this.notificationGranted,
    required this.backgroundGranted,
  });

  /// Get list of denied permission names
  List<String> get deniedPermissions {
    final denied = <String>[];
    if (!photoGranted) denied.add('photo');
    if (!notificationGranted) denied.add('notification');
    if (!backgroundGranted) denied.add('background');
    return denied;
  }

  /// Check if all permissions were denied
  bool get allDenied => !photoGranted && !notificationGranted && !backgroundGranted;

  @override
  List<Object?> get props => [photoGranted, notificationGranted, backgroundGranted];
}

/// All permissions granted or onboarding complete
class OnboardingComplete extends OnboardingState {
  final bool allPermissionsGranted;

  const OnboardingComplete({this.allPermissionsGranted = true});

  @override
  List<Object?> get props => [allPermissionsGranted];
}

/// Error during onboarding
class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
