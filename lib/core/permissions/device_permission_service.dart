import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_app/core/permissions/app_permission.dart';
import 'package:photo_manager_app/core/permissions/permission_service.dart';
import 'package:photo_manager_app/core/widgets/permission/background_task_permission_helper.dart';
import 'package:photo_manager_app/core/widgets/permission/notification_permission_helper.dart';

/// [PermissionService] backed by the platform plugins.
class DevicePermissionService implements PermissionService {

  static const _photoOption = PermissionRequestOption(
    iosAccessLevel: IosAccessLevel.readWrite,
    androidPermission: AndroidPermission(type: RequestType.common, mediaLocation: false),
  );

  @override
  Future<bool> isGranted(AppPermission permission) async {
    switch (permission) {
      case AppPermission.photos:
        final state = await PhotoManager.getPermissionState(requestOption: _photoOption);
        return state.hasAccess;
      case AppPermission.notifications:
        return NotificationPermissionHelper.areNotificationsEnabled();
      case AppPermission.background:
        return BackgroundTaskPermissionHelper.isBackgroundTaskEnabled();
    }
  }

  @override
  Future<bool> request(AppPermission permission) async {
    switch (permission) {
      case AppPermission.photos:
        final state = await PhotoManager.requestPermissionExtend(requestOption: _photoOption);
        return state.hasAccess;
      case AppPermission.notifications:
        return NotificationPermissionHelper.requestFromOS();
      case AppPermission.background:
        return BackgroundTaskPermissionHelper.requestBatteryOptimizationExemption();
    }
  }

  @override
  Future<void> openSettings() => handler.openAppSettings();
}
