import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/permissions/app_permission.dart';
import 'package:photo_manager_app/core/permissions/permission_access.dart';
import 'package:photo_manager_app/core/permissions/permission_service.dart';
import 'package:photo_manager_app/features/onboarding/domain/use_cases/complete_onboarding_use_case.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_state.dart';

/// BLoC for the first-launch permissions screen: asks for each permission
/// separately and completes the onboarding.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final CompleteOnboardingUseCase _completeOnboardingUseCase;
  final PermissionService _permissionService;

  OnboardingBloc({
    required CompleteOnboardingUseCase completeOnboardingUseCase,
    required PermissionService permissionService,
  })  : _completeOnboardingUseCase = completeOnboardingUseCase,
        _permissionService = permissionService,
        super(const OnboardingInitial()) {
    on<OnboardingStarted>(_onOnboardingStarted);
    on<PhotoPermissionRequested>((_, emit) => _request(AppPermission.photos, emit));
    on<NotificationPermissionRequested>((_, emit) => _request(AppPermission.notifications, emit));
    on<BackgroundPermissionRequested>((_, emit) => _request(AppPermission.background, emit));
    on<PermissionSettingsRequested>(_onPermissionSettingsRequested);
    on<PermissionsRechecked>(_onPermissionsRechecked);
    on<PermissionsGranted>(_onPermissionsGranted);
    on<OnboardingCompleted>(_onOnboardingCompleted);
  }

  OnboardingPermissions get _permissions {
    final current = state;
    return current is OnboardingPermissions ? current : const OnboardingPermissions();
  }

  Future<void> _onOnboardingStarted(OnboardingStarted event, Emitter<OnboardingState> emit) async {
    emit(await _checkAll(const OnboardingPermissions()));
  }

  Future<void> _onPermissionsRechecked(PermissionsRechecked event, Emitter<OnboardingState> emit) async {
    if (state is! OnboardingPermissions) return;
    emit(await _checkAll(_permissions));
  }

  /// Granted permissions become granted; the rest keep pending or blocked.
  Future<OnboardingPermissions> _checkAll(OnboardingPermissions current) async {
    var result = current;
    for (final permission in AppPermission.values) {
      final granted = await _isGranted(permission);
      final previous = current.accessOf(permission);
      result = result.withAccess(
        permission,
        granted
            ? PermissionAccess.granted
            : previous == PermissionAccess.blocked
                ? PermissionAccess.blocked
                : PermissionAccess.pending,
      );
    }
    return result;
  }

  Future<bool> _isGranted(AppPermission permission) async {
    try {
      return await _permissionService.isGranted(permission);
    } catch (_) {
      return false;
    }
  }

  Future<void> _request(AppPermission permission, Emitter<OnboardingState> emit) async {
    final current = _permissions;
    if (current.requesting != null || current.accessOf(permission) == PermissionAccess.granted) return;

    emit(current.requestingPermission(permission));

    bool granted;
    try {
      granted = await _permissionService.request(permission);
    } catch (_) {
      granted = false;
    }

    // Once denied, the system may not show the prompt again: send to settings.
    emit(current.withAccess(permission, granted ? PermissionAccess.granted : PermissionAccess.blocked));
  }

  Future<void> _onPermissionSettingsRequested(
    PermissionSettingsRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      await _permissionService.openSettings();
    } catch (_) {
      // Nothing else to offer: the permissions can still be changed from Profile.
    }
  }

  /// Handle permissions granted event
  Future<void> _onPermissionsGranted(
    PermissionsGranted event,
    Emitter<OnboardingState> emit,
  ) async {
    // Check if all permissions were granted
    final allGranted = event.photoGranted &&
        event.notificationGranted &&
        event.backgroundGranted;

    if (allGranted) {
      // All permissions granted, complete onboarding
      await _completeOnboardingUseCase();
      emit(const OnboardingComplete(allPermissionsGranted: true));
    } else {
      // Some permissions denied, show warning
      emit(OnboardingPermissionsPartiallyDenied(
        photoGranted: event.photoGranted,
        notificationGranted: event.notificationGranted,
        backgroundGranted: event.backgroundGranted,
      ));
    }
  }

  /// Marks the onboarding as done, whatever was granted.
  Future<void> _onOnboardingCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    final allGranted = state is OnboardingPermissions && _permissions.allGranted;
    await _completeOnboardingUseCase();
    emit(OnboardingComplete(allPermissionsGranted: allGranted));
  }
}
