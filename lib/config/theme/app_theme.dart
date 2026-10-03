import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Temas claro y oscuro de «Revelado».
class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppPalette.light);
  static ThemeData dark() => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness b, AppPalette p) {
    final scheme = ColorScheme(
      brightness: b,
      primary: p.accent,
      onPrimary: p.onAccent,
      primaryContainer: p.accentSoft,
      onPrimaryContainer: p.accentInk,
      secondary: p.accent,
      onSecondary: p.onAccent,
      error: p.danger,
      onError: p.onAccent,
      surface: p.surface,
      onSurface: p.ink,
      surfaceContainerHighest: p.surface2,
      onSurfaceVariant: p.ink2,
      outline: p.line,
      outlineVariant: p.lineSoft,
    );
    final text = AppTypography.textTheme(p);

    const buttonTextStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );
    final largeButtonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );
    const largeButtonSize = Size(64, 54);

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide.none,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      textTheme: text,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: p.ink,
        titleTextStyle: AppTypography.secondaryBarTitle(p),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: Colors.white,
          minimumSize: largeButtonSize,
          shape: largeButtonShape,
          textStyle: buttonTextStyle,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: largeButtonSize,
          shape: largeButtonShape,
          textStyle: buttonTextStyle,
        ),
      ),
      // No usar en pantallas nuevas: se mapea al botón secundario.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: p.accentSoft,
          foregroundColor: p.accentInk,
          side: BorderSide.none,
          minimumSize: largeButtonSize,
          shape: largeButtonShape,
          textStyle: buttonTextStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accentInk,
          textStyle: buttonTextStyle,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        disabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: p.danger, width: 1.5),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: p.danger, width: 1.5),
        ),
        hintStyle: TextStyle(color: p.ink3),
        labelStyle: TextStyle(color: p.ink2),
        errorStyle: TextStyle(
          color: p.dangerInk,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.accent : p.line,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbIcon: const WidgetStatePropertyAll(null),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        showCheckmark: false,
        color: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.ink : p.surface2,
        ),
        labelStyle: WidgetStateTextStyle.resolveWith(
          (states) => TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected) ? p.background : p.ink,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.line,
        dragHandleSize: const Size(40, 5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: p.ink,
        ),
        contentTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: p.ink2,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.ink,
        actionTextColor: p.accentSoft,
        contentTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: p.background,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accent,
        linearTrackColor: p.accentSoft,
      ),
      dividerTheme: DividerThemeData(color: p.lineSoft, thickness: 1, space: 1),
    );
  }
}
