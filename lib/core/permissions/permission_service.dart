import 'package:photo_manager_app/core/permissions/app_permission.dart';

/// Checks and requests device permissions without any UI of its own.
abstract class PermissionService {
  /// Whether [permission] is granted right now.
  Future<bool> isGranted(AppPermission permission);

  /// Shows the system prompt for [permission]; returns whether it was granted.
  Future<bool> request(AppPermission permission);

  /// Opens the system settings of the app.
  Future<void> openSettings();
}
