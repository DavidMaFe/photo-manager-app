import 'package:flutter/cupertino.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';
import '../base/failures.dart';


class FailureMessageHelper {

  /// Gets the error message using hybrid localization:
  /// 1. First priority: Use backend-provided message (from errorResponse)
  /// 2. Fallback: Use Flutter localization (ARB files)
  static String getMessage(BuildContext context, Failure failure) {
    // Priority 1: Use backend message if available
    if (failure.errorResponse != null && failure.errorResponse!.message.isNotEmpty) {
      return failure.errorResponse!.message;
    }

    // Priority 2: Fallback to Flutter localization
    final l10n = AppLocalizations.of(context)!;
    return _getLocalizedMessage(l10n, failure);
  }

  static String getTitle(BuildContext context, Failure failure) {
    final l10n = AppLocalizations.of(context)!;

    if (failure is NetworkFailure) return l10n.errorNetworkTitle;
    if (failure is ServerFailure) return l10n.errorServerTitle;
    if (failure is ValidationFailure) return l10n.errorValidationTitle;
    if (failure is UnauthorizedFailure) return l10n.errorUnauthorizedTitle;
    if (failure is NotFoundFailure) return l10n.errorNotFoundTitle;
    if (failure is StorageSpaceExceededFailure) return l10n.errorStorageSpaceExceededTitle;
    if (failure is ConcurrencyFailure) return l10n.syncInProgressErrorTitle;

    return l10n.errorUnknown;
  }

  static String _getLocalizedMessage(AppLocalizations l10n, Failure failure) {
    switch (failure.messageKey) {
    // Network
      case 'errorNetwork':
        return l10n.errorNetwork;
      case 'errorServer':
        return l10n.errorServer;
      case 'errorTimeout':
        return l10n.errorTimeout;

    // Auth
      case 'errorUnauthorized':
        return l10n.errorUnauthorized;
      case 'errorInvalidCredentials':
        return l10n.errorInvalidCredentials;
      case 'errorTokenExpired':
        return l10n.errorTokenExpired;

    // Validation
      case 'errorValidation':
        return l10n.errorValidation;
      case 'errorInvalidEmail':
        return l10n.errorInvalidEmail;
      case 'errorPasswordMismatch':
        return l10n.errorPasswordMismatch;
      case 'errorRequiredField':
        final fieldName = failure.messageParams?['fieldName'] as String? ?? '';
        return l10n.errorRequiredField(fieldName);

    // Data
      case 'errorNotFound':
        return l10n.errorNotFound;
      case 'errorAlreadyExists':
        return l10n.errorAlreadyExists;
      case 'errorEmailAlreadyExists':
        return l10n.errorEmailAlreadyExists;
      case 'errorCache':
        return l10n.errorCache;

    // Permission
      case 'errorStorageQuotaExceeded':
        return l10n.errorStorageSpaceExceeded;
      case 'errorPermissionDenied':
        return l10n.errorPermissionDenied;

    // Sync
      case 'syncInProgressError':
        return l10n.syncInProgressError;

    // End-to-end encryption
      case 'errorRecoveryPhraseMismatch':
        return l10n.errorRecoveryPhraseMismatch;
      case 'errorInvalidRecoveryPhrase':
        return l10n.errorInvalidRecoveryPhrase;
      case 'errorWeakPassword':
        return l10n.errorWeakPassword(failure.messageParams?['min'] as int? ?? 10);
      case 'errorMissingDeviceKey':
        return l10n.errorMissingDeviceKey;
      case 'errorKeyUnlock':
        return l10n.errorKeyUnlock;
      case 'errorDeviceAuthentication':
        return l10n.errorDeviceAuthentication;
      case 'errorLegalTermsNotAccepted':
        return l10n.errorLegalTermsNotAccepted;

    // Generic
      case 'errorUnknown':
      default:
        return l10n.errorUnknown;
    }
  }

  static String? getFormattedCode(BuildContext context, String? code) {
    if (code == null) return null;
    final l10n = AppLocalizations.of(context)!;
    return l10n.errorCode(code);
  }
}