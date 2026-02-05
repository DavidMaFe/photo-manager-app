import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage UI-related user preferences
class UiPreferencesService {
  static const String _keyDontShowLocalDeletionWarning = 'dont_show_local_deletion_warning';

  final SharedPreferences _prefs;

  UiPreferencesService(this._prefs);

  /// Check if user wants to hide the local deletion warning dialog
  bool get shouldHideLocalDeletionWarning {
    return _prefs.getBool(_keyDontShowLocalDeletionWarning) ?? false;
  }

  /// Set whether to hide the local deletion warning dialog
  Future<void> setHideLocalDeletionWarning(bool hide) async {
    await _prefs.setBool(_keyDontShowLocalDeletionWarning, hide);
  }
}
