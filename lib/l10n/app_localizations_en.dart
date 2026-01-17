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
  String get selectAll => 'Select all';

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
  String get delete => 'Delete';

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
}
