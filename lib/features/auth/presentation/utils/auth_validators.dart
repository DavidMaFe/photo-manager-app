import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Form validators shared by the auth screens.
class AuthValidators {
  static String? email(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.errorEmailRequired;
    }
    if (!value.contains('@') || !value.contains('.')) {
      return l10n.errorInvalidEmail;
    }
    return null;
  }

  static String? password(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.errorPasswordRequired;
    }
    return null;
  }

  static String? confirmation(AppLocalizations l10n, String? value, String password) {
    if (value == null || value.isEmpty) {
      return l10n.errorConfirmPasswordRequired;
    }
    if (value != password) {
      return l10n.errorPasswordsDoNotMatch;
    }
    return null;
  }
}
