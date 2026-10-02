import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Roles de color de «Revelado» que no caben en [ColorScheme].
///
/// Acceso desde widgets: `context.palette.accent`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background, surface, surface2, line, lineSoft;
  final Color ink, ink2, ink3;
  final Color accent, accentInk, accentSoft;
  final Color review, reviewInk, reviewSoft, reviewIcon;
  final Color safe, safeInk, safeSoft;
  final Color danger, dangerInk, dangerSoft;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.line,
    required this.lineSoft,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.accent,
    required this.accentInk,
    required this.accentSoft,
    required this.review,
    required this.reviewInk,
    required this.reviewSoft,
    required this.reviewIcon,
    required this.safe,
    required this.safeInk,
    required this.safeSoft,
    required this.danger,
    required this.dangerInk,
    required this.dangerSoft,
  });

  static const light = AppPalette(
    background: AppColors.background,
    surface: AppColors.surface,
    surface2: AppColors.surface2,
    line: AppColors.line,
    lineSoft: AppColors.lineSoft,
    ink: AppColors.ink,
    ink2: AppColors.ink2,
    ink3: AppColors.ink3,
    accent: AppColors.accent,
    accentInk: AppColors.accentInk,
    accentSoft: AppColors.accentSoft,
    review: AppColors.review,
    reviewInk: AppColors.reviewInk,
    reviewSoft: AppColors.reviewSoft,
    reviewIcon: AppColors.reviewIcon,
    safe: AppColors.safe,
    safeInk: AppColors.safeInk,
    safeSoft: AppColors.safeSoft,
    danger: AppColors.danger,
    dangerInk: AppColors.dangerInk,
    dangerSoft: AppColors.dangerSoft,
  );

  static const dark = AppPalette(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surface2: AppColors.darkSurface2,
    line: AppColors.darkLine,
    lineSoft: AppColors.darkSurface2,
    ink: AppColors.darkInk,
    ink2: AppColors.darkInk2,
    ink3: AppColors.ink3,
    accent: AppColors.darkAccent,
    accentInk: AppColors.darkAccentAlt,
    accentSoft: AppColors.darkAccentSoft,
    review: AppColors.review,
    reviewInk: AppColors.reviewInk,
    reviewSoft: AppColors.reviewSoft,
    reviewIcon: AppColors.reviewIcon,
    safe: AppColors.safe,
    safeInk: AppColors.safeInk,
    safeSoft: AppColors.safeSoft,
    danger: AppColors.danger,
    dangerInk: AppColors.darkDanger,
    dangerSoft: AppColors.dangerSoft,
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surface2,
    Color? line,
    Color? lineSoft,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? accent,
    Color? accentInk,
    Color? accentSoft,
    Color? review,
    Color? reviewInk,
    Color? reviewSoft,
    Color? reviewIcon,
    Color? safe,
    Color? safeInk,
    Color? safeSoft,
    Color? danger,
    Color? dangerInk,
    Color? dangerSoft,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      line: line ?? this.line,
      lineSoft: lineSoft ?? this.lineSoft,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      accentSoft: accentSoft ?? this.accentSoft,
      review: review ?? this.review,
      reviewInk: reviewInk ?? this.reviewInk,
      reviewSoft: reviewSoft ?? this.reviewSoft,
      reviewIcon: reviewIcon ?? this.reviewIcon,
      safe: safe ?? this.safe,
      safeInk: safeInk ?? this.safeInk,
      safeSoft: safeSoft ?? this.safeSoft,
      danger: danger ?? this.danger,
      dangerInk: dangerInk ?? this.dangerInk,
      dangerSoft: dangerSoft ?? this.dangerSoft,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      line: l(line, other.line),
      lineSoft: l(lineSoft, other.lineSoft),
      ink: l(ink, other.ink),
      ink2: l(ink2, other.ink2),
      ink3: l(ink3, other.ink3),
      accent: l(accent, other.accent),
      accentInk: l(accentInk, other.accentInk),
      accentSoft: l(accentSoft, other.accentSoft),
      review: l(review, other.review),
      reviewInk: l(reviewInk, other.reviewInk),
      reviewSoft: l(reviewSoft, other.reviewSoft),
      reviewIcon: l(reviewIcon, other.reviewIcon),
      safe: l(safe, other.safe),
      safeInk: l(safeInk, other.safeInk),
      safeSoft: l(safeSoft, other.safeSoft),
      danger: l(danger, other.danger),
      dangerInk: l(dangerInk, other.dangerInk),
      dangerSoft: l(dangerSoft, other.dangerSoft),
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
