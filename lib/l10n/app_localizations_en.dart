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
  String get emailLabel => 'Email';

  @override
  String get emailPlaceholder => 'your@email.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get logoutButton => 'Sign out';

  @override
  String get logoutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get forgotPassword => 'Forgot it?';

  @override
  String get accountCreated => 'Account created! Please sign in';

  @override
  String get nameLabel => 'Name';

  @override
  String get namePlaceholder => 'John';

  @override
  String get surnamePlaceholder => 'Doe';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get errorNameRequired => 'Name is required';

  @override
  String get errorConfirmPasswordRequired => 'Please confirm your password';

  @override
  String get errorPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get registerButton => 'Create account';

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
  String get noFiles => 'There is no files to show';

  @override
  String selectedFilesWithLimit(int count) {
    return '$count / 100 selected';
  }

  @override
  String get selectionLimitReached => 'You can only select up to 100 files at a time.';

  @override
  String get noFolders => 'You don\'t have any album. Create a new one.';

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
  String get saveInFolderTitle => 'To an album';

  @override
  String get saveInFolderSubtitle => 'Save in an album';

  @override
  String get deleteBothTitle => 'Delete all';

  @override
  String get deleteBothSubtitle => 'Delete from all places';

  @override
  String get advancedOptionsTitle => 'ADVANCED OPTIONS';

  @override
  String get nameFolder => 'Album name';

  @override
  String get saveInRootTitle => 'Save in root';

  @override
  String get saveInRootSubtitle => 'Without a specific album';

  @override
  String get moveToFolderTitle => 'Move to an existing album';

  @override
  String get moveToFolderSubtitle => 'Select an album';

  @override
  String get newFolderTitle => 'New album';

  @override
  String get newFolderSubtitle => 'Write the album name';

  @override
  String get deleteTitle => 'Delete from server';

  @override
  String get deleteSubtitle => 'This action is permanent';

  @override
  String get keepInDeviceTitle => 'Keep file in my device';

  @override
  String get keepInDeviceSubtitle => 'The file will continue to occupy local storage space.';

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
  String get selectFolderError => 'You must select an album';

  @override
  String get newFolderNameError => 'You must write a name for the new album';

  @override
  String get invalidActionError => 'Invalid action';

  @override
  String get fileTypeNotSupported => 'File type not supported';

  @override
  String get fileProperties => 'File properties';

  @override
  String get filePropertyTypeImage => 'Image';

  @override
  String get filePropertyTypeVideo => 'Video';

  @override
  String get filePropertyStatus => 'Status';

  @override
  String get filePropertyCapturedAt => 'Captured at';

  @override
  String get filePropertyDuration => 'Duration';

  @override
  String get loadingVideoError => 'Error loading the video';

  @override
  String get folder => 'Album';

  @override
  String get subfolders => 'Sub-albums';

  @override
  String get rename => 'Rename';

  @override
  String get create => 'Create';

  @override
  String get save => 'Save';

  @override
  String get folderName => 'Album name';

  @override
  String get hintFolderName => 'Ex: Holidays 2024';

  @override
  String get folderNameRequiredError => 'Album name is required';

  @override
  String get folderMaxHundredCharactersError => 'Max 100 characters';

  @override
  String get renameFolder => 'Rename album';

  @override
  String get newName => 'New name';

  @override
  String get creatingFolder => 'Creating album...';

  @override
  String get renamingFolder => 'Renaming album...';

  @override
  String get deletingFolder => 'Deleting album...';

  @override
  String get processing => 'Processing...';

  @override
  String get emptyFolders => 'You don\'t have albums';

  @override
  String get emptyFolder => 'This album is empty';

  @override
  String get emptyFolderDescription => 'Move photos here to organise them';

  @override
  String get createFirstFolder => 'Create your first album to organise your photos';

  @override
  String get deleteFolder => 'Delete album';

  @override
  String deleteEmptyFolder(Object folderName) {
    return 'Are you sure you want to delete the album $folderName?';
  }

  @override
  String deleteFolderWithFiles(Object files, Object folderName) {
    return 'The album $folderName contains $files files. Are you sure you want to delete all its content?';
  }

  @override
  String deleteFolderWithSubfolders(Object folderName, Object subfolders) {
    return 'The album $folderName contains $subfolders sub-albums. Are you sure you want to delete all its content?';
  }

  @override
  String deleteFolderWithFilesAndSubfoldersWarning(Object files, Object folderName, Object subfolders) {
    return 'The album $folderName contains $files files and $subfolders sub-albums. Are you sure you want to delete all its content?';
  }

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
  String get close => 'Close';

  @override
  String get tryAgain => 'Try again';

  @override
  String get storage => 'Storage';

  @override
  String get files => 'Files';

  @override
  String get folders => 'Albums';

  @override
  String get devices => 'Devices';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get myDevices => 'My devices';

  @override
  String get trash => 'Trash';

  @override
  String get notifications => 'Notifications';

  @override
  String get trashIsEmpty => 'Trash is empty';

  @override
  String get trashEmptyDescription => 'Deleted files will appear here and be permanently deleted after 30 days';

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
  String get sendCodeButton => 'Send code';

  @override
  String get emailSentSuccess => 'Code sent to your email';

  @override
  String get validateCodeButton => 'Verify code';

  @override
  String get resendCodeButton => 'Resend code';

  @override
  String get codeResent => 'Code resent successfully';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmNewPasswordLabel => 'Confirm new password';

  @override
  String get resetPasswordButton => 'Save password';

  @override
  String get passwordResetSuccess => 'Password reset successfully';

  @override
  String get errorNewPasswordRequired => 'New password is required';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get currentPasswordPlaceholder => 'Your current password';

  @override
  String get errorCurrentPasswordRequired => 'Current password is required';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated';

  @override
  String get passwordChangedSuccessfully => 'Password changed';

  @override
  String get selectProfilePhoto => 'Select profile photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get passwordSection => 'Change password';

  @override
  String get leavePasswordEmptyHint => 'Leave it blank if you don\'t want to change it';

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
  String get deviceName => 'Device name';

  @override
  String get deviceNameRequired => 'Device name is required';

  @override
  String get deviceNameTooLong => 'Name is too long (maximum 50 characters)';

  @override
  String get autoSync => 'Automatic backup';

  @override
  String get unlinkDevice => 'Unlink';

  @override
  String unlinkDeviceConfirmation(Object deviceName) {
    return 'Are you sure you want to unlink \'$deviceName\'? This device will stop syncing with your account.';
  }

  @override
  String get deviceActionSuccess => 'Done';

  @override
  String get noDevices => 'No linked devices';

  @override
  String get noDevicesDescription => 'Devices will appear here when you sign in to the app from other devices.';

  @override
  String get retry => 'Retry';

  @override
  String get autoSyncEnabled => 'Automatic sync is enabled';

  @override
  String get monday => 'Monday';

  @override
  String get notifyOnSuccess => 'Notify when sync is successful';

  @override
  String get notifyOnFailure => 'Notify when sync fails';

  @override
  String get configurationSaved => 'Settings saved';

  @override
  String get loadingConfiguration => 'Loading configuration...';

  @override
  String get configurationLoadError => 'Error loading configuration';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Photo Manager!';

  @override
  String get onboardingWelcomeMessage => 'To give you the best experience, we need your permission to access your photos, send you notifications, and run automatic syncs in the background.\n\nThese permissions allow us to:\n\n• Automatically sync your photos and videos\n• Keep your files safely backed up\n• Notify you about sync progress\n• Run syncs while the app is closed';

  @override
  String get onboardingWelcomeButton => 'Get Started';

  @override
  String get permissionNotificationTitle => 'Notifications';

  @override
  String get permissionNotificationMessage => 'We\'ll send you notifications to inform you about the progress of your automatic syncs and when they complete successfully or fail.';

  @override
  String get permissionNotificationDeniedTitle => 'Notifications Disabled';

  @override
  String get permissionNotificationDeniedMessage => 'Without notification permission, you won\'t receive updates about your sync status. You can enable notifications later in Settings.';

  @override
  String get permissionBackgroundTitle => 'Background Sync';

  @override
  String get permissionBackgroundMessageAndroid => 'For automatic sync to work properly, we need to:\n\n• Allow the app to run in the background\n• Disable battery optimization for this app\n\nThis allows your photos to sync even when the app is closed.';

  @override
  String get permissionBackgroundMessageIOS => 'For automatic sync to work properly, we need to:\n\n• Enable background app refresh\n• Allow the app to run in the background\n\nThis allows your photos to sync even when the app is closed.';

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
  String get loginGreeting => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to see and organise your photos.';

  @override
  String get noAccountYet => 'Don\'t have an account yet?';

  @override
  String get createAccountLink => 'Create account';

  @override
  String get registerHeadline => 'Create your account';

  @override
  String get registerSubtitle => 'Back up your photos and free up space on your phone.';

  @override
  String get surnameShortLabel => 'Last name';

  @override
  String get optionalLabel => '(optional)';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get forgotPasswordHeadline => 'Forgot your password?';

  @override
  String get forgotPasswordBody => 'Enter your email and we\'ll send you a code to create a new one.';

  @override
  String get checkYourEmail => 'Check your email';

  @override
  String codeSentTo(String email) {
    return 'We\'ve sent a 6-digit code to $email';
  }

  @override
  String get didNotReceiveCode => 'Didn\'t get it?';

  @override
  String resendIn(String time) {
    return 'Resend in $time';
  }

  @override
  String get newPasswordHeadline => 'Create a new password';

  @override
  String get newPasswordBody => 'Use one you haven\'t used before on this account.';

  @override
  String get navPhotos => 'Photos';

  @override
  String get backupUpToDate => 'Up to date';

  @override
  String backupInProgress(int percent) {
    return 'Backing up $percent%';
  }

  @override
  String get backupFailed => 'Backup failed';

  @override
  String get filterAll => 'All';

  @override
  String get filterToReview => 'To review';

  @override
  String toReviewTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items to review',
      one: '1 item to review',
    );
    return '$_temp0';
  }

  @override
  String get toReviewBody => 'Decide whether to keep them or free up space on your phone';

  @override
  String get review => 'Review';

  @override
  String get select => 'Select';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get selectAllShort => 'All';

  @override
  String get selectNone => 'None';

  @override
  String get noPhotosYet => 'No photos yet';

  @override
  String get noPhotosBody => 'Back up your phone to see them here';

  @override
  String get backupNow => 'Back up now';

  @override
  String get openProfile => 'Open profile';

  @override
  String get closeSelection => 'Exit selection';

  @override
  String dayAndTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String get viewerInfo => 'Info';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get deleteFileTitle => 'Delete this file?';

  @override
  String get deleteFileBody => 'It will be removed from your cloud and this phone. You can restore it from the trash for 30 days.';

  @override
  String get copyId => 'Copy ID';

  @override
  String get copiedToClipboard => 'Copied';

  @override
  String get statusSafe => 'Backed up';

  @override
  String get navAlbums => 'Albums';

  @override
  String get searchAlbums => 'Search albums';

  @override
  String get newAlbum => 'New';

  @override
  String get createAlbum => 'Create album';

  @override
  String albumMeta(int count, int subcount) {
    String _temp0 = intl.Intl.pluralLogic(
      subcount,
      locale: localeName,
      other: '$subcount sub-albums',
      one: '1 sub-album',
    );
    return '$count · $_temp0';
  }

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'Empty',
    );
    return '$_temp0';
  }

  @override
  String get subalbum => 'Sub-album';

  @override
  String get newSubalbum => 'New sub-album';

  @override
  String get moreOptions => 'More options';

  @override
  String noAlbumsMatch(String query) {
    return 'No album matches “$query”';
  }

  @override
  String get navBackup => 'Backup';

  @override
  String get allSafe => 'All backed up';

  @override
  String lastBackupMeta(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return 'Last backup $when · $_temp0';
  }

  @override
  String copyingNofM(int done, int total) {
    return 'Backing up $done of $total';
  }

  @override
  String get backupIncomplete => 'The last backup didn\'t finish';

  @override
  String backupIncompleteMeta(String when, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count failures',
      one: '1 failure',
    );
    return '$when · $_temp0';
  }

  @override
  String get noBackupsYet => 'You haven\'t backed up yet';

  @override
  String get noBackupsBody => 'Save your photos to the cloud and free up space on your phone.';

  @override
  String get backupCancelledTitle => 'The last backup was cancelled';

  @override
  String condDaily(String time) {
    return 'Daily · $time';
  }

  @override
  String condWeekly(String day, String time) {
    return '$day · $time';
  }

  @override
  String get condWifi => 'Wi-Fi only';

  @override
  String get condAnyNetwork => 'Wi-Fi and data';

  @override
  String get condBattery => 'Charging or >15%';

  @override
  String get autoBackupOff => 'Automatic backup off';

  @override
  String get backupSettings => 'Backup settings';

  @override
  String get activity => 'Activity';

  @override
  String itemsSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items saved',
      one: '1 item saved',
    );
    return '$_temp0';
  }

  @override
  String incompleteWithFailures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count failures',
      one: '1 failure',
    );
    return 'Incomplete backup · $_temp0';
  }

  @override
  String get backupCancelled => 'Backup cancelled';

  @override
  String get backupRunning => 'Backup in progress';

  @override
  String get navProfile => 'Profile';

  @override
  String get edit => 'Edit';

  @override
  String storageOf(String used, String total) {
    return '$used of $total';
  }

  @override
  String elementsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return '$_temp0';
  }

  @override
  String albumsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'albums',
      one: 'album',
    );
    return '$_temp0';
  }

  @override
  String devicesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'devices',
      one: 'device',
    );
    return '$_temp0';
  }

  @override
  String get sectionBackupSpace => 'Backup and space';

  @override
  String get sectionApp => 'App';

  @override
  String dailyAt(String time) {
    return 'Daily at $time';
  }

  @override
  String weeklyAt(String day, String time) {
    return '$day at $time';
  }

  @override
  String linkedDevices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linked',
      one: '1 linked',
      zero: 'None linked',
    );
    return '$_temp0';
  }

  @override
  String get trashAutoEmpty => 'Emptied after 30 days';

  @override
  String get notifOnlyFailures => 'Failures only';

  @override
  String get notifOnlySuccess => 'Finished only';

  @override
  String get notifAll => 'All';

  @override
  String get notifOff => 'Off';

  @override
  String get sectionData => 'Details';

  @override
  String get sectionPassword => 'Password';

  @override
  String get gallerySource => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get thisDevice => 'This phone';

  @override
  String get emptyTrashShort => 'Empty';

  @override
  String get trashInfo => 'Items are deleted forever after 30 days. Long-press to restore several.';

  @override
  String get deletingSoon => 'Deleted soon';

  @override
  String get thisMonth => 'This month';

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String get deleteForever => 'Delete forever';

  @override
  String deletesIn(String time) {
    return 'Deleted in $time';
  }

  @override
  String selectedItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get autoBackupBody => 'Your new photos are saved automatically';

  @override
  String get sectionWhen => 'When';

  @override
  String get everyDay => 'Every day';

  @override
  String get oncePerWeek => 'Once a week';

  @override
  String get day => 'Day';

  @override
  String get time => 'Time';

  @override
  String nextBackup(String when) {
    return 'Next backup: $when';
  }

  @override
  String get sectionConditions => 'Conditions';

  @override
  String get network => 'Network';

  @override
  String get battery => 'Battery';

  @override
  String get always => 'Always';

  @override
  String get sectionAlerts => 'Alerts';

  @override
  String get alertSuccess => 'When it finishes';

  @override
  String get alertSuccessBody => 'A notice with what was saved';

  @override
  String get alertFailure => 'If something fails';

  @override
  String get alertFailureBody => 'So you can retry it';

  @override
  String get sectionDiagnostics => 'Diagnostics';
}
