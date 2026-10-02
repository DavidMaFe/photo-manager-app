import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage UI-related user preferences
class UiPreferencesService {
  static const String _keyDontShowLocalDeletionWarning = 'dont_show_local_deletion_warning';
  static const String _keyThemeMode = 'theme_mode';

  final SharedPreferences _prefs;

  /// Current theme mode; MyApp listens to it to rebuild the MaterialApp.
  final ValueNotifier<ThemeMode> themeMode;

  UiPreferencesService(this._prefs)
      : themeMode = ValueNotifier(_parseThemeMode(_prefs.getString(_keyThemeMode)));

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

  static ThemeMode _parseThemeMode(String? value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}
