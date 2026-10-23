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
  String get noDate => 'No date';

  @override
  String get noFiles => 'There is no files to show';

  @override
  String get selectionLimitReached => 'You can only select up to 100 files at a time.';

  @override
  String get newFolderTitle => 'New album';

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
  String get syncSessionCancelWarning => 'Cancel synchronization?';

  @override
  String get syncSessionCancelDescription => 'The current progress will be lost. The files uploaded will remain in the server.';

  @override
  String get syncSessionCancelConfirm => 'Yes, cancel';

  @override
  String get total => 'Total';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get failed => 'Failed';

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
  String get syncInProgressErrorTitle => 'Backup in progress';

  @override
  String get syncInProgressError => 'A backup is already running. Wait for it to finish and try again.';

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
  String get onboardingPermissionsRejectedTitle => 'Some Permissions Were Not Granted';

  @override
  String get onboardingPermissionsRejectedMessage => 'You have denied some required permissions. The app will work with limited functionality. You can enable these permissions later from the app settings:';

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
  String manageQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'What should we do with these $count photos?',
      one: 'What should we do with this photo?',
    );
    return '$_temp0';
  }

  @override
  String photosSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos selected',
      one: '1 photo selected',
    );
    return '$_temp0';
  }

  @override
  String photosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String get optSaveFree => 'Save and free up space';

  @override
  String get optSaveFreeBody => 'They\'re saved to your cloud and removed from the phone.';

  @override
  String get recommended => 'Recommended';

  @override
  String get optSaveKeep => 'Save and keep on the phone';

  @override
  String get optSaveKeepBody => 'You\'ll have a copy in the cloud and another one here.';

  @override
  String get optAlbum => 'Save to an album';

  @override
  String get optAlbumBody => 'Pick an existing one or create a new one.';

  @override
  String get newAlbumChip => 'New';

  @override
  String get deleteAfterSaving => 'Remove from the phone afterwards';

  @override
  String get deleteEverywhere => 'Delete everywhere';

  @override
  String saveToAlbum(String album) {
    return 'Save to $album';
  }

  @override
  String get chooseAlbum => 'Choose an album';

  @override
  String get actionToAlbum => 'To album';

  @override
  String get actionFreeUp => 'Free up';

  @override
  String get freeUpTitle => 'Free up space on the phone?';

  @override
  String freeUpBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The $count photos will be saved to your cloud and removed from this phone.',
      one: 'The photo will be saved to your cloud and removed from this phone.',
    );
    return '$_temp0';
  }

  @override
  String deleteFilesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count photos?',
      one: 'Delete this photo?',
    );
    return '$_temp0';
  }

  @override
  String get deleteFilesBody => 'They\'ll be removed from your cloud and this phone. You can restore them from the trash for 30 days.';

  @override
  String get preparingBackup => 'Preparing the backup…';

  @override
  String get lookingForPhotos => 'Looking for new photos';

  @override
  String get finishingBackup => 'Finishing the backup…';

  @override
  String get cancellingBackup => 'Cancelling…';

  @override
  String remainingMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'About $count min left',
      one: 'About 1 min left',
    );
    return '$_temp0';
  }

  @override
  String get remainingLessThanMinute => 'Less than a minute left';

  @override
  String get backgroundInfo => 'You can leave the app: the backup continues in the background and we\'ll let you know when it\'s done.';

  @override
  String get seeAll => 'See all';

  @override
  String get seeLess => 'See less';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String get welcomeGeneric => 'Welcome';

  @override
  String get permissionsHeadline => 'Three permissions and we\'re ready';

  @override
  String get permissionsBody => 'That way we can save your photos automatically and let you know when each backup finishes.';

  @override
  String get permPhotosTitle => 'Photos and videos';

  @override
  String get permPhotosBody => 'To back them up and free up space';

  @override
  String get permNotifTitle => 'Notifications';

  @override
  String get permNotifBody => 'We let you know when it\'s done or if it fails';

  @override
  String get permBgTitle => 'Background';

  @override
  String get permBgBody => 'Backups with the app closed';

  @override
  String get allow => 'Allow';

  @override
  String get done => 'Done';

  @override
  String get permSettings => 'Settings';

  @override
  String get privacyNote => 'Your photos are private. You can change these permissions any time from Profile.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get later => 'Do it later';

  @override
  String get continueAnyway => 'Continue anyway';

  @override
  String get reviewPermissions => 'Review permissions';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'Automatic';

  @override
  String get themeSystemHint => 'Follows your phone\'s mode';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String deviceLastBackup(String os, String when) {
    return '$os · Last backup $when';
  }

  @override
  String photosSelectedSize(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos · $size',
      one: '1 photo · $size',
    );
    return '$_temp0';
  }

  @override
  String freeUpSize(String size) {
    return 'Free up $size';
  }

  @override
  String get filePropertyName => 'Name';

  @override
  String get filePropertyUploadedAt => 'Uploaded at';

  @override
  String get filePropertySize => 'Size';

  @override
  String get filePropertyDimensions => 'Dimensions';

  @override
  String get filePropertyAlbum => 'Album';

  @override
  String get filePropertyDevice => 'Device';

  @override
  String get fileInfoLoading => 'Loading details…';

  @override
  String get filterFavorites => 'Favorites';

  @override
  String get favorite => 'Favorite';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptyBody => 'Tap the heart while viewing a photo to keep it here';

  @override
  String favoritesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count added to favorites',
      one: 'Added to favorites',
    );
    return '$_temp0';
  }

  @override
  String favoritesRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count removed from favorites',
      one: 'Removed from favorites',
    );
    return '$_temp0';
  }

  @override
  String get favoriteError => 'Couldn\'t update. Please try again.';

  @override
  String get move => 'Move';

  @override
  String get cover => 'Cover';

  @override
  String coverOf(String album) {
    return 'Cover of $album';
  }

  @override
  String coverOfMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cover of $count albums',
      one: 'Cover of 1 album',
    );
    return '$_temp0';
  }

  @override
  String get useAsCover => 'Use as cover';

  @override
  String get useAsCoverBody => 'Tick the albums where you want it to appear. Up to 3 per album.';

  @override
  String get photoIsHere => 'The photo is here';

  @override
  String get photosAreHere => 'The photos are here';

  @override
  String get coverAlreadyHint => 'Already a cover · untick to remove it';

  @override
  String coverWillAdd(int count) {
    return 'Will be added · $count of 3';
  }

  @override
  String get coverFullChoose => 'Full · choose which to replace';

  @override
  String coverFullChooseMany(int count) {
    return 'Full · choose $count to replace';
  }

  @override
  String get coverWillRemove => 'Will be removed from the cover';

  @override
  String coverCount(int count) {
    return '$count of 3 covers';
  }

  @override
  String get replace => 'Replace';

  @override
  String replaceCoverOf(int position, String album) {
    return 'Replace cover $position of $album';
  }

  @override
  String get coverTreeNote => 'Only the photo\'s album and the albums that contain it are shown.';

  @override
  String saveChangesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save · $count changes',
      one: 'Save · 1 change',
    );
    return '$_temp0';
  }

  @override
  String coverUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cover updated in $count albums',
      one: 'Cover updated',
    );
    return '$_temp0';
  }

  @override
  String upToThreeCovers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0 · up to 3 can be a cover';
  }

  @override
  String get chooseUpToThree => 'Choose up to 3 photos to use as cover';

  @override
  String get videosCannotBeCovers => 'Videos can\'t be album covers';

  @override
  String get noSharedAlbum => 'These photos don\'t share an album';

  @override
  String inAlbum(String album) {
    return 'in $album';
  }

  @override
  String albumCoverTitle(String album) {
    return 'Cover of $album';
  }

  @override
  String albumCoverSubtitle(int count) {
    return '$count of 3 photos · drag to change the order';
  }

  @override
  String albumCoverCard(int count) {
    return '$count of 3 photos';
  }

  @override
  String get albumCoverAuto => 'Automatic · recent photos';

  @override
  String get previewInAlbums => 'How it looks in Albums';

  @override
  String get previewInAlbumsBody => 'The first photo is the big one. With 1 or 2 photos the mosaic adapts.';

  @override
  String get coverAutomatic => 'Automatic';

  @override
  String get coverMain => 'Main';

  @override
  String get coverSecond => 'Second';

  @override
  String get coverThird => 'Third';

  @override
  String get fromThisAlbum => 'From this album';

  @override
  String fromAlbum(String path) {
    return 'From $path';
  }

  @override
  String get removeCover => 'Remove from cover';

  @override
  String get coverRemoved => 'Removed from the cover';

  @override
  String get addCoverHint => 'To add another, open a photo of this album or its sub-albums and tap «Cover». Without covers, the most recent photos are used.';

  @override
  String get undo => 'Undo';

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get coverBadge => 'Cover';

  @override
  String bytesToUpload(String size) {
    return '$size left to upload';
  }

  @override
  String get errorRecoveryPhraseMismatch => 'These 24 words do not match any key of your account.';

  @override
  String get errorInvalidRecoveryPhrase => 'Check the words: one is misspelled or some are missing.';

  @override
  String errorWeakPassword(int min) {
    return 'The password must have at least $min characters.';
  }

  @override
  String get errorMissingDeviceKey => 'This device does not have every key of your account. Log in again on it and try again.';

  @override
  String get errorKeyUnlock => 'The keys of your account could not be opened.';

  @override
  String get errorDeviceAuthentication => 'Your identity could not be verified with the device lock. Set up a fingerprint, PIN or pattern and try again.';

  @override
  String get recoveryPhraseTitle => 'Your 24 recovery words';

  @override
  String get recoveryPhraseSubtitle => 'They are the only way to recover your photos if you forget your password and have no other device with an open session.';

  @override
  String get recoveryPhraseWarning => 'Nobody, not even us, can recover them for you. Keep them somewhere safe.';

  @override
  String get recoveryPhraseSaveToPasswordManager => 'Save to the password manager';

  @override
  String get recoveryPhraseSavedToPasswordManager => 'Saved to the password manager';

  @override
  String get recoveryPhraseSaveToPasswordManagerFailed => 'They could not be saved to the password manager. Download the PDF or write them down.';

  @override
  String get recoveryPhraseDownloadPdf => 'Download PDF';

  @override
  String get recoveryPhraseContinue => 'I have saved them';

  @override
  String get recoveryPhraseDone => 'Done';

  @override
  String get recoveryPhraseViewTitle => 'My 24 words';

  @override
  String get recoveryPhraseNotOnDevice => 'This device has no copy of your 24 words. If you have them written down, verify them to keep a copy here.';

  @override
  String recoveryPhrasePasswordManagerAccount(String email) {
    return 'Photo Manager recovery key ($email)';
  }

  @override
  String get recoveryPhrasePdfTitle => 'Photo Manager recovery key';

  @override
  String get recoveryPhrasePdfAccount => 'Account';

  @override
  String get recoveryPhrasePdfWarning => 'Keep this document somewhere safe. Anyone with these words and access to your email could reset your password.';

  @override
  String get recoveryPhrasePdfInstructions => 'If you forget your password: tap \"Forgot your password?\", enter the code you get by email and then these 24 words.';

  @override
  String get confirmPhraseTitle => 'Check your words';

  @override
  String get confirmPhraseSubtitle => 'Type the words we ask for to confirm you have saved them.';

  @override
  String confirmPhraseWordLabel(int position) {
    return 'Word number $position';
  }

  @override
  String get confirmPhraseCheck => 'Check';

  @override
  String get confirmPhraseWrong => 'A word does not match. Check your copy.';

  @override
  String get recoveryWordsInputLabel => 'Your 24 words';

  @override
  String get recoveryWordsInputHint => 'Type them separated by spaces';

  @override
  String get lockedTitle => 'Your earlier photos are locked';

  @override
  String get lockedMessage => 'You reset your password without your 24 words, so the keys that protected your photos cannot be opened.';

  @override
  String get lockedPhotosKept => 'Your photos have not been deleted. You will recover all of them if you find your 24 words or a device that still has an open session.';

  @override
  String get lockedUseWords => 'I have my 24 words';

  @override
  String get lockedUseDevice => 'Recover from this device';

  @override
  String get lockedUseDeviceSubtitle => 'This device still keeps the keys of some locked photos.';

  @override
  String get lockedNewKey => 'Start with a new key';

  @override
  String get lockedNewKeyConfirmTitle => 'Start with a new key?';

  @override
  String get lockedNewKeyConfirmMessage => 'You can keep uploading photos. The earlier ones stay locked but are not deleted: you can recover them later.';

  @override
  String get lockedPasswordPrompt => 'Type your current password';

  @override
  String get lockedUnlocked => 'Photos recovered';

  @override
  String get resetHaveWordsQuestion => 'Do you have your 24 recovery words?';

  @override
  String get resetHaveWordsYes => 'Yes, I have them';

  @override
  String get resetHaveWordsNo => 'I do not have them';

  @override
  String get resetWithoutWordsTitle => 'Your photos will be locked';

  @override
  String get resetWithoutWordsMessage => 'Without the 24 words the keys of your photos cannot be opened. You will log in with the new password, but your current photos will be locked. They are not deleted: you will recover them if you find your words or a device with an open session.';

  @override
  String get resetWithoutWordsConfirm => 'Understood, continue';

  @override
  String get resetAccountLockedNotice => 'Password changed. When you log in you will see how to recover your locked photos.';

  @override
  String get deviceResetTitle => 'I forgot my password';

  @override
  String get deviceResetSubtitle => 'Since this device has an open session, you can set a new password without losing anything. We will ask for the fingerprint or PIN of the device.';

  @override
  String get deviceResetReason => 'Confirm it is you to change the password';

  @override
  String get deviceResetSubmit => 'Change password';

  @override
  String get deviceResetSuccess => 'Password changed';

  @override
  String get verifyPhraseTitle => 'Verify my 24 words';

  @override
  String get verifyPhraseSubtitleFull => 'Type your 24 words. If they are right, a copy will be kept on this device.';

  @override
  String get verifyPhraseSuccess => 'Your words are right';

  @override
  String get reminderTitle => 'Do you still have your 24 words?';

  @override
  String get reminderMessage => 'They are the only way to recover your photos if you forget your password. Check that you still have them.';

  @override
  String get reminderVerifyNow => 'Check now';

  @override
  String get reminderLater => 'Later';

  @override
  String get profileSecuritySection => 'Security';

  @override
  String get profileRecoveryWords => 'My 24 words';

  @override
  String get profileVerifyWords => 'Verify my 24 words';

  @override
  String get profileForgotPassword => 'I forgot my password';

  @override
  String get profileLockedPhotos => 'Recover locked photos';

  @override
  String get lockedNone => 'You have no locked photos: all your keys are available.';

  @override
  String get legalInfoTitle => 'Information and legal';

  @override
  String get legalInfoLink => 'How it works, terms and privacy';

  @override
  String get legalInfoSubtitle => 'How your photos are protected and the rules of the service. You can read them without an account.';

  @override
  String legalVersionLabel(String version, String date) {
    return 'Version $version · in force since $date';
  }

  @override
  String get legalAcceptPrefix => 'I have read and accept the';

  @override
  String get legalTermsLink => 'Terms of use';

  @override
  String get legalAcceptMiddle => 'and the';

  @override
  String get legalPrivacyLink => 'Privacy policy';

  @override
  String get legalAcceptRequired => 'You must accept the terms of use and the privacy policy';

  @override
  String get legalAcceptanceTitle => 'Terms of use and privacy';

  @override
  String get legalAcceptanceMessage => 'To keep using Photo Manager, read and accept the terms of use and the privacy policy. They explain how your photos are protected and what happens if you lose access to them.';

  @override
  String get legalAcceptanceButton => 'Accept and continue';

  @override
  String get errorLegalTermsNotAccepted => 'You must accept the terms of use and the privacy policy';

  @override
  String get recoveryPhraseImportanceTitle => 'Read this before you continue';

  @override
  String get recoveryPhraseImportance1 => 'If you forget your password, these 24 words are the only way to recover your photos.';

  @override
  String get recoveryPhraseImportance2 => 'Nobody can recover them for you, not even us.';

  @override
  String get recoveryPhraseImportance3 => 'Save them now in the password manager or as a PDF, and keep a copy somewhere safe.';

  @override
  String recoveryPhraseWait(int seconds) {
    return 'Read carefully ($seconds)';
  }

  @override
  String get recoveryPhraseLearnMore => 'More about the 24 words';

  @override
  String get errorMissingCurrentKey => 'This device has no key to encrypt new photos. Log in again or recover your locked photos.';

  @override
  String get mediaLocked => 'Locked: recover it from Profile > Security';

  @override
  String get mediaLoadError => 'It could not be loaded';

  @override
  String get errorLockedFile => 'This file is locked. You can recover it from Profile > Security > Recover locked photos.';

  @override
  String get errorUnencryptedFile => 'This file was uploaded before encryption and cannot be shown.';

  @override
  String get keySyncTitle => 'Your keys changed on another device';

  @override
  String get keySyncMessage => 'The password or the keys of your account were changed on another device. Type your current password to keep seeing and uploading your photos on this one.';

  @override
  String get keySyncDone => 'Keys updated';

  @override
  String get errorOutdatedKeys => 'The keys of your account changed on another device. Open the app and type your current password.';

  @override
  String get actionDownload => 'Download';

  @override
  String get actionShare => 'Share';

  @override
  String get actionMore => 'More';

  @override
  String get actionOnDevice => 'On phone';

  @override
  String selectionSizeOnDevice(String size, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count on this phone',
      one: '1 on this phone',
      zero: 'none on this phone',
    );
    return '$size · $_temp0';
  }

  @override
  String get downloadAlbum => 'Download album';

  @override
  String get downloadSheetTitle => 'Save to this phone';

  @override
  String downloadSheetSubtitle(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$name · $_temp0';
  }

  @override
  String get downloadSheetAllTitle => 'What is not on this phone';

  @override
  String downloadToDownload(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count to download',
      one: '1 to download',
    );
    return '$_temp0';
  }

  @override
  String downloadApproxSize(String size) {
    return 'About $size';
  }

  @override
  String downloadAlreadyOnDevice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count already on this phone',
      one: '1 already on this phone',
    );
    return '$_temp0';
  }

  @override
  String get downloadSkipped => 'Skipped';

  @override
  String get downloadIncludeSubalbums => 'Include subalbums';

  @override
  String get downloadFreeSpace => 'Free space on this phone';

  @override
  String downloadFreeOfTotal(String free, String total) {
    return '$free of $total';
  }

  @override
  String downloadDestinationNote(String album) {
    return 'They are saved in the phone gallery, in the album «$album». Use Wi-Fi if you can.';
  }

  @override
  String downloadButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Download $count items',
      one: 'Download 1 item',
    );
    return '$_temp0';
  }

  @override
  String get downloadNothingMissing => 'Everything is already on this phone';

  @override
  String downloadNotEnoughSpaceNote(String size) {
    return 'It does not fit: you need $size free on this phone';
  }

  @override
  String downloadProgressTitle(int saved, int total) {
    return 'Saving to this phone · $saved of $total';
  }

  @override
  String downloadProgressRemaining(String time) {
    return 'about $time left';
  }

  @override
  String downloadProgressFinished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved to this phone',
      one: '1 saved to this phone',
    );
    return '$_temp0';
  }

  @override
  String downloadProgressFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count could not be saved',
      one: '1 could not be saved',
    );
    return '$_temp0';
  }

  @override
  String get downloadProgressMainAlbum => 'Phone gallery';

  @override
  String downloadStarted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Downloading $count items',
      one: 'Downloading 1 item',
    );
    return '$_temp0';
  }

  @override
  String downloadAllOnDevice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'They are all on this phone already',
      one: 'It is already on this phone',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int count) {
    return '$count min';
  }

  @override
  String get durationLessThanMinute => 'less than 1 min';

  @override
  String get filterNotOnDevice => 'Not on phone';

  @override
  String notOnDeviceSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0 · $size';
  }

  @override
  String get downloadAll => 'Download all';

  @override
  String get emptyNotOnDeviceTitle => 'Everything is on this phone';

  @override
  String get emptyNotOnDeviceBody => 'Photos and videos that are only in the cloud show up here.';

  @override
  String sharePreparing(int prepared, int total) {
    return 'Preparing $prepared of $total…';
  }

  @override
  String get errorNotEnoughSpace => 'There is not enough space on this phone for these files.';

  @override
  String get errorDeviceMediaUnsupported => 'This phone does not let the app save photos into its gallery.';

  @override
  String errorTooManyFilesToShare(int max) {
    return 'You can share up to $max files at once.';
  }

  @override
  String get deleteAccountAction => 'Delete account';

  @override
  String deleteAccountStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get deleteAccountTitle => 'Before you delete your account';

  @override
  String get deleteAccountSubtitle => 'This is what will happen and how to take your photos with you first.';

  @override
  String get deleteAccountWhatIsDeleted => 'What is deleted';

  @override
  String deleteAccountFiles(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString photos and videos',
      one: '1 photo or video',
    );
    return '$_temp0';
  }

  @override
  String deleteAccountFilesDetail(String size) {
    return '$size stored in the cloud';
  }

  @override
  String deleteAccountAlbums(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString albums',
      one: '1 album',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountAlbumsDetail => 'With their subalbums, covers and favorites';

  @override
  String deleteAccountDevices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices are unlinked',
      one: '1 device is unlinked',
      zero: 'No linked devices',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountDevicesDetail => 'Automatic backup stops on all of them';

  @override
  String get deleteAccountPhoneSafe => 'The photos on your phone are not touched';

  @override
  String get deleteAccountPhoneSafeDetail => 'Only what is in the cloud is deleted';

  @override
  String get deleteAccountTakePhotos => 'Take your photos with you';

  @override
  String get deleteAccountSaveAll => 'Save everything on this phone';

  @override
  String deleteAccountSaveAllDetail(int count, String size) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString to download',
      one: '1 to download',
    );
    return '$_temp0 · $size';
  }

  @override
  String deleteAccountSaveAllFree(int count, String free) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString to download',
      one: '1 to download',
    );
    return '$_temp0 · you have $free free';
  }

  @override
  String get deleteAccountSaveAllDone => 'Everything is already on this phone';

  @override
  String get deleteAccountContinue => 'Continue';

  @override
  String get deleteAccountKeep => 'Keep my account';

  @override
  String get deleteAccountConfirmTitle => 'Confirm it\'s you';

  @override
  String deleteAccountConfirmSubtitle(String word) {
    return 'For your security, enter your password and the word $word.';
  }

  @override
  String get deleteAccountConfirmWord => 'DELETE';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Type $word';
  }

  @override
  String get deleteAccountFinalNote => 'You will be signed out on every device and everything will be deleted right away. This cannot be undone.';

  @override
  String get deleteAccountSubmit => 'Delete my account';

  @override
  String get deleteAccountWrongPassword => 'The password is not correct';

  @override
  String get deleteAccountDone => 'Your account has been deleted';

  @override
  String get notificationChannelFinishedName => 'Finished';

  @override
  String get notificationChannelFinishedDescription => 'When a backup or a download to this phone finishes';

  @override
  String get notificationChannelFailureName => 'Backup problems';

  @override
  String get notificationChannelFailureDescription => 'When a backup could not be completed';

  @override
  String get notificationChannelProgressName => 'In progress';

  @override
  String get notificationChannelProgressDescription => 'Progress of a backup or a download running in the background';

  @override
  String get notificationBackupRunningTitle => 'Backing up your photos';

  @override
  String get notificationBackupPreparing => 'Preparing the backup…';

  @override
  String notificationBackupProgress(int current, int total) {
    return '$current of $total files uploaded';
  }

  @override
  String get notificationBackupDoneTitle => 'Backup completed';

  @override
  String notificationBackupDoneBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files uploaded',
      one: '1 file uploaded',
      zero: 'Everything was already backed up',
    );
    return '$_temp0';
  }

  @override
  String get notificationBackupFailedTitle => 'The backup could not be completed';

  @override
  String get notificationBackupFailedBody => 'It will be tried again later. Open the app to see what happened.';

  @override
  String get notificationBackupSessionExpired => 'Your session has expired. Log in again to keep backing up your photos.';

  @override
  String get notificationDownloadRunningTitle => 'Saving to this phone';

  @override
  String notificationDownloadProgress(int saved, int total) {
    return '$saved of $total files';
  }

  @override
  String get notificationDownloadDoneTitle => 'Download completed';

  @override
  String notificationDownloadDoneBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files saved to this phone',
      one: '1 file saved to this phone',
    );
    return '$_temp0';
  }

  @override
  String notificationDownloadFailedSuffix(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count could not be saved',
      one: '1 could not be saved',
    );
    return '$_temp0';
  }

  @override
  String get appColor => 'App color';

  @override
  String get appColorHint => 'Changes buttons, selection and links. The logo stays the same.';

  @override
  String get accentViolet => 'Violet';

  @override
  String get accentBlue => 'Blue';

  @override
  String get accentTeal => 'Teal';

  @override
  String get accentTerracotta => 'Terracotta';

  @override
  String get accentGraphite => 'Graphite';

  @override
  String get plansTitle => 'Plans';

  @override
  String get plansSubtitle => 'End-to-end encrypted: nobody but you can see your photos, whatever the plan.';

  @override
  String get planNameFree => 'Free';

  @override
  String get planName100 => '100 GB';

  @override
  String get planName250 => '250 GB';

  @override
  String get planName1tb => '1 TB';

  @override
  String get planYours => 'Your plan';

  @override
  String planStorage(String size) {
    return '$size of space';
  }

  @override
  String planDevices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices',
      one: '1 device',
    );
    return '$_temp0';
  }

  @override
  String planVideos(String size) {
    return 'Videos up to $size';
  }

  @override
  String get planBackupDaily => 'Daily automatic backup';

  @override
  String get planBackupWeekly => 'Weekly automatic backup';

  @override
  String planPriceMonthly(String price) {
    return '$price/month';
  }

  @override
  String planPriceAnnual(String price) {
    return 'or $price/year: 2 months free';
  }

  @override
  String get planComingSoon => 'Paid plans are coming soon.';

  @override
  String planUsageStorage(String used, String limit) {
    return 'Space: $used of $limit';
  }

  @override
  String planUsageDevices(int count, int max) {
    return 'Devices: $count of $max';
  }

  @override
  String planRenews(String date) {
    return 'Renews on $date';
  }

  @override
  String planEnds(String date) {
    return 'Ends on $date: it will not renew';
  }

  @override
  String get planPaymentIssue => 'The last payment failed: check your payment method in Google Play';

  @override
  String planEnded(String date) {
    return 'Your subscription ended on $date';
  }

  @override
  String get planRow => 'Your plan';

  @override
  String planRowValue(String name, String size) {
    return '$name · $size';
  }

  @override
  String get planSeePlans => 'See plans';

  @override
  String get planReadOnlyTitle => 'Your account is read only';

  @override
  String planReadOnlyBody(String used, String limit) {
    return 'You use $used and your plan allows $limit. You can view, download and delete your files, but not back up new ones until you free up space or upgrade your plan.';
  }

  @override
  String get planDevicePausedTitle => 'This device is paused';

  @override
  String planDevicePausedBody(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Your plan allows $max devices',
      one: 'Your plan allows 1 device',
    );
    return '$_temp0, and the ones that backed up most recently use them. Unlink another one or upgrade your plan.';
  }

  @override
  String get planDeviceNotLinkedTitle => 'This device is not linked';

  @override
  String planDeviceNotLinkedBody(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Your plan allows $max devices',
      one: 'Your plan allows 1 device',
    );
    return '$_temp0. Unlink another one from My devices or upgrade your plan to back up from this one.';
  }

  @override
  String get planWeeklyOnly => 'On the free plan the automatic backup is weekly.';

  @override
  String planVideosSkipped(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos were not backed up',
      one: '1 video was not backed up',
    );
    return '$_temp0: your plan allows videos up to $size.';
  }

  @override
  String backupNotEnoughSpace(String free) {
    return 'Not everything pending fits: what fits in the $free free will be backed up.';
  }

  @override
  String backupFilesDidNotFit(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files were not backed up',
      one: '1 file was not backed up',
    );
    return '$_temp0: they did not fit in your space ($size). Upgrade your plan to back them up.';
  }

  @override
  String get errorPlanLimit => 'Your plan has reached one of its limits.';

  @override
  String get notificationBackupPlanLimit => 'Your plan has reached one of its limits. Open the app to see it.';

  @override
  String get notificationStorageFullTitle => 'Not everything fit in your space';

  @override
  String notificationStorageFullBody(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files were not backed up',
      one: '1 file was not backed up',
    );
    return '$_temp0 ($size). Tap to see the plans.';
  }

  @override
  String get planPaymentPending => 'Payment pending: the plan applies as soon as it is confirmed';

  @override
  String planBuyMonthly(String price) {
    return '$price per month';
  }

  @override
  String planBuyAnnual(String price) {
    return '$price per year';
  }

  @override
  String get planStoreUnavailable => 'Could not connect to Google Play. Try again later.';

  @override
  String planPurchaseDone(String name) {
    return 'Done! You now have the $name plan';
  }

  @override
  String get planPurchasePending => 'Your payment is pending. The plan will apply as soon as it is confirmed.';

  @override
  String get planPurchaseError => 'The purchase could not be completed. Try again later.';

  @override
  String get planManage => 'Manage in Google Play';

  @override
  String get deleteAccountSubscription => 'Your subscription is cancelled';

  @override
  String get deleteAccountSubscriptionDetail => 'It will not renew and you will not be charged again';

  @override
  String get planPurchaseTerms => 'When you subscribe, the plan starts at once at your request, so you give up the right of withdrawal. It renews automatically until you cancel it in Google Play; once cancelled you keep it until the end of the paid period and it is not refunded.';

  @override
  String get planPurchaseTermsLink => 'Terms of use';

  @override
  String get registerEmailBody => 'First we verify your email: we\'ll send you a 6-digit code.';

  @override
  String get registerEmailTaken => 'This email already has an account.';

  @override
  String get registerChangeEmail => 'Change email';

  @override
  String get errorSecondFactorExpired => 'The verification expired. Sign in again.';

  @override
  String get loginSecondFactorTitle => 'Confirm it\'s you';

  @override
  String loginSecondFactorBody(String email) {
    return 'This device is new for your account. We\'ve sent a 6-digit code to $email';
  }

  @override
  String get loginSecondFactorBack => 'Back to sign in';

  @override
  String get profileTwoFactor => 'Authenticator app';

  @override
  String get twoFactorTitle => 'Authenticator app';

  @override
  String get twoFactorOffBody => 'When you sign in on a new device we email you a code. With an authenticator app (Google Authenticator, Microsoft Authenticator…) the code comes from the app instead: even with your password and your email, nobody can get in.';

  @override
  String get twoFactorOnBody => 'Signing in on a new device asks for a code of your authenticator app, or one of your backup codes.';

  @override
  String get twoFactorStatusOn => 'On';

  @override
  String get twoFactorStatusOff => 'Off';

  @override
  String twoFactorBackupCodesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unused backup codes',
      one: '1 unused backup code',
    );
    return '$_temp0';
  }

  @override
  String get twoFactorEnable => 'Turn on';

  @override
  String get twoFactorDisable => 'Turn off';

  @override
  String get twoFactorRegenerate => 'New backup codes';

  @override
  String get twoFactorSetUpTitle => 'Set up the app';

  @override
  String get twoFactorSetUpStep1 => '1. Add the account to your authenticator app: open it with the button, or type the key by hand.';

  @override
  String get twoFactorOpenApp => 'Open in the authenticator app';

  @override
  String get twoFactorNoApp => 'No authenticator app on this phone opens the link. Install one, or type the key by hand.';

  @override
  String get twoFactorCopyKey => 'Copy key';

  @override
  String get twoFactorKeyCopied => 'Key copied';

  @override
  String get twoFactorSetUpStep2 => '2. Type the 6-digit code the app shows.';

  @override
  String get twoFactorBackupCodesTitle => 'Keep your backup codes';

  @override
  String get twoFactorBackupCodesBody => 'If you lose the phone with the app, each code lets you in once. Keep them somewhere safe: you will not see them again.';

  @override
  String get twoFactorCopyCodes => 'Copy';

  @override
  String get twoFactorCodesCopied => 'Codes copied';

  @override
  String get twoFactorShareCodes => 'Share';

  @override
  String get twoFactorCodesSaved => 'I have saved them';

  @override
  String get twoFactorShareText => 'Photo Manager backup codes. Each one works once.';

  @override
  String get twoFactorPromptDisableTitle => 'Turn off the authenticator app';

  @override
  String get twoFactorPromptRegenerateTitle => 'New backup codes';

  @override
  String get twoFactorPromptBody => 'Type your password and a code of the app (or a backup code).';

  @override
  String get twoFactorCodeLabel => 'Code';

  @override
  String get twoFactorDisabledMessage => 'Authenticator app turned off';

  @override
  String get loginTotpTitle => 'Code of your authenticator app';

  @override
  String get loginTotpBody => 'This device is new for your account. Type the 6-digit code of your authenticator app.';

  @override
  String get loginBackupCodeBody => 'Type one of your backup codes (like abcde-fghij). Each one works once.';

  @override
  String get loginUseBackupCode => 'Use a backup code';

  @override
  String get loginUseAppCode => 'Use the code of the app';

  @override
  String get loginBackupCodeLabel => 'Backup code';

  @override
  String get recoveryWordsAuthReason => 'Confirm it\'s you to see the recovery words';

  @override
  String get recoveryWordsPasswordTitle => 'Confirm your password';

  @override
  String get recoveryWordsPasswordBody => 'This phone has no screen lock. Type your password to see the recovery words.';

  @override
  String get errorWrongPassword => 'The password is not correct.';

  @override
  String get sectionWhat => 'What to back up';

  @override
  String get localAlbumsTitle => 'Albums on the phone';

  @override
  String get localAlbumsMessage => 'Choose what the backup does with the photos of each folder of your phone. What is already uploaded does not change.';

  @override
  String get localAlbumsReviewTitle => 'Your albums';

  @override
  String localAlbumsReviewMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'We found $count albums on your phone.',
      one: 'We found 1 album on your phone.',
    );
    return '$_temp0 The ones set to «As an album» will be created in Photo Manager with their photos.';
  }

  @override
  String get localAlbumsReviewHint => 'You can change it any time in Profile → Backup settings → Albums on the phone.';

  @override
  String get localAlbumsLimitedAccess => 'You only see the albums of the photos you gave access to.';

  @override
  String get localAlbumsEmpty => 'There are no albums in your gallery';

  @override
  String get localAlbumsEmptyMessage => 'When you have folders with photos or videos, they will show up here.';

  @override
  String get localAlbumsNoPermission => 'Photo access is missing';

  @override
  String get localAlbumsNoPermissionMessage => 'To see the albums of your phone, Photo Manager needs access to your photos.';

  @override
  String get localAlbumsGrantPermission => 'Allow access';

  @override
  String get localAlbumsLoadError => 'The albums could not be loaded';

  @override
  String get localAlbumModeAlbum => 'As an album';

  @override
  String get localAlbumModeBackupOnly => 'Backup only';

  @override
  String get localAlbumModeExcluded => 'Do not back up';

  @override
  String localAlbumFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '1 file',
    );
    return '$_temp0';
  }

  @override
  String localAlbumsSummary(int albums, int excluded) {
    String _temp0 = intl.Intl.pluralLogic(
      albums,
      locale: localeName,
      other: '$albums albums',
      one: '1 album',
    );
    return '$_temp0 · $excluded not backed up';
  }

  @override
  String localAlbumsSummaryAll(int albums) {
    String _temp0 = intl.Intl.pluralLogic(
      albums,
      locale: localeName,
      other: '$albums albums',
      one: '1 album',
    );
    return '$_temp0';
  }

  @override
  String backupAlbumsCreated(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your photos were organized into $count albums: $names',
      one: 'Your photos were organized into the album $names',
    );
    return '$_temp0';
  }

  @override
  String get seeAlbums => 'See albums';

  @override
  String get notificationAlbumsCreatedTitle => 'Your photos have new albums';

  @override
  String notificationAlbumsCreatedBody(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The backup put photos in $count albums: $names.',
      one: 'The backup put photos in the album $names.',
    );
    return '$_temp0 Tap to choose what is backed up.';
  }
}
