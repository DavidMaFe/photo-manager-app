class AppConfig {
  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'prod',
  );

  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://photo-manager-pro.com',
  );

  static const bool isProduction = env == 'prod';
  static const bool isDevelopment = env == 'dev';
}
