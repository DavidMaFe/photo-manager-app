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

  /// No description provided for @pendingSingular.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingSingular;

  /// No description provided for @pendingPlural.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingPlural;

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

  /// No description provided for @selectedFilesSingle.
  ///
  /// In en, this message translates to:
  /// **'1 selected'**
  String get selectedFilesSingle;

  /// No description provided for @selectedFiles.
  ///
  /// In en, this message translates to:
  /// **'{files} selected'**
  String selectedFiles(Object files);

  /// No description provided for @noFolders.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any folder. Create a new one.'**
  String get noFolders;

  /// No description provided for @selectFolder.
  ///
  /// In en, this message translates to:
  /// **'Select one folder'**
  String get selectFolder;

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get quickActionsTitle;

  /// No description provided for @saveAndKeepTitle.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAndKeepTitle;

  /// No description provided for @saveAndKeepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save and keep in the device'**
  String get saveAndKeepSubtitle;

  /// No description provided for @saveAndDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Save and free up space'**
  String get saveAndDeleteTitle;

  /// No description provided for @saveAndDeleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save and delete from the device'**
  String get saveAndDeleteSubtitle;

  /// No description provided for @saveInFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'To folder'**
  String get saveInFolderTitle;

  /// No description provided for @saveInFolderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save in a folder'**
  String get saveInFolderSubtitle;

  /// No description provided for @deleteBothTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteBothTitle;

  /// No description provided for @deleteBothSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete from all places'**
  String get deleteBothSubtitle;

  /// No description provided for @advancedOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'ADVANCED OPTIONS'**
  String get advancedOptionsTitle;

  /// No description provided for @nameFolder.
  ///
  /// In en, this message translates to:
  /// **'Name of the folder'**
  String get nameFolder;

  /// No description provided for @saveInRootTitle.
  ///
  /// In en, this message translates to:
  /// **'Save in root'**
  String get saveInRootTitle;

  /// No description provided for @saveInRootSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Without specific folder'**
  String get saveInRootSubtitle;

  /// No description provided for @moveToFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Move to existing folder'**
  String get moveToFolderTitle;

  /// No description provided for @moveToFolderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select one folder'**
  String get moveToFolderSubtitle;

  /// No description provided for @newFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new folder'**
  String get newFolderTitle;

  /// No description provided for @newFolderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write the folder name'**
  String get newFolderSubtitle;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete from server'**
  String get deleteTitle;

  /// No description provided for @deleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent'**
  String get deleteSubtitle;

  /// No description provided for @keepInDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep file in my device'**
  String get keepInDeviceTitle;

  /// No description provided for @keepInDeviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The file will continue to occupy local storage space.'**
  String get keepInDeviceSubtitle;

  /// No description provided for @deleteFromDeviceDescription.
  ///
  /// In en, this message translates to:
  /// **'The file will be removed from the device but will remain on the server'**
  String get deleteFromDeviceDescription;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @manageMultipleFiles.
  ///
  /// In en, this message translates to:
  /// **'Manage {files} files'**
  String manageMultipleFiles(Object files);

  /// No description provided for @manageSingleFile.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do with this file?'**
  String get manageSingleFile;

  /// No description provided for @sameActionWarning.
  ///
  /// In en, this message translates to:
  /// **'The same action will be applied to all the selected files'**
  String get sameActionWarning;

  /// No description provided for @applyMultiple.
  ///
  /// In en, this message translates to:
  /// **'Apply to {files}'**
  String applyMultiple(Object files);

  /// No description provided for @applySingle.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applySingle;

  /// No description provided for @selectAction.
  ///
  /// In en, this message translates to:
  /// **'Please, select an action'**
  String get selectAction;

  /// No description provided for @partialManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Partial management'**
  String get partialManageTitle;

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

  /// No description provided for @selectFolderError.
  ///
  /// In en, this message translates to:
  /// **'You must select a folder'**
  String get selectFolderError;

  /// No description provided for @newFolderNameError.
  ///
  /// In en, this message translates to:
  /// **'You must write a name for the new folder'**
  String get newFolderNameError;

  /// No description provided for @invalidActionError.
  ///
  /// In en, this message translates to:
  /// **'Invalid action'**
  String get invalidActionError;

  /// No description provided for @fileCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{currentFile} of {totalFiles}'**
  String fileCountLabel(Object currentFile, Object totalFiles);

  /// No description provided for @fileTypeNotSupported.
  ///
  /// In en, this message translates to:
  /// **'File type not supported'**
  String get fileTypeNotSupported;

  /// No description provided for @timePassedInMinutesSingular.
  ///
  /// In en, this message translates to:
  /// **'1 minute ago'**
  String get timePassedInMinutesSingular;

  /// No description provided for @timePassedInMinutesPlural.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String timePassedInMinutesPlural(Object minutes);

  /// No description provided for @timePassedInHoursSingular.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get timePassedInHoursSingular;

  /// No description provided for @timePassedInHoursPlural.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String timePassedInHoursPlural(Object hours);

  /// No description provided for @timePassedInDaysSingular.
  ///
  /// In en, this message translates to:
  /// **'1 day ago'**
  String get timePassedInDaysSingular;

  /// No description provided for @timePassedInDaysPlural.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String timePassedInDaysPlural(Object days);

  /// No description provided for @fileProperties.
  ///
  /// In en, this message translates to:
  /// **'File properties'**
  String get fileProperties;

  /// No description provided for @filePropertyType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filePropertyType;

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

  /// No description provided for @filePropertyStatusManaged.
  ///
  /// In en, this message translates to:
  /// **'Managed'**
  String get filePropertyStatusManaged;

  /// No description provided for @filePropertyStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filePropertyStatusPending;

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

  /// No description provided for @fileDetailManageFile.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get fileDetailManageFile;

  /// No description provided for @fileShare.
  ///
  /// In en, this message translates to:
  /// **'Share file'**
  String get fileShare;

  /// No description provided for @fileDownload.
  ///
  /// In en, this message translates to:
  /// **'Download file'**
  String get fileDownload;

  /// No description provided for @loadingVideoError.
  ///
  /// In en, this message translates to:
  /// **'Error loading the video'**
  String get loadingVideoError;

  /// No description provided for @foldersTitle.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get foldersTitle;

  /// No description provided for @folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folder;

  /// No description provided for @subfolders.
  ///
  /// In en, this message translates to:
  /// **'Subfolders'**
  String get subfolders;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

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
  /// **'Folder name'**
  String get folderName;

  /// No description provided for @hintFolderName.
  ///
  /// In en, this message translates to:
  /// **'Ex: Holidays 2024'**
  String get hintFolderName;

  /// No description provided for @folderNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Folder name is required'**
  String get folderNameRequiredError;

  /// No description provided for @folderMaxHundredCharactersError.
  ///
  /// In en, this message translates to:
  /// **'Max 100 characters'**
  String get folderMaxHundredCharactersError;

  /// No description provided for @renameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get renameFolder;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get newName;

  /// No description provided for @creatingFolder.
  ///
  /// In en, this message translates to:
  /// **'Creating folder...'**
  String get creatingFolder;

  /// No description provided for @renamingFolder.
  ///
  /// In en, this message translates to:
  /// **'Renaming folder...'**
  String get renamingFolder;

  /// No description provided for @deletingFolder.
  ///
  /// In en, this message translates to:
  /// **'Deleting folder...'**
  String get deletingFolder;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @emptyFolders.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have folders'**
  String get emptyFolders;

  /// No description provided for @emptyFolder.
  ///
  /// In en, this message translates to:
  /// **'This folder is empty'**
  String get emptyFolder;

  /// No description provided for @emptyFolderDescription.
  ///
  /// In en, this message translates to:
  /// **'Move files here to organize them'**
  String get emptyFolderDescription;

  /// No description provided for @createFirstFolder.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to create your first folder'**
  String get createFirstFolder;

  /// No description provided for @deleteFolder.
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get deleteFolder;

  /// No description provided for @deleteEmptyFolder.
  ///
  /// In en, this message translates to:
  /// **'¿Are you sure you want to delete the folder {folderName}?'**
  String deleteEmptyFolder(Object folderName);

  /// No description provided for @deleteFolderWithFiles.
  ///
  /// In en, this message translates to:
  /// **'The folder {folderName} contains {files} files. Are you sure you want to delete all the content?'**
  String deleteFolderWithFiles(Object files, Object folderName);

  /// No description provided for @deleteFolderWithSubfolders.
  ///
  /// In en, this message translates to:
  /// **'The folder {folderName} contains {subfolders} folders. Are you sure you want to delete all the content?'**
  String deleteFolderWithSubfolders(Object folderName, Object subfolders);

  /// No description provided for @deleteFolderWithFilesAndSubfoldersWarning.
  ///
  /// In en, this message translates to:
  /// **'The folder {folderName} contains {files} files and {subfolders} folders. Are you sure you want to delete all the content?'**
  String deleteFolderWithFilesAndSubfoldersWarning(Object files, Object folderName, Object subfolders);

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
