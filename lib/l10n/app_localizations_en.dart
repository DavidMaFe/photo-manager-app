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
  String get welcome => 'Welcome';

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
  String get forgotPassword => 'Forgot your password?';

  @override
  String get notHaveAccount => 'You don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get syncSessionTitle => 'Synchronization';

  @override
  String get syncSessionInit => 'Starting synchronization...';

  @override
  String get syncSessionConnecting => 'Connecting with the server';

  @override
  String get syncSessionFetchingFiles => 'Fetching files from the gallery...';

  @override
  String get syncSessionWaitWarning => 'This may take a few seconds';

  @override
  String get syncSessionUploadingFiles => 'Uploading files...';

  @override
  String syncSessionFiles(Object totalFiles, Object uploadedFiles) {
    return '$uploadedFiles/$totalFiles files';
  }

  @override
  String get syncSessionCancel => 'Cancel synchronization';

  @override
  String get syncSessionCancelWarning => 'Cancel synchronization?';

  @override
  String get syncSessionCancelDescription => 'The current progress will be lost. The files uploaded will remain in the server.';

  @override
  String get syncSessionCancelShortDescription => 'The synchronization is in progress. You want to cancel?';

  @override
  String get syncSessionCancelConfirm => 'Yes, cancel';

  @override
  String get syncSessionCompleting => 'Completing synchronization...';

  @override
  String get syncSessionSave => 'Saving information';

  @override
  String get syncSessionCompleted => 'Synchronization completed';

  @override
  String get syncSessionFinished => 'Synchronization finished';

  @override
  String get syncSessionError => 'Error in the synchronization';

  @override
  String get total => 'Total';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get failed => 'Failed';

  @override
  String infoFiles(Object info) {
    return '$info files';
  }

  @override
  String get goBack => 'Return';

  @override
  String get errorLoadingProfile => 'Error loading the profile';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

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

  @override
  String get errorUnknownTitle => 'Unknown Error';

  @override
  String get errorUnknown => 'An unexpected error ocurred. Please, try again later.';

  @override
  String get errorNetworkTitle => 'Connection Error';

  @override
  String get errorNetwork => 'No internet connection. Check your connection and try again.';

  @override
  String get errorServerTitle => 'Server Error';

  @override
  String get errorServer => 'Server error. Please, try again later.';

  @override
  String get errorTimeout => 'The operation took too long. Please, try again.';

  @override
  String get errorUnauthorizedTitle => 'Unauthorized';

  @override
  String get errorUnauthorized => 'You are not authorized. Please, log in.';

  @override
  String get errorInvalidCredentials => 'Invalid email or password.';

  @override
  String get errorTokenExpired => 'Your session has expired. Please log in again.';

  @override
  String get errorValidationTitle => 'Invalid Data';

  @override
  String get errorValidation => 'The provided data is invalid.';

  @override
  String get errorInvalidEmail => 'The email format is invalid.';

  @override
  String get errorPasswordMismatch => 'Passwords do not match.';

  @override
  String errorRequiredField(Object fieldName) {
    return 'The $fieldName field is required.';
  }

  @override
  String get errorNotFoundTitle => 'Not Found';

  @override
  String get errorNotFound => 'The requested resource was not found.';

  @override
  String get errorAlreadyExists => 'The resource already exists.';

  @override
  String get errorEmailAlreadyExists => 'This email is already registered.';

  @override
  String get errorCache => 'Error accessing local data.';

  @override
  String get errorStorageSpaceExceededTitle => 'Storage Full';

  @override
  String get errorStorageSpaceExceeded => 'You have exceeded your personal storage limit.';

  @override
  String get errorPermissionDenied => 'You do not have permission to perform this action.';

  @override
  String errorCode(Object code) {
    return 'Error code: $code';
  }

  @override
  String get errorEmailRequired => 'Please enter an email address';

  @override
  String get errorPasswordRequired => 'Please enter a password';
}
