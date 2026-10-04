class AppConfig {
  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'prod',
  );

  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://photo-manager-pro.com',
  );

  /// Shows favorites and album covers. Off until the backend of
  /// `feature/favoritas-portadas` is deployed (see `config/*.json`).
  static const bool favoritesAndCoversEnabled = bool.fromEnvironment(
    'FAVORITES_AND_COVERS_ENABLED',
    defaultValue: false,
  );

  static const bool isProduction = env == 'prod';
  static const bool isDevelopment = env == 'dev';
}
