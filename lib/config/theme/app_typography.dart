import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Tipografía de «Revelado»: Plus Jakarta Sans (empaquetada en assets/fonts).
class AppTypography {
  static const fontFamily = 'PlusJakartaSans';

  /// Roles principales mapeados sobre [TextTheme]:
  /// - screenTitle → headlineMedium (30/w800/-0.6)
  /// - title       → titleLarge (22/w700)
  /// - section     → titleMedium (17/w700)
  /// - body        → bodyLarge (15/w500)
  /// - label       → labelLarge (13/w700)
  /// - note        → bodySmall (12/w600/ink2)
  static TextTheme textTheme(AppPalette p) {
    return TextTheme(
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        height: 1.15,
        color: p.ink,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: p.ink,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: p.ink,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: p.ink,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: p.ink,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: p.ink2,
      ),
    );
  }

  /// Título de barra de pantalla secundaria (18/w800).
  static TextStyle secondaryBarTitle(AppPalette p) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: p.ink,
      );

  /// Etiqueta de la barra de navegación (11/w700; activa w800).
  static TextStyle navLabel(AppPalette p, {bool active = false}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: active ? FontWeight.w800 : FontWeight.w700,
        color: active ? p.accentInk : p.ink2,
      );

  /// Etiqueta de sección en mayúsculas («COPIA Y ESPACIO»): 12/w800/0.7/ink2.
  static TextStyle sectionLabel(AppPalette p) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.7,
        color: p.ink2,
      );
}
