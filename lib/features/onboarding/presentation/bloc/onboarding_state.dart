import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/permissions/app_permission.dart';
import 'package:photo_manager_app/core/permissions/permission_access.dart';

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

/// The permissions screen: where each of the three permissions stands.
class OnboardingPermissions extends OnboardingState {
  final PermissionAccess photos;
  final PermissionAccess notifications;
  final PermissionAccess background;

  /// Permission whose system prompt is showing.
  final AppPermission? requesting;

  const OnboardingPermissions({
    this.photos = PermissionAccess.pending,
    this.notifications = PermissionAccess.pending,
    this.background = PermissionAccess.pending,
    this.requesting,
  });

  PermissionAccess accessOf(AppPermission permission) {
    return switch (permission) {
      AppPermission.photos => photos,
      AppPermission.notifications => notifications,
      AppPermission.background => background,
    };
  }

  bool get allGranted => AppPermission.values.every((p) => accessOf(p) == PermissionAccess.granted);

  /// First permission still to grant, in screen order.
  AppPermission? get nextRecommended {
    for (final permission in AppPermission.values) {
      if (accessOf(permission) != PermissionAccess.granted) return permission;
    }
    return null;
  }

  OnboardingPermissions copyWith({
    PermissionAccess? photos,
    PermissionAccess? notifications,
    PermissionAccess? background,
  }) {
    return OnboardingPermissions(
      photos: photos ?? this.photos,
      notifications: notifications ?? this.notifications,
      background: background ?? this.background,
    );
  }

  OnboardingPermissions withAccess(AppPermission permission, PermissionAccess access) {
    return switch (permission) {
      AppPermission.photos => copyWith(photos: access),
      AppPermission.notifications => copyWith(notifications: access),
      AppPermission.background => copyWith(background: access),
    };
  }

  OnboardingPermissions requestingPermission(AppPermission permission) {
    return OnboardingPermissions(
      photos: photos,
      notifications: notifications,
      background: background,
      requesting: permission,
    );
  }

  @override
  List<Object?> get props => [photos, notifications, background, requesting];
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
