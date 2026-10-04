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
  String get sectionDiagnostics => 'Diagnostics';

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
}
