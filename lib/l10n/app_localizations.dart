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

  /// No description provided for @syncInProgressErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup in progress'**
  String get syncInProgressErrorTitle;

  /// No description provided for @syncInProgressError.
  ///
  /// In en, this message translates to:
  /// **'A backup is already running. Wait for it to finish and try again.'**
  String get syncInProgressError;

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

  /// No description provided for @coverBadge.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get coverBadge;

  /// No description provided for @bytesToUpload.
  ///
  /// In en, this message translates to:
  /// **'{size} left to upload'**
  String bytesToUpload(String size);

  /// No description provided for @errorRecoveryPhraseMismatch.
  ///
  /// In en, this message translates to:
  /// **'These 24 words do not match any key of your account.'**
  String get errorRecoveryPhraseMismatch;

  /// No description provided for @errorInvalidRecoveryPhrase.
  ///
  /// In en, this message translates to:
  /// **'Check the words: one is misspelled or some are missing.'**
  String get errorInvalidRecoveryPhrase;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password must have at least {min} characters.'**
  String errorWeakPassword(int min);

  /// No description provided for @errorMissingDeviceKey.
  ///
  /// In en, this message translates to:
  /// **'This device does not have every key of your account. Log in again on it and try again.'**
  String get errorMissingDeviceKey;

  /// No description provided for @errorKeyUnlock.
  ///
  /// In en, this message translates to:
  /// **'The keys of your account could not be opened.'**
  String get errorKeyUnlock;

  /// No description provided for @errorDeviceAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Your identity could not be verified with the device lock. Set up a fingerprint, PIN or pattern and try again.'**
  String get errorDeviceAuthentication;

  /// No description provided for @recoveryPhraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Your 24 recovery words'**
  String get recoveryPhraseTitle;

  /// No description provided for @recoveryPhraseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'They are the only way to recover your photos if you forget your password and have no other device with an open session.'**
  String get recoveryPhraseSubtitle;

  /// No description provided for @recoveryPhraseWarning.
  ///
  /// In en, this message translates to:
  /// **'Nobody, not even us, can recover them for you. Keep them somewhere safe.'**
  String get recoveryPhraseWarning;

  /// No description provided for @recoveryPhraseSaveToPasswordManager.
  ///
  /// In en, this message translates to:
  /// **'Save to the password manager'**
  String get recoveryPhraseSaveToPasswordManager;

  /// No description provided for @recoveryPhraseSavedToPasswordManager.
  ///
  /// In en, this message translates to:
  /// **'Saved to the password manager'**
  String get recoveryPhraseSavedToPasswordManager;

  /// No description provided for @recoveryPhraseSaveToPasswordManagerFailed.
  ///
  /// In en, this message translates to:
  /// **'They could not be saved to the password manager. Download the PDF or write them down.'**
  String get recoveryPhraseSaveToPasswordManagerFailed;

  /// No description provided for @recoveryPhraseDownloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get recoveryPhraseDownloadPdf;

  /// No description provided for @recoveryPhraseContinue.
  ///
  /// In en, this message translates to:
  /// **'I have saved them'**
  String get recoveryPhraseContinue;

  /// No description provided for @recoveryPhraseDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get recoveryPhraseDone;

  /// No description provided for @recoveryPhraseViewTitle.
  ///
  /// In en, this message translates to:
  /// **'My 24 words'**
  String get recoveryPhraseViewTitle;

  /// No description provided for @recoveryPhraseNotOnDevice.
  ///
  /// In en, this message translates to:
  /// **'This device has no copy of your 24 words. If you have them written down, verify them to keep a copy here.'**
  String get recoveryPhraseNotOnDevice;

  /// No description provided for @recoveryPhrasePasswordManagerAccount.
  ///
  /// In en, this message translates to:
  /// **'Photo Manager recovery key ({email})'**
  String recoveryPhrasePasswordManagerAccount(String email);

  /// No description provided for @recoveryPhrasePdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Manager recovery key'**
  String get recoveryPhrasePdfTitle;

  /// No description provided for @recoveryPhrasePdfAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get recoveryPhrasePdfAccount;

  /// No description provided for @recoveryPhrasePdfWarning.
  ///
  /// In en, this message translates to:
  /// **'Keep this document somewhere safe. Anyone with these words and access to your email could reset your password.'**
  String get recoveryPhrasePdfWarning;

  /// No description provided for @recoveryPhrasePdfInstructions.
  ///
  /// In en, this message translates to:
  /// **'If you forget your password: tap \"Forgot your password?\", enter the code you get by email and then these 24 words.'**
  String get recoveryPhrasePdfInstructions;

  /// No description provided for @confirmPhraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your words'**
  String get confirmPhraseTitle;

  /// No description provided for @confirmPhraseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type the words we ask for to confirm you have saved them.'**
  String get confirmPhraseSubtitle;

  /// No description provided for @confirmPhraseWordLabel.
  ///
  /// In en, this message translates to:
  /// **'Word number {position}'**
  String confirmPhraseWordLabel(int position);

  /// No description provided for @confirmPhraseCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get confirmPhraseCheck;

  /// No description provided for @confirmPhraseWrong.
  ///
  /// In en, this message translates to:
  /// **'A word does not match. Check your copy.'**
  String get confirmPhraseWrong;

  /// No description provided for @recoveryWordsInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Your 24 words'**
  String get recoveryWordsInputLabel;

  /// No description provided for @recoveryWordsInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type them separated by spaces'**
  String get recoveryWordsInputHint;

  /// No description provided for @lockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your earlier photos are locked'**
  String get lockedTitle;

  /// No description provided for @lockedMessage.
  ///
  /// In en, this message translates to:
  /// **'You reset your password without your 24 words, so the keys that protected your photos cannot be opened.'**
  String get lockedMessage;

  /// No description provided for @lockedPhotosKept.
  ///
  /// In en, this message translates to:
  /// **'Your photos have not been deleted. You will recover all of them if you find your 24 words or a device that still has an open session.'**
  String get lockedPhotosKept;

  /// No description provided for @lockedUseWords.
  ///
  /// In en, this message translates to:
  /// **'I have my 24 words'**
  String get lockedUseWords;

  /// No description provided for @lockedUseDevice.
  ///
  /// In en, this message translates to:
  /// **'Recover from this device'**
  String get lockedUseDevice;

  /// No description provided for @lockedUseDeviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This device still keeps the keys of some locked photos.'**
  String get lockedUseDeviceSubtitle;

  /// No description provided for @lockedNewKey.
  ///
  /// In en, this message translates to:
  /// **'Start with a new key'**
  String get lockedNewKey;

  /// No description provided for @lockedNewKeyConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with a new key?'**
  String get lockedNewKeyConfirmTitle;

  /// No description provided for @lockedNewKeyConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You can keep uploading photos. The earlier ones stay locked but are not deleted: you can recover them later.'**
  String get lockedNewKeyConfirmMessage;

  /// No description provided for @lockedPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type your current password'**
  String get lockedPasswordPrompt;

  /// No description provided for @lockedUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Photos recovered'**
  String get lockedUnlocked;

  /// No description provided for @resetHaveWordsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you have your 24 recovery words?'**
  String get resetHaveWordsQuestion;

  /// No description provided for @resetHaveWordsYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, I have them'**
  String get resetHaveWordsYes;

  /// No description provided for @resetHaveWordsNo.
  ///
  /// In en, this message translates to:
  /// **'I do not have them'**
  String get resetHaveWordsNo;

  /// No description provided for @resetWithoutWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your photos will be locked'**
  String get resetWithoutWordsTitle;

  /// No description provided for @resetWithoutWordsMessage.
  ///
  /// In en, this message translates to:
  /// **'Without the 24 words the keys of your photos cannot be opened. You will log in with the new password, but your current photos will be locked. They are not deleted: you will recover them if you find your words or a device with an open session.'**
  String get resetWithoutWordsMessage;

  /// No description provided for @resetWithoutWordsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Understood, continue'**
  String get resetWithoutWordsConfirm;

  /// No description provided for @resetAccountLockedNotice.
  ///
  /// In en, this message translates to:
  /// **'Password changed. When you log in you will see how to recover your locked photos.'**
  String get resetAccountLockedNotice;

  /// No description provided for @deviceResetTitle.
  ///
  /// In en, this message translates to:
  /// **'I forgot my password'**
  String get deviceResetTitle;

  /// No description provided for @deviceResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Since this device has an open session, you can set a new password without losing anything. We will ask for the fingerprint or PIN of the device.'**
  String get deviceResetSubtitle;

  /// No description provided for @deviceResetReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm it is you to change the password'**
  String get deviceResetReason;

  /// No description provided for @deviceResetSubmit.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get deviceResetSubmit;

  /// No description provided for @deviceResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get deviceResetSuccess;

  /// No description provided for @verifyPhraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify my 24 words'**
  String get verifyPhraseTitle;

  /// No description provided for @verifyPhraseSubtitleFull.
  ///
  /// In en, this message translates to:
  /// **'Type your 24 words. If they are right, a copy will be kept on this device.'**
  String get verifyPhraseSubtitleFull;

  /// No description provided for @verifyPhraseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your words are right'**
  String get verifyPhraseSuccess;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you still have your 24 words?'**
  String get reminderTitle;

  /// No description provided for @reminderMessage.
  ///
  /// In en, this message translates to:
  /// **'They are the only way to recover your photos if you forget your password. Check that you still have them.'**
  String get reminderMessage;

  /// No description provided for @reminderVerifyNow.
  ///
  /// In en, this message translates to:
  /// **'Check now'**
  String get reminderVerifyNow;

  /// No description provided for @reminderLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get reminderLater;

  /// No description provided for @profileSecuritySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get profileSecuritySection;

  /// No description provided for @profileRecoveryWords.
  ///
  /// In en, this message translates to:
  /// **'My 24 words'**
  String get profileRecoveryWords;

  /// No description provided for @profileVerifyWords.
  ///
  /// In en, this message translates to:
  /// **'Verify my 24 words'**
  String get profileVerifyWords;

  /// No description provided for @profileForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'I forgot my password'**
  String get profileForgotPassword;

  /// No description provided for @profileLockedPhotos.
  ///
  /// In en, this message translates to:
  /// **'Recover locked photos'**
  String get profileLockedPhotos;

  /// No description provided for @lockedNone.
  ///
  /// In en, this message translates to:
  /// **'You have no locked photos: all your keys are available.'**
  String get lockedNone;

  /// No description provided for @legalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Information and legal'**
  String get legalInfoTitle;

  /// No description provided for @legalInfoLink.
  ///
  /// In en, this message translates to:
  /// **'How it works, terms and privacy'**
  String get legalInfoLink;

  /// No description provided for @legalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How your photos are protected and the rules of the service. You can read them without an account.'**
  String get legalInfoSubtitle;

  /// No description provided for @legalVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version} · in force since {date}'**
  String legalVersionLabel(String version, String date);

  /// No description provided for @legalAcceptPrefix.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the'**
  String get legalAcceptPrefix;

  /// No description provided for @legalTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get legalTermsLink;

  /// No description provided for @legalAcceptMiddle.
  ///
  /// In en, this message translates to:
  /// **'and the'**
  String get legalAcceptMiddle;

  /// No description provided for @legalPrivacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get legalPrivacyLink;

  /// No description provided for @legalAcceptRequired.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms of use and the privacy policy'**
  String get legalAcceptRequired;

  /// No description provided for @legalAcceptanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of use and privacy'**
  String get legalAcceptanceTitle;

  /// No description provided for @legalAcceptanceMessage.
  ///
  /// In en, this message translates to:
  /// **'To keep using Photo Manager, read and accept the terms of use and the privacy policy. They explain how your photos are protected and what happens if you lose access to them.'**
  String get legalAcceptanceMessage;

  /// No description provided for @legalAcceptanceButton.
  ///
  /// In en, this message translates to:
  /// **'Accept and continue'**
  String get legalAcceptanceButton;

  /// No description provided for @errorLegalTermsNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms of use and the privacy policy'**
  String get errorLegalTermsNotAccepted;

  /// No description provided for @recoveryPhraseImportanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Read this before you continue'**
  String get recoveryPhraseImportanceTitle;

  /// No description provided for @recoveryPhraseImportance1.
  ///
  /// In en, this message translates to:
  /// **'If you forget your password, these 24 words are the only way to recover your photos.'**
  String get recoveryPhraseImportance1;

  /// No description provided for @recoveryPhraseImportance2.
  ///
  /// In en, this message translates to:
  /// **'Nobody can recover them for you, not even us.'**
  String get recoveryPhraseImportance2;

  /// No description provided for @recoveryPhraseImportance3.
  ///
  /// In en, this message translates to:
  /// **'Save them now in the password manager or as a PDF, and keep a copy somewhere safe.'**
  String get recoveryPhraseImportance3;

  /// No description provided for @recoveryPhraseWait.
  ///
  /// In en, this message translates to:
  /// **'Read carefully ({seconds})'**
  String recoveryPhraseWait(int seconds);

  /// No description provided for @recoveryPhraseLearnMore.
  ///
  /// In en, this message translates to:
  /// **'More about the 24 words'**
  String get recoveryPhraseLearnMore;

  /// No description provided for @errorMissingCurrentKey.
  ///
  /// In en, this message translates to:
  /// **'This device has no key to encrypt new photos. Log in again or recover your locked photos.'**
  String get errorMissingCurrentKey;

  /// No description provided for @mediaLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked: recover it from Profile > Security'**
  String get mediaLocked;

  /// No description provided for @mediaLoadError.
  ///
  /// In en, this message translates to:
  /// **'It could not be loaded'**
  String get mediaLoadError;

  /// No description provided for @errorLockedFile.
  ///
  /// In en, this message translates to:
  /// **'This file is locked. You can recover it from Profile > Security > Recover locked photos.'**
  String get errorLockedFile;

  /// No description provided for @errorUnencryptedFile.
  ///
  /// In en, this message translates to:
  /// **'This file was uploaded before encryption and cannot be shown.'**
  String get errorUnencryptedFile;

  /// No description provided for @keySyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Your keys changed on another device'**
  String get keySyncTitle;

  /// No description provided for @keySyncMessage.
  ///
  /// In en, this message translates to:
  /// **'The password or the keys of your account were changed on another device. Type your current password to keep seeing and uploading your photos on this one.'**
  String get keySyncMessage;

  /// No description provided for @keySyncDone.
  ///
  /// In en, this message translates to:
  /// **'Keys updated'**
  String get keySyncDone;

  /// No description provided for @errorOutdatedKeys.
  ///
  /// In en, this message translates to:
  /// **'The keys of your account changed on another device. Open the app and type your current password.'**
  String get errorOutdatedKeys;

  /// No description provided for @actionDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get actionDownload;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get actionMore;

  /// No description provided for @actionOnDevice.
  ///
  /// In en, this message translates to:
  /// **'On phone'**
  String get actionOnDevice;

  /// No description provided for @selectionSizeOnDevice.
  ///
  /// In en, this message translates to:
  /// **'{size} · {count, plural, =0{none on this phone} =1{1 on this phone} other{{count} on this phone}}'**
  String selectionSizeOnDevice(String size, int count);

  /// No description provided for @downloadAlbum.
  ///
  /// In en, this message translates to:
  /// **'Download album'**
  String get downloadAlbum;

  /// No description provided for @downloadSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Save to this phone'**
  String get downloadSheetTitle;

  /// No description provided for @downloadSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · {count, plural, =1{1 item} other{{count} items}}'**
  String downloadSheetSubtitle(String name, int count);

  /// No description provided for @downloadSheetAllTitle.
  ///
  /// In en, this message translates to:
  /// **'What is not on this phone'**
  String get downloadSheetAllTitle;

  /// No description provided for @downloadToDownload.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 to download} other{{count} to download}}'**
  String downloadToDownload(int count);

  /// No description provided for @downloadApproxSize.
  ///
  /// In en, this message translates to:
  /// **'About {size}'**
  String downloadApproxSize(String size);

  /// No description provided for @downloadAlreadyOnDevice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 already on this phone} other{{count} already on this phone}}'**
  String downloadAlreadyOnDevice(int count);

  /// No description provided for @downloadSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get downloadSkipped;

  /// No description provided for @downloadIncludeSubalbums.
  ///
  /// In en, this message translates to:
  /// **'Include subalbums'**
  String get downloadIncludeSubalbums;

  /// No description provided for @downloadFreeSpace.
  ///
  /// In en, this message translates to:
  /// **'Free space on this phone'**
  String get downloadFreeSpace;

  /// No description provided for @downloadFreeOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{free} of {total}'**
  String downloadFreeOfTotal(String free, String total);

  /// No description provided for @downloadDestinationNote.
  ///
  /// In en, this message translates to:
  /// **'They are saved in the phone gallery, in the album «{album}». Use Wi-Fi if you can.'**
  String downloadDestinationNote(String album);

  /// No description provided for @downloadButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Download 1 item} other{Download {count} items}}'**
  String downloadButton(int count);

  /// No description provided for @downloadNothingMissing.
  ///
  /// In en, this message translates to:
  /// **'Everything is already on this phone'**
  String get downloadNothingMissing;

  /// No description provided for @downloadNotEnoughSpaceNote.
  ///
  /// In en, this message translates to:
  /// **'It does not fit: you need {size} free on this phone'**
  String downloadNotEnoughSpaceNote(String size);

  /// No description provided for @downloadProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Saving to this phone · {saved} of {total}'**
  String downloadProgressTitle(int saved, int total);

  /// No description provided for @downloadProgressRemaining.
  ///
  /// In en, this message translates to:
  /// **'about {time} left'**
  String downloadProgressRemaining(String time);

  /// No description provided for @downloadProgressFinished.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 saved to this phone} other{{count} saved to this phone}}'**
  String downloadProgressFinished(int count);

  /// No description provided for @downloadProgressFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 could not be saved} other{{count} could not be saved}}'**
  String downloadProgressFailed(int count);

  /// No description provided for @downloadProgressMainAlbum.
  ///
  /// In en, this message translates to:
  /// **'Phone gallery'**
  String get downloadProgressMainAlbum;

  /// No description provided for @downloadStarted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Downloading 1 item} other{Downloading {count} items}}'**
  String downloadStarted(int count);

  /// No description provided for @downloadAllOnDevice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{It is already on this phone} other{They are all on this phone already}}'**
  String downloadAllOnDevice(int count);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String durationMinutes(int count);

  /// No description provided for @durationLessThanMinute.
  ///
  /// In en, this message translates to:
  /// **'less than 1 min'**
  String get durationLessThanMinute;

  /// No description provided for @filterNotOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Not on phone'**
  String get filterNotOnDevice;

  /// No description provided for @notOnDeviceSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}} · {size}'**
  String notOnDeviceSummary(int count, String size);

  /// No description provided for @downloadAll.
  ///
  /// In en, this message translates to:
  /// **'Download all'**
  String get downloadAll;

  /// No description provided for @emptyNotOnDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything is on this phone'**
  String get emptyNotOnDeviceTitle;

  /// No description provided for @emptyNotOnDeviceBody.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos that are only in the cloud show up here.'**
  String get emptyNotOnDeviceBody;

  /// No description provided for @sharePreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing {prepared} of {total}…'**
  String sharePreparing(int prepared, int total);

  /// No description provided for @errorNotEnoughSpace.
  ///
  /// In en, this message translates to:
  /// **'There is not enough space on this phone for these files.'**
  String get errorNotEnoughSpace;

  /// No description provided for @errorDeviceMediaUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This phone does not let the app save photos into its gallery.'**
  String get errorDeviceMediaUnsupported;

  /// No description provided for @errorTooManyFilesToShare.
  ///
  /// In en, this message translates to:
  /// **'You can share up to {max} files at once.'**
  String errorTooManyFilesToShare(int max);

  /// No description provided for @deleteAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountAction;

  /// No description provided for @deleteAccountStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String deleteAccountStep(int current, int total);

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you delete your account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is what will happen and how to take your photos with you first.'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountWhatIsDeleted.
  ///
  /// In en, this message translates to:
  /// **'What is deleted'**
  String get deleteAccountWhatIsDeleted;

  /// No description provided for @deleteAccountFiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo or video} other{{count} photos and videos}}'**
  String deleteAccountFiles(int count);

  /// No description provided for @deleteAccountFilesDetail.
  ///
  /// In en, this message translates to:
  /// **'{size} stored in the cloud'**
  String deleteAccountFilesDetail(String size);

  /// No description provided for @deleteAccountAlbums.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 album} other{{count} albums}}'**
  String deleteAccountAlbums(int count);

  /// No description provided for @deleteAccountAlbumsDetail.
  ///
  /// In en, this message translates to:
  /// **'With their subalbums, covers and favorites'**
  String get deleteAccountAlbumsDetail;

  /// No description provided for @deleteAccountDevices.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No linked devices} =1{1 device is unlinked} other{{count} devices are unlinked}}'**
  String deleteAccountDevices(int count);

  /// No description provided for @deleteAccountDevicesDetail.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup stops on all of them'**
  String get deleteAccountDevicesDetail;

  /// No description provided for @deleteAccountPhoneSafe.
  ///
  /// In en, this message translates to:
  /// **'The photos on your phone are not touched'**
  String get deleteAccountPhoneSafe;

  /// No description provided for @deleteAccountPhoneSafeDetail.
  ///
  /// In en, this message translates to:
  /// **'Only what is in the cloud is deleted'**
  String get deleteAccountPhoneSafeDetail;

  /// No description provided for @deleteAccountTakePhotos.
  ///
  /// In en, this message translates to:
  /// **'Take your photos with you'**
  String get deleteAccountTakePhotos;

  /// No description provided for @deleteAccountSaveAll.
  ///
  /// In en, this message translates to:
  /// **'Save everything on this phone'**
  String get deleteAccountSaveAll;

  /// No description provided for @deleteAccountSaveAllDetail.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 to download} other{{count} to download}} · {size}'**
  String deleteAccountSaveAllDetail(int count, String size);

  /// No description provided for @deleteAccountSaveAllFree.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 to download} other{{count} to download}} · you have {free} free'**
  String deleteAccountSaveAllFree(int count, String free);

  /// No description provided for @deleteAccountSaveAllDone.
  ///
  /// In en, this message translates to:
  /// **'Everything is already on this phone'**
  String get deleteAccountSaveAllDone;

  /// No description provided for @deleteAccountContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get deleteAccountContinue;

  /// No description provided for @deleteAccountKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep my account'**
  String get deleteAccountKeep;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For your security, enter your password and the word {word}.'**
  String deleteAccountConfirmSubtitle(String word);

  /// No description provided for @deleteAccountConfirmWord.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteAccountConfirmWord;

  /// No description provided for @deleteAccountTypeWord.
  ///
  /// In en, this message translates to:
  /// **'Type {word}'**
  String deleteAccountTypeWord(String word);

  /// No description provided for @deleteAccountFinalNote.
  ///
  /// In en, this message translates to:
  /// **'You will be signed out on every device and everything will be deleted right away. This cannot be undone.'**
  String get deleteAccountFinalNote;

  /// No description provided for @deleteAccountSubmit.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccountSubmit;

  /// No description provided for @deleteAccountWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is not correct'**
  String get deleteAccountWrongPassword;

  /// No description provided for @deleteAccountDone.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted'**
  String get deleteAccountDone;

  /// No description provided for @notificationChannelFinishedName.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get notificationChannelFinishedName;

  /// No description provided for @notificationChannelFinishedDescription.
  ///
  /// In en, this message translates to:
  /// **'When a backup or a download to this phone finishes'**
  String get notificationChannelFinishedDescription;

  /// No description provided for @notificationChannelFailureName.
  ///
  /// In en, this message translates to:
  /// **'Backup problems'**
  String get notificationChannelFailureName;

  /// No description provided for @notificationChannelFailureDescription.
  ///
  /// In en, this message translates to:
  /// **'When a backup could not be completed'**
  String get notificationChannelFailureDescription;

  /// No description provided for @notificationChannelProgressName.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get notificationChannelProgressName;

  /// No description provided for @notificationChannelProgressDescription.
  ///
  /// In en, this message translates to:
  /// **'Progress of a backup or a download running in the background'**
  String get notificationChannelProgressDescription;

  /// No description provided for @notificationBackupRunningTitle.
  ///
  /// In en, this message translates to:
  /// **'Backing up your photos'**
  String get notificationBackupRunningTitle;

  /// No description provided for @notificationBackupPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing the backup…'**
  String get notificationBackupPreparing;

  /// No description provided for @notificationBackupProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total} files uploaded'**
  String notificationBackupProgress(int current, int total);

  /// No description provided for @notificationBackupDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup completed'**
  String get notificationBackupDoneTitle;

  /// No description provided for @notificationBackupDoneBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Everything was already backed up} =1{1 file uploaded} other{{count} files uploaded}}'**
  String notificationBackupDoneBody(int count);

  /// No description provided for @notificationBackupFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'The backup could not be completed'**
  String get notificationBackupFailedTitle;

  /// No description provided for @notificationBackupFailedBody.
  ///
  /// In en, this message translates to:
  /// **'It will be tried again later. Open the app to see what happened.'**
  String get notificationBackupFailedBody;

  /// No description provided for @notificationBackupSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Log in again to keep backing up your photos.'**
  String get notificationBackupSessionExpired;

  /// No description provided for @notificationDownloadRunningTitle.
  ///
  /// In en, this message translates to:
  /// **'Saving to this phone'**
  String get notificationDownloadRunningTitle;

  /// No description provided for @notificationDownloadProgress.
  ///
  /// In en, this message translates to:
  /// **'{saved} of {total} files'**
  String notificationDownloadProgress(int saved, int total);

  /// No description provided for @notificationDownloadDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Download completed'**
  String get notificationDownloadDoneTitle;

  /// No description provided for @notificationDownloadDoneBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file saved to this phone} other{{count} files saved to this phone}}'**
  String notificationDownloadDoneBody(int count);

  /// No description provided for @notificationDownloadFailedSuffix.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 could not be saved} other{{count} could not be saved}}'**
  String notificationDownloadFailedSuffix(int count);

  /// No description provided for @appColor.
  ///
  /// In en, this message translates to:
  /// **'App color'**
  String get appColor;

  /// No description provided for @appColorHint.
  ///
  /// In en, this message translates to:
  /// **'Changes buttons, selection and links. The logo stays the same.'**
  String get appColorHint;

  /// No description provided for @accentViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get accentViolet;

  /// No description provided for @accentBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get accentBlue;

  /// No description provided for @accentTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get accentTeal;

  /// No description provided for @accentTerracotta.
  ///
  /// In en, this message translates to:
  /// **'Terracotta'**
  String get accentTerracotta;

  /// No description provided for @accentGraphite.
  ///
  /// In en, this message translates to:
  /// **'Graphite'**
  String get accentGraphite;

  /// No description provided for @plansTitle.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plansTitle;

  /// No description provided for @plansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encrypted: nobody but you can see your photos, whatever the plan.'**
  String get plansSubtitle;

  /// No description provided for @planNameFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planNameFree;

  /// No description provided for @planName100.
  ///
  /// In en, this message translates to:
  /// **'100 GB'**
  String get planName100;

  /// No description provided for @planName250.
  ///
  /// In en, this message translates to:
  /// **'250 GB'**
  String get planName250;

  /// No description provided for @planName1tb.
  ///
  /// In en, this message translates to:
  /// **'1 TB'**
  String get planName1tb;

  /// No description provided for @planYours.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get planYours;

  /// No description provided for @planStorage.
  ///
  /// In en, this message translates to:
  /// **'{size} of space'**
  String planStorage(String size);

  /// No description provided for @planDevices.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 device} other{{count} devices}}'**
  String planDevices(int count);

  /// No description provided for @planVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos up to {size}'**
  String planVideos(String size);

  /// No description provided for @planBackupDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily automatic backup'**
  String get planBackupDaily;

  /// No description provided for @planBackupWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly automatic backup'**
  String get planBackupWeekly;

  /// No description provided for @planPriceMonthly.
  ///
  /// In en, this message translates to:
  /// **'{price}/month'**
  String planPriceMonthly(String price);

  /// No description provided for @planPriceAnnual.
  ///
  /// In en, this message translates to:
  /// **'or {price}/year: 2 months free'**
  String planPriceAnnual(String price);

  /// No description provided for @planComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Paid plans are coming soon.'**
  String get planComingSoon;

  /// No description provided for @planUsageStorage.
  ///
  /// In en, this message translates to:
  /// **'Space: {used} of {limit}'**
  String planUsageStorage(String used, String limit);

  /// No description provided for @planUsageDevices.
  ///
  /// In en, this message translates to:
  /// **'Devices: {count} of {max}'**
  String planUsageDevices(int count, int max);

  /// No description provided for @planRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews on {date}'**
  String planRenews(String date);

  /// No description provided for @planEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends on {date}: it will not renew'**
  String planEnds(String date);

  /// No description provided for @planPaymentIssue.
  ///
  /// In en, this message translates to:
  /// **'The last payment failed: check your payment method in Google Play'**
  String get planPaymentIssue;

  /// No description provided for @planEnded.
  ///
  /// In en, this message translates to:
  /// **'Your subscription ended on {date}'**
  String planEnded(String date);

  /// No description provided for @planRow.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get planRow;

  /// No description provided for @planRowValue.
  ///
  /// In en, this message translates to:
  /// **'{name} · {size}'**
  String planRowValue(String name, String size);

  /// No description provided for @planSeePlans.
  ///
  /// In en, this message translates to:
  /// **'See plans'**
  String get planSeePlans;

  /// No description provided for @planReadOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is read only'**
  String get planReadOnlyTitle;

  /// No description provided for @planReadOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'You use {used} and your plan allows {limit}. You can view, download and delete your files, but not back up new ones until you free up space or upgrade your plan.'**
  String planReadOnlyBody(String used, String limit);

  /// No description provided for @planDevicePausedTitle.
  ///
  /// In en, this message translates to:
  /// **'This device is paused'**
  String get planDevicePausedTitle;

  /// No description provided for @planDevicePausedBody.
  ///
  /// In en, this message translates to:
  /// **'{max, plural, =1{Your plan allows 1 device} other{Your plan allows {max} devices}}, and the ones that backed up most recently use them. Unlink another one or upgrade your plan.'**
  String planDevicePausedBody(int max);

  /// No description provided for @planDeviceNotLinkedTitle.
  ///
  /// In en, this message translates to:
  /// **'This device is not linked'**
  String get planDeviceNotLinkedTitle;

  /// No description provided for @planDeviceNotLinkedBody.
  ///
  /// In en, this message translates to:
  /// **'{max, plural, =1{Your plan allows 1 device} other{Your plan allows {max} devices}}. Unlink another one from My devices or upgrade your plan to back up from this one.'**
  String planDeviceNotLinkedBody(int max);

  /// No description provided for @planWeeklyOnly.
  ///
  /// In en, this message translates to:
  /// **'On the free plan the automatic backup is weekly.'**
  String get planWeeklyOnly;

  /// No description provided for @planVideosSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 video was not backed up} other{{count} videos were not backed up}}: your plan allows videos up to {size}.'**
  String planVideosSkipped(int count, String size);

  /// No description provided for @errorPlanLimit.
  ///
  /// In en, this message translates to:
  /// **'Your plan has reached one of its limits.'**
  String get errorPlanLimit;

  /// No description provided for @notificationBackupPlanLimit.
  ///
  /// In en, this message translates to:
  /// **'Your plan has reached one of its limits. Open the app to see it.'**
  String get notificationBackupPlanLimit;

  /// No description provided for @planPaymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment pending: the plan applies as soon as it is confirmed'**
  String get planPaymentPending;

  /// No description provided for @planBuyMonthly.
  ///
  /// In en, this message translates to:
  /// **'{price} per month'**
  String planBuyMonthly(String price);

  /// No description provided for @planBuyAnnual.
  ///
  /// In en, this message translates to:
  /// **'{price} per year'**
  String planBuyAnnual(String price);

  /// No description provided for @planStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to Google Play. Try again later.'**
  String get planStoreUnavailable;

  /// No description provided for @planPurchaseDone.
  ///
  /// In en, this message translates to:
  /// **'Done! You now have the {name} plan'**
  String planPurchaseDone(String name);

  /// No description provided for @planPurchasePending.
  ///
  /// In en, this message translates to:
  /// **'Your payment is pending. The plan will apply as soon as it is confirmed.'**
  String get planPurchasePending;

  /// No description provided for @planPurchaseError.
  ///
  /// In en, this message translates to:
  /// **'The purchase could not be completed. Try again later.'**
  String get planPurchaseError;

  /// No description provided for @planManage.
  ///
  /// In en, this message translates to:
  /// **'Manage in Google Play'**
  String get planManage;

  /// No description provided for @deleteAccountSubscription.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is cancelled'**
  String get deleteAccountSubscription;

  /// No description provided for @deleteAccountSubscriptionDetail.
  ///
  /// In en, this message translates to:
  /// **'It will not renew and you will not be charged again'**
  String get deleteAccountSubscriptionDetail;

  /// No description provided for @planPurchaseTerms.
  ///
  /// In en, this message translates to:
  /// **'When you subscribe, the plan starts at once at your request, so you give up the right of withdrawal. It renews automatically until you cancel it in Google Play; once cancelled you keep it until the end of the paid period and it is not refunded.'**
  String get planPurchaseTerms;

  /// No description provided for @planPurchaseTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get planPurchaseTermsLink;

  /// No description provided for @registerEmailBody.
  ///
  /// In en, this message translates to:
  /// **'First we verify your email: we\'ll send you a 6-digit code.'**
  String get registerEmailBody;

  /// No description provided for @registerEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'This email already has an account.'**
  String get registerEmailTaken;

  /// No description provided for @registerChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get registerChangeEmail;

  /// No description provided for @errorSecondFactorExpired.
  ///
  /// In en, this message translates to:
  /// **'The verification expired. Sign in again.'**
  String get errorSecondFactorExpired;

  /// No description provided for @loginSecondFactorTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you'**
  String get loginSecondFactorTitle;

  /// No description provided for @loginSecondFactorBody.
  ///
  /// In en, this message translates to:
  /// **'This device is new for your account. We\'ve sent a 6-digit code to {email}'**
  String loginSecondFactorBody(String email);

  /// No description provided for @loginSecondFactorBack.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get loginSecondFactorBack;

  /// No description provided for @profileTwoFactor.
  ///
  /// In en, this message translates to:
  /// **'Authenticator app'**
  String get profileTwoFactor;

  /// No description provided for @twoFactorTitle.
  ///
  /// In en, this message translates to:
  /// **'Authenticator app'**
  String get twoFactorTitle;

  /// No description provided for @twoFactorOffBody.
  ///
  /// In en, this message translates to:
  /// **'When you sign in on a new device we email you a code. With an authenticator app (Google Authenticator, Microsoft Authenticator…) the code comes from the app instead: even with your password and your email, nobody can get in.'**
  String get twoFactorOffBody;

  /// No description provided for @twoFactorOnBody.
  ///
  /// In en, this message translates to:
  /// **'Signing in on a new device asks for a code of your authenticator app, or one of your backup codes.'**
  String get twoFactorOnBody;

  /// No description provided for @twoFactorStatusOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get twoFactorStatusOn;

  /// No description provided for @twoFactorStatusOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get twoFactorStatusOff;

  /// No description provided for @twoFactorBackupCodesLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unused backup code} other{{count} unused backup codes}}'**
  String twoFactorBackupCodesLeft(int count);

  /// No description provided for @twoFactorEnable.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get twoFactorEnable;

  /// No description provided for @twoFactorDisable.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get twoFactorDisable;

  /// No description provided for @twoFactorRegenerate.
  ///
  /// In en, this message translates to:
  /// **'New backup codes'**
  String get twoFactorRegenerate;

  /// No description provided for @twoFactorSetUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up the app'**
  String get twoFactorSetUpTitle;

  /// No description provided for @twoFactorSetUpStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Add the account to your authenticator app: open it with the button, or type the key by hand.'**
  String get twoFactorSetUpStep1;

  /// No description provided for @twoFactorOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Open in the authenticator app'**
  String get twoFactorOpenApp;

  /// No description provided for @twoFactorNoApp.
  ///
  /// In en, this message translates to:
  /// **'No authenticator app on this phone opens the link. Install one, or type the key by hand.'**
  String get twoFactorNoApp;

  /// No description provided for @twoFactorCopyKey.
  ///
  /// In en, this message translates to:
  /// **'Copy key'**
  String get twoFactorCopyKey;

  /// No description provided for @twoFactorKeyCopied.
  ///
  /// In en, this message translates to:
  /// **'Key copied'**
  String get twoFactorKeyCopied;

  /// No description provided for @twoFactorSetUpStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Type the 6-digit code the app shows.'**
  String get twoFactorSetUpStep2;

  /// No description provided for @twoFactorBackupCodesTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your backup codes'**
  String get twoFactorBackupCodesTitle;

  /// No description provided for @twoFactorBackupCodesBody.
  ///
  /// In en, this message translates to:
  /// **'If you lose the phone with the app, each code lets you in once. Keep them somewhere safe: you will not see them again.'**
  String get twoFactorBackupCodesBody;

  /// No description provided for @twoFactorCopyCodes.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get twoFactorCopyCodes;

  /// No description provided for @twoFactorCodesCopied.
  ///
  /// In en, this message translates to:
  /// **'Codes copied'**
  String get twoFactorCodesCopied;

  /// No description provided for @twoFactorShareCodes.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get twoFactorShareCodes;

  /// No description provided for @twoFactorCodesSaved.
  ///
  /// In en, this message translates to:
  /// **'I have saved them'**
  String get twoFactorCodesSaved;

  /// No description provided for @twoFactorShareText.
  ///
  /// In en, this message translates to:
  /// **'Photo Manager backup codes. Each one works once.'**
  String get twoFactorShareText;

  /// No description provided for @twoFactorPromptDisableTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn off the authenticator app'**
  String get twoFactorPromptDisableTitle;

  /// No description provided for @twoFactorPromptRegenerateTitle.
  ///
  /// In en, this message translates to:
  /// **'New backup codes'**
  String get twoFactorPromptRegenerateTitle;

  /// No description provided for @twoFactorPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Type your password and a code of the app (or a backup code).'**
  String get twoFactorPromptBody;

  /// No description provided for @twoFactorCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get twoFactorCodeLabel;

  /// No description provided for @twoFactorDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Authenticator app turned off'**
  String get twoFactorDisabledMessage;

  /// No description provided for @loginTotpTitle.
  ///
  /// In en, this message translates to:
  /// **'Code of your authenticator app'**
  String get loginTotpTitle;

  /// No description provided for @loginTotpBody.
  ///
  /// In en, this message translates to:
  /// **'This device is new for your account. Type the 6-digit code of your authenticator app.'**
  String get loginTotpBody;

  /// No description provided for @loginBackupCodeBody.
  ///
  /// In en, this message translates to:
  /// **'Type one of your backup codes (like abcde-fghij). Each one works once.'**
  String get loginBackupCodeBody;

  /// No description provided for @loginUseBackupCode.
  ///
  /// In en, this message translates to:
  /// **'Use a backup code'**
  String get loginUseBackupCode;

  /// No description provided for @loginUseAppCode.
  ///
  /// In en, this message translates to:
  /// **'Use the code of the app'**
  String get loginUseAppCode;

  /// No description provided for @loginBackupCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Backup code'**
  String get loginBackupCodeLabel;

  /// No description provided for @recoveryWordsAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you to see the recovery words'**
  String get recoveryWordsAuthReason;

  /// No description provided for @recoveryWordsPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get recoveryWordsPasswordTitle;

  /// No description provided for @recoveryWordsPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'This phone has no screen lock. Type your password to see the recovery words.'**
  String get recoveryWordsPasswordBody;

  /// No description provided for @errorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is not correct.'**
  String get errorWrongPassword;
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
