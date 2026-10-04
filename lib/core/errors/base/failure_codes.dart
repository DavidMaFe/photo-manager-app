/// Error codes that match the backend error codes
///
/// These codes are returned by the backend in the ErrorResponse.code field
/// and are used to map to specific Failure types in the ErrorHandler.
///
/// Backend reference: /backend/*/domain/errors/*.java
class FailureCodes {
  // ==================== General Errors ====================
  static const String authenticationError = "AUTHENTICATION_ERROR";
  static const String unknownError = "UNKNOWN_ERROR";
  static const String validationError = "VALIDATION_ERROR";

  // ==================== User Domain Errors ====================
  static const String emailAlreadyUsed = "EMAIL_ALREADY_USED";
  static const String userNotFound = "USER_NOT_FOUND";
  static const String incorrectPassword = "INCORRECT_PASSWORD";
  static const String userDoesNotHaveStorageSpace = "USER_DOES_NOT_HAVE_STORAGE_SPACE";
  static const String updateUserError = "UPDATE_USER_ERROR";

  // ==================== Device Domain Errors ====================
  static const String deviceNotFound = "DEVICE_NOT_FOUND";
  static const String deviceLinkedToAnotherUser = "DEVICE_LINKED_TO_ANOTHER_USER";
  static const String deviceNotLinkedToUser = "DEVICE_NOT_LINKED_TO_USER";

  // ==================== File Domain Errors ====================
  static const String fileNotFound = "FILE_NOT_FOUND";
  static const String fileSizeNotAccepted = "FILE_SIZE_NOT_ACCEPTED";
  static const String invalidFileMimeType = "INVALID_FILE_MIME_TYPE";
  static const String deleteFileError = "DELETE_FILE_ERROR";

  // ==================== Sync Session Domain Errors ====================
  static const String syncSessionNotFound = "SYNC_SESSION_NOT_FOUND";
  static const String syncSessionAlreadyInProgress = "SYNC_SESSION_ALREADY_IN_PROGRESS";
  static const String syncSessionNotInProgress = "SYNC_SESSION_NOT_IN_PROGRESS";
  static const String uploadFileError = "UPLOAD_FILE_ERROR";

  // ==================== Folder Domain Errors ====================
  static const String folderNotFound = "FOLDER_NOT_FOUND";
  static const String folderAlreadyExists = "FOLDER_ALREADY_EXISTS";
  static const String folderCoversLimitExceeded = "FOLDER_COVERS_LIMIT_EXCEEDED";
  static const String folderCoverDuplicated = "FOLDER_COVER_DUPLICATED";
  static const String folderCoverFileNotValid = "FOLDER_COVER_FILE_NOT_VALID";
  static const String folderCoverVideoNotAllowed = "FOLDER_COVER_VIDEO_NOT_ALLOWED";
  static const String folderCoverReplaceNotValid = "FOLDER_COVER_REPLACE_NOT_VALID";

  // ==================== Password Reset Domain Errors ====================
  static const String expiredResetCode = "EXPIRED_RESET_CODE";
  static const String invalidResetCode = "INVALID_RESET_CODE";
  static const String resetCodeNotFound = "RESET_CODE_NOT_FOUND";
  static const String tooManyResetAttempts = "TOO_MANY_RESET_ATTEMPTS";

  // ==================== JWT/Token Errors ====================
  static const String invalidTokenFormat = "INVALID_TOKEN_FORMAT";
  static const String tokenExpired = "TOKEN_EXPIRED";
  static const String invalidTokenSignature = "INVALID_TOKEN_SIGNATURE";
  static const String unauthorized = "UNAUTHORIZED";

  // ==================== Frontend-Specific Errors ====================
  /// This code is used for gallery/camera permission errors on the frontend
  static const String galleryPermissionError = "GALLERY_PERMISSION_ERROR";

  // ==================== Legacy (Deprecated - for backward compatibility) ====================
  @Deprecated('Use authenticationError instead')
  static String authenticationErrorCode = authenticationError;

  @Deprecated('Use unknownError instead')
  static String unknownErrorCode = unknownError;

  @Deprecated('Use galleryPermissionError instead')
  static String galleryPermissionErrorCode = galleryPermissionError;
}