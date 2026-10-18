import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Color de la app que elige el usuario. Cambia solo la interfaz: el logo, el icono, el splash y los correos siguen
/// en el violeta de la marca.
///
/// Cada color es una familia completa para claro, oscuro y el visor, con el mismo contraste que el violeta:
/// - claro: texto blanco sobre [AccentColors.accent] ≥ 4,5:1; [AccentColors.accentInk] sobre el fondo y sobre
///   [AccentColors.accentSoft] ≥ 4,5:1;
/// - oscuro: texto blanco sobre [AccentColors.darkAccent] ≥ 3:1 (como el violeta) y [AccentColors.darkAccent] sobre el
///   fondo ≥ 4,5:1;
/// - visor: [AccentColors.mediaAccent] y [AccentColors.mediaCover] sobre negro ≥ 7:1.
///
/// Los colores de estado (verde «a salvo», ámbar «por revisar», rojo «eliminar» y rosa «favorita») no cambian, y
/// ningún color de la app se confunde con ellos.
enum AppAccent {
  violet(AccentColors(
    accent: AppColors.accent,
    accentInk: AppColors.accentInk,
    accentSoft: AppColors.accentSoft,
    darkAccent: AppColors.darkAccent,
    darkAccentInk: AppColors.darkAccentAlt,
    darkAccentSoft: AppColors.darkAccentSoft,
    mediaAccent: AppColors.mediaAccent,
    mediaCover: AppColors.mediaCover,
  )),
  blue(AccentColors(
    accent: Color(0xFF1F63D6),
    accentInk: Color(0xFF1A4FA8),
    accentSoft: Color(0xFFE5EEFC),
    darkAccent: Color(0xFF5692FF),
    darkAccentInk: Color(0xFFA9C7FF),
    darkAccentSoft: Color(0xFF17294A),
    mediaAccent: Color(0xFFA9C7FF),
    mediaCover: Color(0xFFCFE0FF),
  )),
  teal(AccentColors(
    accent: Color(0xFF0B7A84),
    accentInk: Color(0xFF095E66),
    accentSoft: Color(0xFFDFF3F4),
    darkAccent: Color(0xFF2CA3AE),
    darkAccentInk: Color(0xFF8ADFE7),
    darkAccentSoft: Color(0xFF0F383C),
    mediaAccent: Color(0xFF8ADFE7),
    mediaCover: Color(0xFFC4EFF3),
  )),
  terracotta(AccentColors(
    accent: Color(0xFFB9512B),
    accentInk: Color(0xFF93401F),
    accentSoft: Color(0xFFFBE9E2),
    darkAccent: Color(0xFFED7041),
    darkAccentInk: Color(0xFFF7B69B),
    darkAccentSoft: Color(0xFF43241A),
    mediaAccent: Color(0xFFF7B69B),
    mediaCover: Color(0xFFFFD8C8),
  )),
  graphite(AccentColors(
    accent: Color(0xFF3D3D47),
    accentInk: Color(0xFF2B2B33),
    accentSoft: Color(0xFFEBEBEF),
    darkAccent: Color(0xFF8C8C99),
    darkAccentInk: Color(0xFFCFCFD8),
    darkAccentSoft: Color(0xFF2A2A33),
    mediaAccent: Color(0xFFCFCFD8),
    mediaCover: Color(0xFFE2E2E8),
  ));

  final AccentColors colors;

  const AppAccent(this.colors);

  static const AppAccent defaultAccent = AppAccent.violet;

  /// The accent stored with [name], or the default one.
  static AppAccent fromName(String? name) =>
      values.firstWhere((accent) => accent.name == name, orElse: () => defaultAccent);
}

/// Tonos de un [AppAccent].
@immutable
class AccentColors {
  /// Claro: acción principal, texto o icono sobre fondo claro, y fondos suaves.
  final Color accent, accentInk, accentSoft;

  /// Oscuro: los mismos roles.
  final Color darkAccent, darkAccentInk, darkAccentSoft;

  /// Visor (igual en claro y oscuro): acción principal o activa, y «Portada de…».
  final Color mediaAccent, mediaCover;

  const AccentColors({
    required this.accent,
    required this.accentInk,
    required this.accentSoft,
    required this.darkAccent,
    required this.darkAccentInk,
    required this.darkAccentSoft,
    required this.mediaAccent,
    required this.mediaCover,
  });

  /// Pill behind «Portada de…» in the viewer: [darkAccent] at 24 % (alpha 0x3D, like [AppColors.mediaCoverSoft]).
  Color get mediaCoverSoft => darkAccent.withAlpha(0x3D);
}
