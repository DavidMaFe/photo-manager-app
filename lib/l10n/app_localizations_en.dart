// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'File Manager';

  @override
  String get loginTitle => 'Login';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailPlaceholder => 'your@email.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get logoutButton => 'Sign Out';

  @override
  String get logoutConfirmation => 'Are you sure to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get notHaveAccount => 'You don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get invalidEmail => 'Invalid email format';

  @override
  String get emptyField => 'This field cannot be empty';

  @override
  String get welcome => 'Welcome';

  @override
  String welcomeMessage(Object userName) {
    return 'Hello $userName, welcome';
  }

  @override
  String get errorLoadingProfile => 'Error loading the profile';

  @override
  String get tryAgain => 'Try again';

  @override
  String get storage => 'Storage';

  @override
  String get files => 'Files';

  @override
  String get folders => 'Folders';

  @override
  String get devices => 'Devices';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get editProfileSubtitle => 'Change name and surname';

  @override
  String get myDevices => 'My devices';

  @override
  String myDevicesSubtitle(Object devices) {
    return '$devices linked devices';
  }

  @override
  String get syncSettings => 'Sync Settings';

  @override
  String get syncSettingsSubtitle => 'Auto sync every 6 hours';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Manage notifications';
}
