import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Base class for onboarding events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start the onboarding flow
class OnboardingStarted extends OnboardingEvent {
  final BuildContext context;

  const OnboardingStarted(this.context);

  @override
  List<Object?> get props => [context];
}

/// Event to request all permissions
class PermissionsRequested extends OnboardingEvent {
  final BuildContext context;

  const PermissionsRequested(this.context);

  @override
  List<Object?> get props => [context];
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

/// Event when user wants to retry permission requests
class RetryPermissionsRequested extends OnboardingEvent {
  final BuildContext context;

  const RetryPermissionsRequested(this.context);

  @override
  List<Object?> get props => [context];
}

/// Event to complete onboarding
class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}
