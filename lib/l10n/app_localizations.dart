import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'File Manager'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailPlaceholder;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logoutButton;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to logout?'**
  String get logoutConfirmation;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @notHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have an account? '**
  String get notHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @pendingFilesInfoSingle.
  ///
  /// In en, this message translates to:
  /// **'You have 1 file pending to manage'**
  String get pendingFilesInfoSingle;

  /// No description provided for @pendingFilesInfo.
  ///
  /// In en, this message translates to:
  /// **'You have {files} files pending to manage'**
  String pendingFilesInfo(Object files);

  /// No description provided for @noFiles.
  ///
  /// In en, this message translates to:
  /// **'There is no files to show'**
  String get noFiles;

  /// No description provided for @syncToHaveFiles.
  ///
  /// In en, this message translates to:
  /// **'Synchronize your devices to see your files'**
  String get syncToHaveFiles;

  /// No description provided for @syncSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Synchronization'**
  String get syncSessionTitle;

  /// No description provided for @syncSessionInit.
  ///
  /// In en, this message translates to:
  /// **'Starting synchronization...'**
  String get syncSessionInit;

  /// No description provided for @syncSessionConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting with the server'**
  String get syncSessionConnecting;

  /// No description provided for @syncSessionFetchingFiles.
  ///
  /// In en, this message translates to:
  /// **'Fetching files from the gallery...'**
  String get syncSessionFetchingFiles;

  /// No description provided for @syncSessionWaitWarning.
  ///
  /// In en, this message translates to:
  /// **'This may take a few seconds'**
  String get syncSessionWaitWarning;

  /// No description provided for @syncSessionUploadingFiles.
  ///
  /// In en, this message translates to:
  /// **'Uploading files...'**
  String get syncSessionUploadingFiles;

  /// No description provided for @syncSessionFiles.
  ///
  /// In en, this message translates to:
  /// **'{uploadedFiles}/{totalFiles} files'**
  String syncSessionFiles(Object totalFiles, Object uploadedFiles);

  /// No description provided for @syncSessionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel synchronization'**
  String get syncSessionCancel;

  /// No description provided for @syncSessionCancelWarning.
  ///
  /// In en, this message translates to:
  /// **'Cancel synchronization?'**
  String get syncSessionCancelWarning;

  /// No description provided for @syncSessionCancelDescription.
  ///
  /// In en, this message translates to:
  /// **'The current progress will be lost. The files uploaded will remain in the server.'**
  String get syncSessionCancelDescription;

  /// No description provided for @syncSessionCancelShortDescription.
  ///
  /// In en, this message translates to:
  /// **'The synchronization is in progress. You want to cancel?'**
  String get syncSessionCancelShortDescription;

  /// No description provided for @syncSessionCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel'**
  String get syncSessionCancelConfirm;

  /// No description provided for @syncSessionCompleting.
  ///
  /// In en, this message translates to:
  /// **'Completing synchronization...'**
  String get syncSessionCompleting;

  /// No description provided for @syncSessionSave.
  ///
  /// In en, this message translates to:
  /// **'Saving information'**
  String get syncSessionSave;

  /// No description provided for @syncSessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Synchronization completed'**
  String get syncSessionCompleted;

  /// No description provided for @syncSessionFinished.
  ///
  /// In en, this message translates to:
  /// **'Synchronization finished'**
  String get syncSessionFinished;

  /// No description provided for @syncSessionError.
  ///
  /// In en, this message translates to:
  /// **'Error in the synchronization'**
  String get syncSessionError;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @infoFiles.
  ///
  /// In en, this message translates to:
  /// **'{info} files'**
  String infoFiles(Object info);

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get goBack;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading the profile'**
  String get errorLoadingProfile;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change name and surname'**
  String get editProfileSubtitle;

  /// No description provided for @myDevices.
  ///
  /// In en, this message translates to:
  /// **'My devices'**
  String get myDevices;

  /// No description provided for @myDevicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{devices} linked devices'**
  String myDevicesSubtitle(Object devices);

  /// No description provided for @syncSettings.
  ///
  /// In en, this message translates to:
  /// **'Sync Settings'**
  String get syncSettings;

  /// No description provided for @syncSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto sync every 6 hours'**
  String get syncSettingsSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get notificationsSubtitle;

  /// No description provided for @errorUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown Error'**
  String get errorUnknownTitle;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error ocurred. Please, try again later.'**
  String get errorUnknown;

  /// No description provided for @errorNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get errorNetworkTitle;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get errorServerTitle;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please, try again later.'**
  String get errorServer;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The operation took too long. Please, try again.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get errorUnauthorizedTitle;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized. Please, log in.'**
  String get errorUnauthorized;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorTokenExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get errorTokenExpired;

  /// No description provided for @errorValidationTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid Data'**
  String get errorValidationTitle;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'The provided data is invalid.'**
  String get errorValidation;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email format is invalid.'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errorPasswordMismatch;

  /// No description provided for @errorRequiredField.
  ///
  /// In en, this message translates to:
  /// **'The {fieldName} field is required.'**
  String errorRequiredField(Object fieldName);

  /// No description provided for @errorNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get errorNotFoundTitle;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested resource was not found.'**
  String get errorNotFound;

  /// No description provided for @errorAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'The resource already exists.'**
  String get errorAlreadyExists;

  /// No description provided for @errorEmailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get errorEmailAlreadyExists;

  /// No description provided for @errorCache.
  ///
  /// In en, this message translates to:
  /// **'Error accessing local data.'**
  String get errorCache;

  /// No description provided for @errorStorageSpaceExceededTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage Full'**
  String get errorStorageSpaceExceededTitle;

  /// No description provided for @errorStorageSpaceExceeded.
  ///
  /// In en, this message translates to:
  /// **'You have exceeded your personal storage limit.'**
  String get errorStorageSpaceExceeded;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this action.'**
  String get errorPermissionDenied;

  /// No description provided for @errorCode.
  ///
  /// In en, this message translates to:
  /// **'Error code: {code}'**
  String errorCode(Object code);

  /// No description provided for @errorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address'**
  String get errorEmailRequired;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get errorPasswordRequired;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
