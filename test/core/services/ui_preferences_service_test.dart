import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/services/ui_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UiPreferencesService', () {
    Future<UiPreferencesService> buildService(Map<String, Object> values) async {
      SharedPreferences.setMockInitialValues(values);
      return UiPreferencesService(await SharedPreferences.getInstance());
    }

    group('themeMode', () {
      test('should default to system when nothing is stored', () async {
        // Arrange
        final service = await buildService({});

        // Act
        final mode = service.themeMode.value;

        // Assert
        expect(mode, ThemeMode.system);
      });

      test('should restore the stored theme mode', () async {
        // Arrange
        final service = await buildService({'theme_mode': 'dark'});

        // Act
        final mode = service.themeMode.value;

        // Assert
        expect(mode, ThemeMode.dark);
      });

      test('should fall back to system when stored value is unknown', () async {
        // Arrange
        final service = await buildService({'theme_mode': 'sepia'});

        // Act
        final mode = service.themeMode.value;

        // Assert
        expect(mode, ThemeMode.system);
      });
    });

    group('setThemeMode', () {
      test('should persist the mode and notify listeners', () async {
        // Arrange
        final service = await buildService({});
        ThemeMode? notified;
        service.themeMode.addListener(() => notified = service.themeMode.value);

        // Act
        await service.setThemeMode(ThemeMode.light);

        // Assert
        expect(notified, ThemeMode.light);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('theme_mode'), 'light');
      });
    });

    group('shouldHideLocalDeletionWarning', () {
      test('should return stored value after setting it', () async {
        // Arrange
        final service = await buildService({});

        // Act
        await service.setHideLocalDeletionWarning(true);

        // Assert
        expect(service.shouldHideLocalDeletionWarning, isTrue);
      });
    });
  });
}
