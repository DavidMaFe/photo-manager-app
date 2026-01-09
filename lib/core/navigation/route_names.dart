

class RouteNames {
  // Auth
  static const String login = 'login';
  static const String register = 'register';
  static const String requestPasswordReset = 'request_password_reset';
  static const String validateResetCode = 'validate_reset_code';
  static const String resetPassword = 'reset_password';

  // Main
  static const String shell = 'shell';
  static const String home = 'home';
  static const String fileDetail = 'fileDetail';
  static const String folders = 'folders';
  static const String folderContent = 'folder_content';
  static const String fileDetailFromFolder = 'file_detail_from_folder';
  static const String sync = 'sync';
  static const String notifications = 'notifications';
  static const String profile = 'profile';
}


class RoutePaths {
  static const String login = '/login';
  static const String register = '/register';
  static const String requestPasswordReset = '/request-password-reset';
  static const String validateResetCode = '/validate-reset-code';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String fileDetail = '/home/file/:fileId';
  static const String folders = '/folders';
  static const String sync = '/sync';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
}