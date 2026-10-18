import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/app_accent.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage UI-related user preferences
class UiPreferencesService {
  static const String _keyDontShowLocalDeletionWarning = 'dont_show_local_deletion_warning';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyAccent = 'app_accent';

  final SharedPreferences _prefs;

  /// Current theme mode; MyApp listens to it to rebuild the MaterialApp.
  final ValueNotifier<ThemeMode> themeMode;

  /// Color of the app chosen by the user (on this phone); MyApp listens to it to rebuild the MaterialApp.
  final ValueNotifier<AppAccent> accent;

  UiPreferencesService(this._prefs)
      : themeMode = ValueNotifier(_parseThemeMode(_prefs.getString(_keyThemeMode))),
        accent = ValueNotifier(AppAccent.fromName(_prefs.getString(_keyAccent)));

  /// Check if user wants to hide the local deletion warning dialog
  bool get shouldHideLocalDeletionWarning {
    return _prefs.getBool(_keyDontShowLocalDeletionWarning) ?? false;
  }

  /// Set whether to hide the local deletion warning dialog
  Future<void> setHideLocalDeletionWarning(bool hide) async {
    await _prefs.setBool(_keyDontShowLocalDeletionWarning, hide);
  }

  /// Persist the selected theme mode and notify listeners
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _prefs.setString(_keyThemeMode, mode.name);
  }

  /// Persist the chosen color of the app and apply it at once.
  Future<void> setAccent(AppAccent value) async {
    accent.value = value;
    await _prefs.setString(_keyAccent, value.name);
  }

  static ThemeMode _parseThemeMode(String? value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}
