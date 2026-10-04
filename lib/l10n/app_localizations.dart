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
  /// **'Sign out'**
  String get logoutButton;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logoutConfirmation;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot it?'**
  String get forgotPassword;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created! Please sign in'**
  String get accountCreated;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @namePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'John'**
  String get namePlaceholder;

  /// No description provided for @surnamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Doe'**
  String get surnamePlaceholder;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @errorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get errorNameRequired;

  /// No description provided for @errorConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get errorConfirmPasswordRequired;

  /// No description provided for @errorPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordsDoNotMatch;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @registerTermsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our Terms and Conditions'**
  String get registerTermsDisclaimer;

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

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @noDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get noDate;

  /// No description provided for @noFiles.
  ///
  /// In en, this message translates to:
  /// **'There is no files to show'**
  String get noFiles;

  /// No description provided for @selectionLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You can only select up to 100 files at a time.'**
  String get selectionLimitReached;

  /// No description provided for @newFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'New album'**
  String get newFolderTitle;

  /// No description provided for @partialManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Partial management'**
  String get partialManageTitle;

  /// No description provided for @filesRemovedFromServerLocalMayRemain.
  ///
  /// In en, this message translates to:
  /// **'Some files may still exist on this device if they were uploaded from another device.'**
  String get filesRemovedFromServerLocalMayRemain;

  /// No description provided for @filesManaged.
  ///
  /// In en, this message translates to:
  /// **'Files Managed'**
  String get filesManaged;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show this again'**
  String get dontShowAgain;

  /// No description provided for @correctManage.
  ///
  /// In en, this message translates to:
  /// **'{files} files were managed successfully'**
  String correctManage(Object files);

  /// No description provided for @failedManage.
  ///
  /// In en, this message translates to:
  /// **'{files} files failed'**
  String failedManage(Object files);

  /// No description provided for @fileTypeNotSupported.
  ///
  /// In en, this message translates to:
  /// **'File type not supported'**
  String get fileTypeNotSupported;

  /// No description provided for @fileProperties.
  ///
  /// In en, this message translates to:
  /// **'File properties'**
  String get fileProperties;

  /// No description provided for @filePropertyTypeImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get filePropertyTypeImage;

  /// No description provided for @filePropertyTypeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get filePropertyTypeVideo;

  /// No description provided for @filePropertyStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filePropertyStatus;

  /// No description provided for @filePropertyCapturedAt.
  ///
  /// In en, this message translates to:
  /// **'Captured at'**
  String get filePropertyCapturedAt;

  /// No description provided for @filePropertyDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get filePropertyDuration;

  /// No description provided for @loadingVideoError.
  ///
  /// In en, this message translates to:
  /// **'Error loading the video'**
  String get loadingVideoError;

  /// No description provided for @folder.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get folder;

  /// No description provided for @subfolders.
  ///
  /// In en, this message translates to:
  /// **'Sub-albums'**
  String get subfolders;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Album name'**
  String get folderName;

  /// No description provided for @hintFolderName.
  ///
  /// In en, this message translates to:
  /// **'Ex: Holidays 2024'**
  String get hintFolderName;

  /// No description provided for @folderNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Album name is required'**
  String get folderNameRequiredError;

  /// No description provided for @folderMaxHundredCharactersError.
  ///
  /// In en, this message translates to:
  /// **'Max 100 characters'**
  String get folderMaxHundredCharactersError;

  /// No description provided for @renameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename album'**
  String get renameFolder;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get newName;

  /// No description provided for @creatingFolder.
  ///
  /// In en, this message translates to:
  /// **'Creating album...'**
  String get creatingFolder;

  /// No description provided for @renamingFolder.
  ///
  /// In en, this message translates to:
  /// **'Renaming album...'**
  String get renamingFolder;

  /// No description provided for @deletingFolder.
  ///
  /// In en, this message translates to:
  /// **'Deleting album...'**
  String get deletingFolder;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @emptyFolders.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have albums'**
  String get emptyFolders;

  /// No description provided for @emptyFolder.
  ///
  /// In en, this message translates to:
  /// **'This album is empty'**
  String get emptyFolder;

  /// No description provided for @emptyFolderDescription.
  ///
  /// In en, this message translates to:
  /// **'Move photos here to organise them'**
  String get emptyFolderDescription;

  /// No description provided for @createFirstFolder.
  ///
  /// In en, this message translates to:
  /// **'Create your first album to organise your photos'**
  String get createFirstFolder;

  /// No description provided for @deleteFolder.
  ///
  /// In en, this message translates to:
  /// **'Delete album'**
  String get deleteFolder;

  /// No description provided for @deleteEmptyFolder.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the album {folderName}?'**
  String deleteEmptyFolder(Object folderName);

  /// No description provided for @deleteFolderWithFiles.
  ///
  /// In en, this message translates to:
  /// **'The album {folderName} contains {files} files. Are you sure you want to delete all its content?'**
  String deleteFolderWithFiles(Object files, Object folderName);

  /// No description provided for @deleteFolderWithSubfolders.
  ///
  /// In en, this message translates to:
  /// **'The album {folderName} contains {subfolders} sub-albums. Are you sure you want to delete all its content?'**
  String deleteFolderWithSubfolders(Object folderName, Object subfolders);

  /// No description provided for @deleteFolderWithFilesAndSubfoldersWarning.
  ///
  /// In en, this message translates to:
  /// **'The album {folderName} contains {files} files and {subfolders} sub-albums. Are you sure you want to delete all its content?'**
  String deleteFolderWithFilesAndSubfoldersWarning(Object files, Object folderName, Object subfolders);

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

  /// No description provided for @syncSessionCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel'**
  String get syncSessionCancelConfirm;

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
  /// **'Albums'**
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

  /// No description provided for @myDevices.
  ///
  /// In en, this message translates to:
  /// **'My devices'**
  String get myDevices;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @trashIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get trashIsEmpty;

  /// No description provided for @trashEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Deleted files will appear here and be permanently deleted after 30 days'**
  String get trashEmptyDescription;

  /// No description provided for @emptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get emptyTrash;

  /// No description provided for @emptyTrashConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete all files in trash? This action cannot be undone.'**
  String get emptyTrashConfirmation;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreFiles.
  ///
  /// In en, this message translates to:
  /// **'Restore {count} files'**
  String restoreFiles(Object count);

  /// No description provided for @restoreFileConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to restore this file to its original location?'**
  String get restoreFileConfirmation;

  /// No description provided for @restoreFilesConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to restore {count} files to their original locations?'**
  String restoreFilesConfirmation(Object count);

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @deletePermanentlyConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this file? This action cannot be undone.'**
  String get deletePermanentlyConfirmation;

  /// No description provided for @deleteFilesPermanentlyConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete {count} files? This action cannot be undone.'**
  String deleteFilesPermanentlyConfirmation(Object count);

  /// No description provided for @filesRestoredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{count} files restored successfully'**
  String filesRestoredSuccessfully(Object count);

  /// No description provided for @filesDeletedPermanently.
  ///
  /// In en, this message translates to:
  /// **'{count} files permanently deleted'**
  String filesDeletedPermanently(Object count);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @permissionPhotoAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Access'**
  String get permissionPhotoAccessTitle;

  /// No description provided for @permissionPhotoAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'This app needs access to your photos to sync and manage your gallery. Your photos will remain private and secure.'**
  String get permissionPhotoAccessMessage;

  /// No description provided for @permissionPhotoAccessContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get permissionPhotoAccessContinue;

  /// No description provided for @permissionPhotoAccessDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionPhotoAccessDeniedTitle;

  /// No description provided for @permissionPhotoAccessDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'We can\'t access your photos without permission. Please enable photo access in Settings to use this feature.'**
  String get permissionPhotoAccessDeniedMessage;

  /// No description provided for @permissionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get permissionOpenSettings;

  /// No description provided for @timeLessThanAMinute.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeLessThanAMinute;

  /// No description provided for @timeOneMinute.
  ///
  /// In en, this message translates to:
  /// **'1 minute ago'**
  String get timeOneMinute;

  /// No description provided for @timeMoreThanOneMinute.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String timeMoreThanOneMinute(Object minutes);

  /// No description provided for @timeOneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get timeOneHour;

  /// No description provided for @timeMoreThanOneHour.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String timeMoreThanOneHour(Object hours);

  /// No description provided for @timeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday at {hour}'**
  String timeYesterday(Object hour);

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

  /// No description provided for @sendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCodeButton;

  /// No description provided for @emailSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Code sent to your email'**
  String get emailSentSuccess;

  /// No description provided for @validateCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get validateCodeButton;

  /// No description provided for @resendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCodeButton;

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'Code resent successfully'**
  String get codeResent;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordLabel;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get resetPasswordButton;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get passwordResetSuccess;

  /// No description provided for @errorNewPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get errorNewPasswordRequired;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @currentPasswordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your current password'**
  String get currentPasswordPlaceholder;

  /// No description provided for @errorCurrentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get errorCurrentPasswordRequired;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChangedSuccessfully;

  /// No description provided for @selectProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Select profile photo'**
  String get selectProfilePhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @passwordSection.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get passwordSection;

  /// No description provided for @leavePasswordEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Leave it blank if you don\'t want to change it'**
  String get leavePasswordEmptyHint;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @renameDevice.
  ///
  /// In en, this message translates to:
  /// **'Rename device'**
  String get renameDevice;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get deviceName;

  /// No description provided for @deviceNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Device name is required'**
  String get deviceNameRequired;

  /// No description provided for @deviceNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name is too long (maximum 50 characters)'**
  String get deviceNameTooLong;

  /// No description provided for @autoSync.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup'**
  String get autoSync;

  /// No description provided for @unlinkDevice.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get unlinkDevice;

  /// No description provided for @unlinkDeviceConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unlink \'{deviceName}\'? This device will stop syncing with your account.'**
  String unlinkDeviceConfirmation(Object deviceName);

  /// No description provided for @deviceActionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get deviceActionSuccess;

  /// No description provided for @noDevices.
  ///
  /// In en, this message translates to:
  /// **'No linked devices'**
  String get noDevices;

  /// No description provided for @noDevicesDescription.
  ///
  /// In en, this message translates to:
  /// **'Devices will appear here when you sign in to the app from other devices.'**
  String get noDevicesDescription;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @autoSyncEnabled.
  ///
  /// In en, this message translates to:
  /// **'Automatic sync is enabled'**
  String get autoSyncEnabled;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @notifyOnSuccess.
  ///
  /// In en, this message translates to:
  /// **'Notify when sync is successful'**
  String get notifyOnSuccess;

  /// No description provided for @notifyOnFailure.
  ///
  /// In en, this message translates to:
  /// **'Notify when sync fails'**
  String get notifyOnFailure;

  /// No description provided for @configurationSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get configurationSaved;

  /// No description provided for @loadingConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Loading configuration...'**
  String get loadingConfiguration;

  /// No description provided for @configurationLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading configuration'**
  String get configurationLoadError;

  /// No description provided for @onboardingPermissionsRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Some Permissions Were Not Granted'**
  String get onboardingPermissionsRejectedTitle;

  /// No description provided for @onboardingPermissionsRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have denied some required permissions. The app will work with limited functionality. You can enable these permissions later from the app settings:'**
  String get onboardingPermissionsRejectedMessage;

  /// No description provided for @permissionLimitationPhoto.
  ///
  /// In en, this message translates to:
  /// **'• You won\'t be able to sync photos or videos'**
  String get permissionLimitationPhoto;

  /// No description provided for @permissionLimitationNotification.
  ///
  /// In en, this message translates to:
  /// **'• You won\'t receive notifications about syncs'**
  String get permissionLimitationNotification;

  /// No description provided for @permissionLimitationBackground.
  ///
  /// In en, this message translates to:
  /// **'• Automatic sync will only work with the app open'**
  String get permissionLimitationBackground;

  /// No description provided for @loginGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginGreeting;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see and organise your photos.'**
  String get loginSubtitle;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet?'**
  String get noAccountYet;

  /// No description provided for @createAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountLink;

  /// No description provided for @registerHeadline.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerHeadline;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Back up your photos and free up space on your phone.'**
  String get registerSubtitle;

  /// No description provided for @surnameShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get surnameShortLabel;

  /// No description provided for @optionalLabel.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optionalLabel;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @forgotPasswordHeadline.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordHeadline;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a code to create a new one.'**
  String get forgotPasswordBody;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit code to {email}'**
  String codeSentTo(String email);

  /// No description provided for @didNotReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it?'**
  String get didNotReceiveCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {time}'**
  String resendIn(String time);

  /// No description provided for @newPasswordHeadline.
  ///
  /// In en, this message translates to:
  /// **'Create a new password'**
  String get newPasswordHeadline;

  /// No description provided for @newPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Use one you haven\'t used before on this account.'**
  String get newPasswordBody;

  /// No description provided for @navPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get navPhotos;

  /// No description provided for @backupUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get backupUpToDate;

  /// No description provided for @backupInProgress.
  ///
  /// In en, this message translates to:
  /// **'Backing up {percent}%'**
  String backupInProgress(int percent);

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get backupFailed;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterToReview.
  ///
  /// In en, this message translates to:
  /// **'To review'**
  String get filterToReview;

  /// No description provided for @toReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item to review} other{{count} items to review}}'**
  String toReviewTitle(int count);

  /// No description provided for @toReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Decide whether to keep them or free up space on your phone'**
  String get toReviewBody;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String selectedCount(int count);

  /// No description provided for @selectAllShort.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get selectAllShort;

  /// No description provided for @selectNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get selectNone;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get noPhotosYet;

  /// No description provided for @noPhotosBody.
  ///
  /// In en, this message translates to:
  /// **'Back up your phone to see them here'**
  String get noPhotosBody;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backupNow;

  /// No description provided for @openProfile.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get openProfile;

  /// No description provided for @closeSelection.
  ///
  /// In en, this message translates to:
  /// **'Exit selection'**
  String get closeSelection;

  /// No description provided for @dayAndTime.
  ///
  /// In en, this message translates to:
  /// **'{day}, {time}'**
  String dayAndTime(String day, String time);

  /// No description provided for @viewerInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get viewerInfo;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @deleteFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this file?'**
  String get deleteFileTitle;

  /// No description provided for @deleteFileBody.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from your cloud and this phone. You can restore it from the trash for 30 days.'**
  String get deleteFileBody;

  /// No description provided for @copyId.
  ///
  /// In en, this message translates to:
  /// **'Copy ID'**
  String get copyId;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copiedToClipboard;

  /// No description provided for @statusSafe.
  ///
  /// In en, this message translates to:
  /// **'Backed up'**
  String get statusSafe;

  /// No description provided for @navAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get navAlbums;

  /// No description provided for @searchAlbums.
  ///
  /// In en, this message translates to:
  /// **'Search albums'**
  String get searchAlbums;

  /// No description provided for @newAlbum.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newAlbum;

  /// No description provided for @createAlbum.
  ///
  /// In en, this message translates to:
  /// **'Create album'**
  String get createAlbum;

  /// No description provided for @albumMeta.
  ///
  /// In en, this message translates to:
  /// **'{count} · {subcount, plural, =1{1 sub-album} other{{subcount} sub-albums}}'**
  String albumMeta(int count, int subcount);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Empty} =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// No description provided for @subalbum.
  ///
  /// In en, this message translates to:
  /// **'Sub-album'**
  String get subalbum;

  /// No description provided for @newSubalbum.
  ///
  /// In en, this message translates to:
  /// **'New sub-album'**
  String get newSubalbum;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @noAlbumsMatch.
  ///
  /// In en, this message translates to:
  /// **'No album matches “{query}”'**
  String noAlbumsMatch(String query);

  /// No description provided for @navBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get navBackup;

  /// No description provided for @allSafe.
  ///
  /// In en, this message translates to:
  /// **'All backed up'**
  String get allSafe;

  /// No description provided for @lastBackupMeta.
  ///
  /// In en, this message translates to:
  /// **'Last backup {when} · {count, plural, =1{1 item} other{{count} items}}'**
  String lastBackupMeta(String when, int count);

  /// No description provided for @copyingNofM.
  ///
  /// In en, this message translates to:
  /// **'Backing up {done} of {total}'**
  String copyingNofM(int done, int total);

  /// No description provided for @backupIncomplete.
  ///
  /// In en, this message translates to:
  /// **'The last backup didn\'t finish'**
  String get backupIncomplete;

  /// No description provided for @backupIncompleteMeta.
  ///
  /// In en, this message translates to:
  /// **'{when} · {count, plural, =1{1 failure} other{{count} failures}}'**
  String backupIncompleteMeta(String when, int count);

  /// No description provided for @noBackupsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t backed up yet'**
  String get noBackupsYet;

  /// No description provided for @noBackupsBody.
  ///
  /// In en, this message translates to:
  /// **'Save your photos to the cloud and free up space on your phone.'**
  String get noBackupsBody;

  /// No description provided for @backupCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'The last backup was cancelled'**
  String get backupCancelledTitle;

  /// No description provided for @condDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily · {time}'**
  String condDaily(String time);

  /// No description provided for @condWeekly.
  ///
  /// In en, this message translates to:
  /// **'{day} · {time}'**
  String condWeekly(String day, String time);

  /// No description provided for @condWifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi only'**
  String get condWifi;

  /// No description provided for @condAnyNetwork.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi and data'**
  String get condAnyNetwork;

  /// No description provided for @condBattery.
  ///
  /// In en, this message translates to:
  /// **'Charging or >15%'**
  String get condBattery;

  /// No description provided for @autoBackupOff.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup off'**
  String get autoBackupOff;

  /// No description provided for @backupSettings.
  ///
  /// In en, this message translates to:
  /// **'Backup settings'**
  String get backupSettings;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @itemsSaved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item saved} other{{count} items saved}}'**
  String itemsSaved(int count);

  /// No description provided for @incompleteWithFailures.
  ///
  /// In en, this message translates to:
  /// **'Incomplete backup · {count, plural, =1{1 failure} other{{count} failures}}'**
  String incompleteWithFailures(int count);

  /// No description provided for @backupCancelled.
  ///
  /// In en, this message translates to:
  /// **'Backup cancelled'**
  String get backupCancelled;

  /// No description provided for @backupRunning.
  ///
  /// In en, this message translates to:
  /// **'Backup in progress'**
  String get backupRunning;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @storageOf.
  ///
  /// In en, this message translates to:
  /// **'{used} of {total}'**
  String storageOf(String used, String total);

  /// No description provided for @elementsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{item} other{items}}'**
  String elementsLabel(int count);

  /// No description provided for @albumsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{album} other{albums}}'**
  String albumsLabel(int count);

  /// No description provided for @devicesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{device} other{devices}}'**
  String devicesLabel(int count);

  /// No description provided for @sectionBackupSpace.
  ///
  /// In en, this message translates to:
  /// **'Backup and space'**
  String get sectionBackupSpace;

  /// No description provided for @sectionApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get sectionApp;

  /// No description provided for @dailyAt.
  ///
  /// In en, this message translates to:
  /// **'Daily at {time}'**
  String dailyAt(String time);

  /// No description provided for @weeklyAt.
  ///
  /// In en, this message translates to:
  /// **'{day} at {time}'**
  String weeklyAt(String day, String time);

  /// No description provided for @linkedDevices.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None linked} =1{1 linked} other{{count} linked}}'**
  String linkedDevices(int count);

  /// No description provided for @trashAutoEmpty.
  ///
  /// In en, this message translates to:
  /// **'Emptied after 30 days'**
  String get trashAutoEmpty;

  /// No description provided for @notifOnlyFailures.
  ///
  /// In en, this message translates to:
  /// **'Failures only'**
  String get notifOnlyFailures;

  /// No description provided for @notifOnlySuccess.
  ///
  /// In en, this message translates to:
  /// **'Finished only'**
  String get notifOnlySuccess;

  /// No description provided for @notifAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notifAll;

  /// No description provided for @notifOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get notifOff;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get sectionData;

  /// No description provided for @sectionPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get sectionPassword;

  /// No description provided for @gallerySource.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallerySource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This phone'**
  String get thisDevice;

  /// No description provided for @emptyTrashShort.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get emptyTrashShort;

  /// No description provided for @trashInfo.
  ///
  /// In en, this message translates to:
  /// **'Items are deleted forever after 30 days. Long-press to restore several.'**
  String get trashInfo;

  /// No description provided for @deletingSoon.
  ///
  /// In en, this message translates to:
  /// **'Deleted soon'**
  String get deletingSoon;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Today} =1{1 day} other{{count} days}}'**
  String daysLeft(int count);

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get deleteForever;

  /// No description provided for @deletesIn.
  ///
  /// In en, this message translates to:
  /// **'Deleted in {time}'**
  String deletesIn(String time);

  /// No description provided for @selectedItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String selectedItems(int count);

  /// No description provided for @autoBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Your new photos are saved automatically'**
  String get autoBackupBody;

  /// No description provided for @sectionWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get sectionWhen;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @oncePerWeek.
  ///
  /// In en, this message translates to:
  /// **'Once a week'**
  String get oncePerWeek;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @nextBackup.
  ///
  /// In en, this message translates to:
  /// **'Next backup: {when}'**
  String nextBackup(String when);

  /// No description provided for @sectionConditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get sectionConditions;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @always.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get always;

  /// No description provided for @sectionAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get sectionAlerts;

  /// No description provided for @alertSuccess.
  ///
  /// In en, this message translates to:
  /// **'When it finishes'**
  String get alertSuccess;

  /// No description provided for @alertSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'A notice with what was saved'**
  String get alertSuccessBody;

  /// No description provided for @alertFailure.
  ///
  /// In en, this message translates to:
  /// **'If something fails'**
  String get alertFailure;

  /// No description provided for @alertFailureBody.
  ///
  /// In en, this message translates to:
  /// **'So you can retry it'**
  String get alertFailureBody;

  /// No description provided for @sectionDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get sectionDiagnostics;

  /// No description provided for @manageQuestion.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{What should we do with this photo?} other{What should we do with these {count} photos?}}'**
  String manageQuestion(int count);

  /// No description provided for @photosSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo selected} other{{count} photos selected}}'**
  String photosSelected(int count);

  /// No description provided for @photosCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String photosCount(int count);

  /// No description provided for @optSaveFree.
  ///
  /// In en, this message translates to:
  /// **'Save and free up space'**
  String get optSaveFree;

  /// No description provided for @optSaveFreeBody.
  ///
  /// In en, this message translates to:
  /// **'They\'re saved to your cloud and removed from the phone.'**
  String get optSaveFreeBody;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @optSaveKeep.
  ///
  /// In en, this message translates to:
  /// **'Save and keep on the phone'**
  String get optSaveKeep;

  /// No description provided for @optSaveKeepBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll have a copy in the cloud and another one here.'**
  String get optSaveKeepBody;

  /// No description provided for @optAlbum.
  ///
  /// In en, this message translates to:
  /// **'Save to an album'**
  String get optAlbum;

  /// No description provided for @optAlbumBody.
  ///
  /// In en, this message translates to:
  /// **'Pick an existing one or create a new one.'**
  String get optAlbumBody;

  /// No description provided for @newAlbumChip.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newAlbumChip;

  /// No description provided for @deleteAfterSaving.
  ///
  /// In en, this message translates to:
  /// **'Remove from the phone afterwards'**
  String get deleteAfterSaving;

  /// No description provided for @deleteEverywhere.
  ///
  /// In en, this message translates to:
  /// **'Delete everywhere'**
  String get deleteEverywhere;

  /// No description provided for @saveToAlbum.
  ///
  /// In en, this message translates to:
  /// **'Save to {album}'**
  String saveToAlbum(String album);

  /// No description provided for @chooseAlbum.
  ///
  /// In en, this message translates to:
  /// **'Choose an album'**
  String get chooseAlbum;

  /// No description provided for @actionToAlbum.
  ///
  /// In en, this message translates to:
  /// **'To album'**
  String get actionToAlbum;

  /// No description provided for @actionFreeUp.
  ///
  /// In en, this message translates to:
  /// **'Free up'**
  String get actionFreeUp;

  /// No description provided for @freeUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Free up space on the phone?'**
  String get freeUpTitle;

  /// No description provided for @freeUpBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The photo will be saved to your cloud and removed from this phone.} other{The {count} photos will be saved to your cloud and removed from this phone.}}'**
  String freeUpBody(int count);

  /// No description provided for @deleteFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete this photo?} other{Delete {count} photos?}}'**
  String deleteFilesTitle(int count);

  /// No description provided for @deleteFilesBody.
  ///
  /// In en, this message translates to:
  /// **'They\'ll be removed from your cloud and this phone. You can restore them from the trash for 30 days.'**
  String get deleteFilesBody;

  /// No description provided for @preparingBackup.
  ///
  /// In en, this message translates to:
  /// **'Preparing the backup…'**
  String get preparingBackup;

  /// No description provided for @lookingForPhotos.
  ///
  /// In en, this message translates to:
  /// **'Looking for new photos'**
  String get lookingForPhotos;

  /// No description provided for @finishingBackup.
  ///
  /// In en, this message translates to:
  /// **'Finishing the backup…'**
  String get finishingBackup;

  /// No description provided for @cancellingBackup.
  ///
  /// In en, this message translates to:
  /// **'Cancelling…'**
  String get cancellingBackup;

  /// No description provided for @remainingMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{About 1 min left} other{About {count} min left}}'**
  String remainingMinutes(int count);

  /// No description provided for @remainingLessThanMinute.
  ///
  /// In en, this message translates to:
  /// **'Less than a minute left'**
  String get remainingLessThanMinute;

  /// No description provided for @backgroundInfo.
  ///
  /// In en, this message translates to:
  /// **'You can leave the app: the backup continues in the background and we\'ll let you know when it\'s done.'**
  String get backgroundInfo;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See less'**
  String get seeLess;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeUser(String name);

  /// No description provided for @welcomeGeneric.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeGeneric;

  /// No description provided for @permissionsHeadline.
  ///
  /// In en, this message translates to:
  /// **'Three permissions and we\'re ready'**
  String get permissionsHeadline;

  /// No description provided for @permissionsBody.
  ///
  /// In en, this message translates to:
  /// **'That way we can save your photos automatically and let you know when each backup finishes.'**
  String get permissionsBody;

  /// No description provided for @permPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos'**
  String get permPhotosTitle;

  /// No description provided for @permPhotosBody.
  ///
  /// In en, this message translates to:
  /// **'To back them up and free up space'**
  String get permPhotosBody;

  /// No description provided for @permNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permNotifTitle;

  /// No description provided for @permNotifBody.
  ///
  /// In en, this message translates to:
  /// **'We let you know when it\'s done or if it fails'**
  String get permNotifBody;

  /// No description provided for @permBgTitle.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get permBgTitle;

  /// No description provided for @permBgBody.
  ///
  /// In en, this message translates to:
  /// **'Backups with the app closed'**
  String get permBgBody;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @permSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get permSettings;

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your photos are private. You can change these permissions any time from Profile.'**
  String get privacyNote;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Do it later'**
  String get later;

  /// No description provided for @continueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue anyway'**
  String get continueAnyway;

  /// No description provided for @reviewPermissions.
  ///
  /// In en, this message translates to:
  /// **'Review permissions'**
  String get reviewPermissions;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get themeSystem;

  /// No description provided for @themeSystemHint.
  ///
  /// In en, this message translates to:
  /// **'Follows your phone\'s mode'**
  String get themeSystemHint;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @deviceLastBackup.
  ///
  /// In en, this message translates to:
  /// **'{os} · Last backup {when}'**
  String deviceLastBackup(String os, String when);

  /// No description provided for @photosSelectedSize.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo · {size}} other{{count} photos · {size}}}'**
  String photosSelectedSize(int count, String size);

  /// No description provided for @freeUpSize.
  ///
  /// In en, this message translates to:
  /// **'Free up {size}'**
  String freeUpSize(String size);

  /// No description provided for @filePropertyName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get filePropertyName;

  /// No description provided for @filePropertyUploadedAt.
  ///
  /// In en, this message translates to:
  /// **'Uploaded at'**
  String get filePropertyUploadedAt;

  /// No description provided for @filePropertySize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get filePropertySize;

  /// No description provided for @filePropertyDimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get filePropertyDimensions;

  /// No description provided for @filePropertyAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get filePropertyAlbum;

  /// No description provided for @filePropertyDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get filePropertyDevice;

  /// No description provided for @fileInfoLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading details…'**
  String get fileInfoLoading;

  /// No description provided for @filterFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get filterFavorites;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart while viewing a photo to keep it here'**
  String get favoritesEmptyBody;

  /// No description provided for @favoritesAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Added to favorites} other{{count} added to favorites}}'**
  String favoritesAdded(int count);

  /// No description provided for @favoritesRemoved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Removed from favorites} other{{count} removed from favorites}}'**
  String favoritesRemoved(int count);

  /// No description provided for @favoriteError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update. Please try again.'**
  String get favoriteError;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @cover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get cover;

  /// No description provided for @coverOf.
  ///
  /// In en, this message translates to:
  /// **'Cover of {album}'**
  String coverOf(String album);

  /// No description provided for @coverOfMany.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Cover of 1 album} other{Cover of {count} albums}}'**
  String coverOfMany(int count);

  /// No description provided for @useAsCover.
  ///
  /// In en, this message translates to:
  /// **'Use as cover'**
  String get useAsCover;

  /// No description provided for @useAsCoverBody.
  ///
  /// In en, this message translates to:
  /// **'Tick the albums where you want it to appear. Up to 3 per album.'**
  String get useAsCoverBody;

  /// No description provided for @photoIsHere.
  ///
  /// In en, this message translates to:
  /// **'The photo is here'**
  String get photoIsHere;

  /// No description provided for @photosAreHere.
  ///
  /// In en, this message translates to:
  /// **'The photos are here'**
  String get photosAreHere;

  /// No description provided for @coverAlreadyHint.
  ///
  /// In en, this message translates to:
  /// **'Already a cover · untick to remove it'**
  String get coverAlreadyHint;

  /// No description provided for @coverWillAdd.
  ///
  /// In en, this message translates to:
  /// **'Will be added · {count} of 3'**
  String coverWillAdd(int count);

  /// No description provided for @coverFullChoose.
  ///
  /// In en, this message translates to:
  /// **'Full · choose which to replace'**
  String get coverFullChoose;

  /// No description provided for @coverFullChooseMany.
  ///
  /// In en, this message translates to:
  /// **'Full · choose {count} to replace'**
  String coverFullChooseMany(int count);

  /// No description provided for @coverWillRemove.
  ///
  /// In en, this message translates to:
  /// **'Will be removed from the cover'**
  String get coverWillRemove;

  /// No description provided for @coverCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of 3 covers'**
  String coverCount(int count);

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @replaceCoverOf.
  ///
  /// In en, this message translates to:
  /// **'Replace cover {position} of {album}'**
  String replaceCoverOf(int position, String album);

  /// No description provided for @coverTreeNote.
  ///
  /// In en, this message translates to:
  /// **'Only the photo\'s album and the albums that contain it are shown.'**
  String get coverTreeNote;

  /// No description provided for @saveChangesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Save · 1 change} other{Save · {count} changes}}'**
  String saveChangesCount(int count);

  /// No description provided for @coverUpdated.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Cover updated} other{Cover updated in {count} albums}}'**
  String coverUpdated(int count);

  /// No description provided for @upToThreeCovers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}} · up to 3 can be a cover'**
  String upToThreeCovers(int count);

  /// No description provided for @chooseUpToThree.
  ///
  /// In en, this message translates to:
  /// **'Choose up to 3 photos to use as cover'**
  String get chooseUpToThree;

  /// No description provided for @videosCannotBeCovers.
  ///
  /// In en, this message translates to:
  /// **'Videos can\'t be album covers'**
  String get videosCannotBeCovers;

  /// No description provided for @noSharedAlbum.
  ///
  /// In en, this message translates to:
  /// **'These photos don\'t share an album'**
  String get noSharedAlbum;

  /// No description provided for @inAlbum.
  ///
  /// In en, this message translates to:
  /// **'in {album}'**
  String inAlbum(String album);

  /// No description provided for @albumCoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Cover of {album}'**
  String albumCoverTitle(String album);

  /// No description provided for @albumCoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} of 3 photos · drag to change the order'**
  String albumCoverSubtitle(int count);

  /// No description provided for @albumCoverCard.
  ///
  /// In en, this message translates to:
  /// **'{count} of 3 photos'**
  String albumCoverCard(int count);

  /// No description provided for @albumCoverAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic · recent photos'**
  String get albumCoverAuto;

  /// No description provided for @previewInAlbums.
  ///
  /// In en, this message translates to:
  /// **'How it looks in Albums'**
  String get previewInAlbums;

  /// No description provided for @previewInAlbumsBody.
  ///
  /// In en, this message translates to:
  /// **'The first photo is the big one. With 1 or 2 photos the mosaic adapts.'**
  String get previewInAlbumsBody;

  /// No description provided for @coverAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get coverAutomatic;

  /// No description provided for @coverMain.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get coverMain;

  /// No description provided for @coverSecond.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get coverSecond;

  /// No description provided for @coverThird.
  ///
  /// In en, this message translates to:
  /// **'Third'**
  String get coverThird;

  /// No description provided for @fromThisAlbum.
  ///
  /// In en, this message translates to:
  /// **'From this album'**
  String get fromThisAlbum;

  /// No description provided for @fromAlbum.
  ///
  /// In en, this message translates to:
  /// **'From {path}'**
  String fromAlbum(String path);

  /// No description provided for @removeCover.
  ///
  /// In en, this message translates to:
  /// **'Remove from cover'**
  String get removeCover;

  /// No description provided for @coverRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from the cover'**
  String get coverRemoved;

  /// No description provided for @addCoverHint.
  ///
  /// In en, this message translates to:
  /// **'To add another, open a photo of this album or its sub-albums and tap «Cover». Without covers, the most recent photos are used.'**
  String get addCoverHint;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;
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
