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
  String get createAccount => 'Create Account';

  @override
  String get accountCreated => 'Account created! Please sign in';

  @override
  String get registerTitle => 'Sign up to get started';

  @override
  String get nameLabel => 'Name';

  @override
  String get namePlaceholder => 'John';

  @override
  String get surnameLabel => 'Last Name (optional)';

  @override
  String get surnamePlaceholder => 'Doe';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get errorNameRequired => 'Name is required';

  @override
  String get errorConfirmPasswordRequired => 'Please confirm your password';

  @override
  String get errorPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get registerButton => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signIn => 'Sign in';

  @override
  String get registerTermsDisclaimer => 'By signing up, you agree to our Terms and Conditions';

  @override
  String get gallery => 'Gallery';

  @override
  String get all => 'All';

  @override
  String get photos => 'Photos';

  @override
  String get videos => 'Videos';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get lastWeek => 'Last Week';

  @override
  String get pendingSingular => 'Pending';

  @override
  String get pendingPlural => 'Pending';

  @override
  String get pendingFilesInfoSingle => 'You have 1 file pending to manage';

  @override
  String pendingFilesInfo(Object files) {
    return 'You have $files files pending to manage';
  }

  @override
  String get noFiles => 'There is no files to show';

  @override
  String get syncToHaveFiles => 'Synchronize your devices to see your files';

  @override
  String get selectedFilesSingle => '1 selected';

  @override
  String selectedFiles(Object files) {
    return '$files selected';
  }

  @override
  String get noFolders => 'You don\'t have any folder. Create a new one.';

  @override
  String get selectFolder => 'Select one folder';

  @override
  String get quickActionsTitle => 'QUICK ACTIONS';

  @override
  String get saveAndKeepTitle => 'Save';

  @override
  String get saveAndKeepSubtitle => 'Save and keep in the device';

  @override
  String get saveAndDeleteTitle => 'Save and free up space';

  @override
  String get saveAndDeleteSubtitle => 'Save and delete from the device';

  @override
  String get saveInFolderTitle => 'To folder';

  @override
  String get saveInFolderSubtitle => 'Save in a folder';

  @override
  String get deleteBothTitle => 'Delete all';

  @override
  String get deleteBothSubtitle => 'Delete from all places';

  @override
  String get advancedOptionsTitle => 'ADVANCED OPTIONS';

  @override
  String get nameFolder => 'Name of the folder';

  @override
  String get saveInRootTitle => 'Save in root';

  @override
  String get saveInRootSubtitle => 'Without specific folder';

  @override
  String get moveToFolderTitle => 'Move to existing folder';

  @override
  String get moveToFolderSubtitle => 'Select one folder';

  @override
  String get newFolderTitle => 'Create a new folder';

  @override
  String get newFolderSubtitle => 'Write the folder name';

  @override
  String get deleteTitle => 'Delete from server';

  @override
  String get deleteSubtitle => 'This action is permanent';

  @override
  String get keepInDeviceTitle => 'Keep file in my device';

  @override
  String get keepInDeviceSubtitle => 'The file will continue to occupy local storage space.';

  @override
  String get deleteFromDeviceDescription => 'The file will be removed from the device but will remain on the server';

  @override
  String manageMultipleFiles(Object files) {
    return 'Manage $files files';
  }

  @override
  String get manageSingleFile => 'What would you like to do with this file?';

  @override
  String get sameActionWarning => 'The same action will be applied to all the selected files';

  @override
  String applyMultiple(Object files) {
    return 'Apply to $files';
  }

  @override
  String get applySingle => 'Apply';

  @override
  String get selectAction => 'Please, select an action';

  @override
  String get partialManageTitle => 'Partial management';

  @override
  String get filesRemovedFromServerLocalMayRemain => 'Some files may still exist on this device if they were uploaded from another device.';

  @override
  String get filesManaged => 'Files Managed';

  @override
  String get success => 'Success';

  @override
  String get ok => 'OK';

  @override
  String get dontShowAgain => 'Don\'t show this again';

  @override
  String correctManage(Object files) {
    return '$files files were managed successfully';
  }

  @override
  String failedManage(Object files) {
    return '$files files failed';
  }

  @override
  String get selectFolderError => 'You must select a folder';

  @override
  String get newFolderNameError => 'You must write a name for the new folder';

  @override
  String get invalidActionError => 'Invalid action';

  @override
  String fileCountLabel(Object currentFile, Object totalFiles) {
    return '$currentFile of $totalFiles';
  }

  @override
  String get fileTypeNotSupported => 'File type not supported';

  @override
  String get timePassedInMinutesSingular => '1 minute ago';

  @override
  String timePassedInMinutesPlural(Object minutes) {
    return '$minutes minutes ago';
  }

  @override
  String get timePassedInHoursSingular => '1 hour ago';

  @override
  String timePassedInHoursPlural(Object hours) {
    return '$hours hours ago';
  }

  @override
  String get timePassedInDaysSingular => '1 day ago';

  @override
  String timePassedInDaysPlural(Object days) {
    return '$days days ago';
  }

  @override
  String get fileProperties => 'File properties';

  @override
  String get filePropertyType => 'Type';

  @override
  String get filePropertyTypeImage => 'Image';

  @override
  String get filePropertyTypeVideo => 'Video';

  @override
  String get filePropertyStatus => 'Status';

  @override
  String get filePropertyStatusManaged => 'Managed';

  @override
  String get filePropertyStatusPending => 'Pending';

  @override
  String get filePropertyCapturedAt => 'Captured at';

  @override
  String get filePropertyDuration => 'Duration';

  @override
  String get fileDetailManageFile => 'Manage';

  @override
  String get fileShare => 'Share file';

  @override
  String get fileDownload => 'Download file';

  @override
  String get loadingVideoError => 'Error loading the video';

  @override
  String get foldersTitle => 'Folders';

  @override
  String get folder => 'Folder';

  @override
  String get subfolders => 'Subfolders';

  @override
  String get rename => 'Rename';

  @override
  String get create => 'Create';

  @override
  String get save => 'Save';

  @override
  String get folderName => 'Folder name';

  @override
  String get hintFolderName => 'Ex: Holidays 2024';

  @override
  String get folderNameRequiredError => 'Folder name is required';

  @override
  String get folderMaxHundredCharactersError => 'Max 100 characters';

  @override
  String get renameFolder => 'Rename folder';

  @override
  String get newName => 'New name';

  @override
  String get creatingFolder => 'Creating folder...';

  @override
  String get renamingFolder => 'Renaming folder...';

  @override
  String get deletingFolder => 'Deleting folder...';

  @override
  String get processing => 'Processing...';

  @override
  String get emptyFolders => 'You don\'t have folders';

  @override
  String get emptyFolder => 'This folder is empty';

  @override
  String get emptyFolderDescription => 'Move files here to organize them';

  @override
  String get createFirstFolder => 'Tap the + button to create your first folder';

  @override
  String get deleteFolder => 'Delete folder';

  @override
  String deleteEmptyFolder(Object folderName) {
    return '¿Are you sure you want to delete the folder $folderName?';
  }

  @override
  String deleteFolderWithFiles(Object files, Object folderName) {
    return 'The folder $folderName contains $files files. Are you sure you want to delete all the content?';
  }

  @override
  String deleteFolderWithSubfolders(Object folderName, Object subfolders) {
    return 'The folder $folderName contains $subfolders folders. Are you sure you want to delete all the content?';
  }

  @override
  String deleteFolderWithFilesAndSubfoldersWarning(Object files, Object folderName, Object subfolders) {
    return 'The folder $folderName contains $files files and $subfolders folders. Are you sure you want to delete all the content?';
  }

  @override
  String get syncCurrentState => 'Current state';

  @override
  String get syncLast => 'Last synchronization';

  @override
  String get syncEmpty => 'Without synchronizations';

  @override
  String get syncNow => 'Synchronize now';

  @override
  String get synchronized => 'Synchronized';

  @override
  String get syncPending => 'Pending';

  @override
  String syncFiles(Object syncFiles) {
    return '$syncFiles synchronized files';
  }

  @override
  String get notSyncYet => 'You have not synchronized yet';

  @override
  String get syncStart => 'Press the synchronization button to start';

  @override
  String get syncErrorLoad => 'Error loading synchronizations';

  @override
  String get syncHistoric => 'Recent Activity';

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
  String get notificationsTitle => 'Notifications';

  @override
  String get emptyNotifications => 'Without notifications';

  @override
  String get noNotificationsYet => 'You don\'t have notifications yet';

  @override
  String get errorLoadingProfile => 'Error loading the profile';

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
  String get trash => 'Trash';

  @override
  String get trashSubtitle => 'View deleted files';

  @override
  String get syncSettings => 'Sync Settings';

  @override
  String get syncSettingsSubtitle => 'Auto sync every 6 hours';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Manage notifications';

  @override
  String get trashIsEmpty => 'Trash is empty';

  @override
  String get trashEmptyDescription => 'Deleted files will appear here and be permanently deleted after 30 days';

  @override
  String daysRemaining(Object days) {
    return '${days}d';
  }

  @override
  String filesSelected(Object count) {
    return '$count selected';
  }

  @override
  String get emptyTrash => 'Empty';

  @override
  String get emptyTrashConfirmation => 'Are you sure you want to permanently delete all files in trash? This action cannot be undone.';

  @override
  String get restore => 'Restore';

  @override
  String restoreFiles(Object count) {
    return 'Restore $count files';
  }

  @override
  String get restoreFileConfirmation => 'Do you want to restore this file to its original location?';

  @override
  String restoreFilesConfirmation(Object count) {
    return 'Do you want to restore $count files to their original locations?';
  }

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String deleteFilesPermanently(Object count) {
    return 'Delete $count permanently';
  }

  @override
  String get deletePermanentlyConfirmation => 'Are you sure you want to permanently delete this file? This action cannot be undone.';

  @override
  String deleteFilesPermanentlyConfirmation(Object count) {
    return 'Are you sure you want to permanently delete $count files? This action cannot be undone.';
  }

  @override
  String filesRestoredSuccessfully(Object count) {
    return '$count files restored successfully';
  }

  @override
  String filesDeletedPermanently(Object count) {
    return '$count files permanently deleted';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get deselectAll => 'Deselect all';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get permissionPhotoAccessTitle => 'Photo Access';

  @override
  String get permissionPhotoAccessMessage => 'This app needs access to your photos to sync and manage your gallery. Your photos will remain private and secure.';

  @override
  String get permissionPhotoAccessContinue => 'Continue';

  @override
  String get permissionPhotoAccessDeniedTitle => 'Permission Denied';

  @override
  String get permissionPhotoAccessDeniedMessage => 'We can\'t access your photos without permission. Please enable photo access in Settings to use this feature.';

  @override
  String get permissionOpenSettings => 'Open Settings';

  @override
  String get timeLessThanAMinute => 'Just now';

  @override
  String get timeOneMinute => '1 minute ago';

  @override
  String timeMoreThanOneMinute(Object minutes) {
    return '$minutes minutes ago';
  }

  @override
  String get timeOneHour => '1 hour ago';

  @override
  String timeMoreThanOneHour(Object hours) {
    return '$hours hours ago';
  }

  @override
  String timeYesterday(Object hour) {
    return 'Yesterday at $hour';
  }

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

  @override
  String get forgotPasswordTitle => 'Recover password';

  @override
  String get forgotPasswordSubtitle => 'Enter your email to receive a verification code';

  @override
  String get sendCodeButton => 'Send code';

  @override
  String get emailSentSuccess => 'Code sent to your email';

  @override
  String get validateCodeTitle => 'Verify code';

  @override
  String validateCodeSubtitle(String email) {
    return 'Enter the 6-digit code sent to $email';
  }

  @override
  String get codeLabel => 'Verification code';

  @override
  String get codePlaceholder => '123456';

  @override
  String get validateCodeButton => 'Validate code';

  @override
  String get resendCodeButton => 'Resend code';

  @override
  String get codeResent => 'Code resent successfully';

  @override
  String get errorCodeRequired => 'Code is required';

  @override
  String get errorCodeInvalid => 'Code must be 6 digits';

  @override
  String get resetPasswordTitle => 'New password';

  @override
  String get resetPasswordSubtitle => 'Enter your new password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmNewPasswordLabel => 'Confirm new password';

  @override
  String get resetPasswordButton => 'Reset password';

  @override
  String get passwordResetSuccess => 'Password reset successfully';

  @override
  String get errorNewPasswordRequired => 'New password is required';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get currentPasswordPlaceholder => 'Your current password';

  @override
  String get errorCurrentPasswordRequired => 'Current password is required';

  @override
  String get errorCurrentPasswordIncorrect => 'Current password is incorrect';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get selectProfilePhoto => 'Select profile photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get basicInfoSection => 'Basic information';

  @override
  String get passwordSection => 'Change password';

  @override
  String get leavePasswordEmptyHint => 'Leave blank if you don\'t want to change the password';

  @override
  String get savingChanges => 'Saving changes...';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get renameDevice => 'Rename device';

  @override
  String get renameDeviceDescription => 'Enter a new name for your device';

  @override
  String get deviceName => 'Device name';

  @override
  String get deviceNameRequired => 'Device name is required';

  @override
  String get deviceNameTooLong => 'Name is too long (maximum 50 characters)';

  @override
  String get autoSync => 'Auto-sync';

  @override
  String get unlinkDevice => 'Unlink';

  @override
  String unlinkDeviceConfirmation(Object deviceName) {
    return 'Are you sure you want to unlink \'$deviceName\'? This device will stop syncing with your account.';
  }

  @override
  String get deviceActionSuccess => 'Action completed successfully';

  @override
  String get noDevices => 'No linked devices';

  @override
  String get noDevicesDescription => 'Devices will appear here when you sign in to the app from other devices.';

  @override
  String get devicesLoadError => 'Could not load devices';

  @override
  String get retry => 'Retry';

  @override
  String get syncConfigurationTitle => 'Sync Configuration';

  @override
  String get syncConfigurationDescription => 'Configure how and when your files will be automatically synced';

  @override
  String get enableAutoSync => 'Enable automatic sync';

  @override
  String get autoSyncEnabled => 'Automatic sync is enabled';

  @override
  String get autoSyncDisabled => 'Automatic sync is disabled';

  @override
  String get syncFrequencyTitle => 'Sync frequency';

  @override
  String get syncFrequencyDaily => 'Daily';

  @override
  String get syncFrequencyWeekly => 'Weekly';

  @override
  String get syncFrequencyAt => 'at';

  @override
  String get syncTimeTitle => 'Sync time';

  @override
  String get syncTimeDescription => 'Select the time you want the sync to run';

  @override
  String get selectTime => 'Select time';

  @override
  String get syncDayOfWeekTitle => 'Day of the week';

  @override
  String get syncDayOfWeekDescription => 'Select the day you want the sync to run';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get networkPreferenceTitle => 'Network preference';

  @override
  String get networkPreferenceWifiOnly => 'WiFi only';

  @override
  String get networkPreferenceWifiOnlyDescription => 'Sync will only run when connected to WiFi';

  @override
  String get networkPreferenceAnyNetwork => 'Any network';

  @override
  String get networkPreferenceAnyNetworkDescription => 'Sync will run on WiFi or mobile data';

  @override
  String get batteryPreferenceTitle => 'Battery preference';

  @override
  String get batteryPreferenceAny => 'Any battery level';

  @override
  String get batteryPreferenceAnyDescription => 'Sync will run regardless of battery level';

  @override
  String get batteryPreferenceCharging => 'Charging or battery >15%';

  @override
  String get batteryPreferenceChargingDescription => 'Sync will only run when device is charging or has more than 15% battery';

  @override
  String get notifyOnSuccess => 'Notify when sync is successful';

  @override
  String get notifyOnSuccessDescription => 'You will receive a notification when sync completes successfully';

  @override
  String get notifyOnFailure => 'Notify when sync fails';

  @override
  String get notifyOnFailureDescription => 'You will receive a notification when sync fails';

  @override
  String get saveConfiguration => 'Save configuration';

  @override
  String get savingConfiguration => 'Saving configuration...';

  @override
  String get configurationSaved => 'Configuration saved';

  @override
  String get configurationSavedDescription => 'Your automatic sync configuration has been saved successfully';

  @override
  String get configurationSaveError => 'Error saving configuration';

  @override
  String get loadingConfiguration => 'Loading configuration...';

  @override
  String get configurationLoadError => 'Error loading configuration';

  @override
  String get syncInProgressError => 'Sync in progress';

  @override
  String get syncInProgressErrorDescription => 'A sync is already in progress. Please wait for it to finish before starting a new one.';

  @override
  String get syncInProgressDialogTitle => 'Sync in progress';

  @override
  String get syncInProgressDialogMessage => 'An automatic sync is in progress in the background. Please wait for it to finish before starting a manual sync.';

  @override
  String get understood => 'Understood';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Photo Manager!';

  @override
  String get onboardingWelcomeMessage => 'To give you the best experience, we need your permission to access your photos, send you notifications, and run automatic syncs in the background.\n\nThese permissions allow us to:\n\n• Automatically sync your photos and videos\n• Keep your files safely backed up\n• Notify you about sync progress\n• Run syncs while the app is closed';

  @override
  String get onboardingWelcomeButton => 'Get Started';

  @override
  String get onboardingGetStarted => 'Start setup';

  @override
  String get permissionNotificationTitle => 'Notifications';

  @override
  String get permissionNotificationMessage => 'We\'ll send you notifications to inform you about the progress of your automatic syncs and when they complete successfully or fail.';

  @override
  String get permissionNotificationContinue => 'Allow Notifications';

  @override
  String get permissionNotificationDeniedTitle => 'Notifications Disabled';

  @override
  String get permissionNotificationDeniedMessage => 'Without notification permission, you won\'t receive updates about your sync status. You can enable notifications later in Settings.';

  @override
  String get permissionBackgroundTitle => 'Background Sync';

  @override
  String get permissionBackgroundMessage => 'For automatic sync to work properly, the app needs to run in the background. This allows your photos to sync even when the app is closed.';

  @override
  String get permissionBackgroundMessageAndroid => 'For automatic sync to work properly, we need to:\n\n• Allow the app to run in the background\n• Disable battery optimization for this app\n\nThis allows your photos to sync even when the app is closed.';

  @override
  String get permissionBackgroundMessageIOS => 'For automatic sync to work properly, we need to:\n\n• Enable background app refresh\n• Allow the app to run in the background\n\nThis allows your photos to sync even when the app is closed.';

  @override
  String get permissionBackgroundContinue => 'Allow Background Sync';

  @override
  String get permissionBackgroundDeniedTitle => 'Background Sync Disabled';

  @override
  String get permissionBackgroundDeniedMessage => 'Without permission to run in the background, automatic sync will only work when you have the app open. You can enable this later in Settings.';

  @override
  String get onboardingPermissionsRejectedTitle => 'Some Permissions Were Not Granted';

  @override
  String get onboardingPermissionsRejectedMessage => 'You have denied some required permissions. The app will work with limited functionality. You can enable these permissions later from the app settings:';

  @override
  String get onboardingPermissionsRejectedButton => 'I Understand';

  @override
  String get onboardingPermissionsRetryButton => 'Try Again';

  @override
  String get permissionLimitationPhoto => '• You won\'t be able to sync photos or videos';

  @override
  String get permissionLimitationNotification => '• You won\'t receive notifications about syncs';

  @override
  String get permissionLimitationBackground => '• Automatic sync will only work with the app open';

  @override
  String get onboardingPermissionsAllGrantedTitle => 'All Set!';

  @override
  String get onboardingPermissionsAllGrantedMessage => 'All permissions have been granted successfully. You can now start using Photo Manager with all its features.';

  @override
  String get onboardingPermissionsAllGrantedButton => 'Go to Gallery';

  @override
  String get errorGalleryPermissionTitle => 'Gallery Permission Required';

  @override
  String get errorGalleryPermission => 'The app needs access to your gallery to work. Please enable the permission in Settings.';
}
