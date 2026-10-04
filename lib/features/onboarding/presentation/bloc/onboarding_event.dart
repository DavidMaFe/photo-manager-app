import 'package:equatable/equatable.dart';

/// Base class for onboarding events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start the onboarding flow: checks what is already granted.
class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

/// Asks for access to photos and videos.
class PhotoPermissionRequested extends OnboardingEvent {
  const PhotoPermissionRequested();
}

/// Asks to send notifications.
class NotificationPermissionRequested extends OnboardingEvent {
  const NotificationPermissionRequested();
}

/// Asks to keep backing up with the app closed.
class BackgroundPermissionRequested extends OnboardingEvent {
  const BackgroundPermissionRequested();
}

/// Opens the system settings for a permission that can no longer be asked.
class PermissionSettingsRequested extends OnboardingEvent {
  const PermissionSettingsRequested();
}

/// Checks the permissions again (e.g. back from the system settings).
class PermissionsRechecked extends OnboardingEvent {
  const PermissionsRechecked();
}

/// Event when permissions are granted
class PermissionsGranted extends OnboardingEvent {
  final bool photoGranted;
  final bool notificationGranted;
  final bool backgroundGranted;

  const PermissionsGranted({
    required this.photoGranted,
    required this.notificationGranted,
    required this.backgroundGranted,
  });

  @override
  List<Object?> get props => [photoGranted, notificationGranted, backgroundGranted];
}

/// Event to complete onboarding
class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}
