import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Roles de color de «Revelado» que no caben en [ColorScheme].
///
/// Acceso desde widgets: `context.palette.accent`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background, surface, surface2, line, lineSoft;
  final Color ink, ink2, ink3;
  final Color accent, accentInk, accentSoft, onAccent;
  final Color review, reviewInk, reviewSoft, reviewIcon, onReview;
  final Color safe, safeInk, safeSoft;
  final Color danger, dangerInk, dangerSoft;
  final Color favorite, favoriteInk;
  final Color shadow, shadowSoft;
  final Color media, onMedia, scrim;
  final Color mediaChrome, mediaChromeRaised, onMediaMuted, mediaDanger, mediaReview;

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
    required this.onAccent,
    required this.review,
    required this.reviewInk,
    required this.reviewSoft,
    required this.reviewIcon,
    required this.onReview,
    required this.safe,
    required this.safeInk,
    required this.safeSoft,
    required this.danger,
    required this.dangerInk,
    required this.dangerSoft,
    required this.favorite,
    required this.favoriteInk,
    required this.shadow,
    required this.shadowSoft,
    required this.media,
    required this.onMedia,
    required this.scrim,
    required this.mediaChrome,
    required this.mediaChromeRaised,
    required this.onMediaMuted,
    required this.mediaDanger,
    required this.mediaReview,
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
    onAccent: AppColors.onAccent,
    review: AppColors.review,
    reviewInk: AppColors.reviewInk,
    reviewSoft: AppColors.reviewSoft,
    reviewIcon: AppColors.reviewIcon,
    onReview: AppColors.onReview,
    safe: AppColors.safe,
    safeInk: AppColors.safeInk,
    safeSoft: AppColors.safeSoft,
    danger: AppColors.danger,
    dangerInk: AppColors.dangerInk,
    dangerSoft: AppColors.dangerSoft,
    favorite: AppColors.favorite,
    favoriteInk: AppColors.favoriteInk,
    shadow: AppColors.shadow,
    shadowSoft: AppColors.shadowSoft,
    media: AppColors.media,
    onMedia: AppColors.onMedia,
    scrim: AppColors.scrim,
    mediaChrome: AppColors.mediaChrome,
    mediaChromeRaised: AppColors.mediaChromeRaised,
    onMediaMuted: AppColors.onMediaMuted,
    mediaDanger: AppColors.mediaDanger,
    mediaReview: AppColors.mediaReview,
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
    onAccent: AppColors.onAccent,
    review: AppColors.review,
    reviewInk: AppColors.darkReviewInk,
    reviewSoft: AppColors.darkReviewSoft,
    reviewIcon: AppColors.reviewIcon,
    onReview: AppColors.onReview,
    safe: AppColors.safe,
    safeInk: AppColors.darkSafeInk,
    safeSoft: AppColors.darkSafeSoft,
    danger: AppColors.danger,
    dangerInk: AppColors.darkDanger,
    dangerSoft: AppColors.darkDangerSoft,
    favorite: AppColors.darkFavorite,
    favoriteInk: AppColors.favoriteInk,
    shadow: AppColors.darkShadow,
    shadowSoft: AppColors.darkShadowSoft,
    media: AppColors.media,
    onMedia: AppColors.onMedia,
    scrim: AppColors.scrim,
    mediaChrome: AppColors.mediaChrome,
    mediaChromeRaised: AppColors.mediaChromeRaised,
    onMediaMuted: AppColors.onMediaMuted,
    mediaDanger: AppColors.mediaDanger,
    mediaReview: AppColors.mediaReview,
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
    Color? onAccent,
    Color? review,
    Color? reviewInk,
    Color? reviewSoft,
    Color? reviewIcon,
    Color? onReview,
    Color? safe,
    Color? safeInk,
    Color? safeSoft,
    Color? danger,
    Color? dangerInk,
    Color? dangerSoft,
    Color? favorite,
    Color? favoriteInk,
    Color? shadow,
    Color? shadowSoft,
    Color? media,
    Color? onMedia,
    Color? scrim,
    Color? mediaChrome,
    Color? mediaChromeRaised,
    Color? onMediaMuted,
    Color? mediaDanger,
    Color? mediaReview,
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
      onAccent: onAccent ?? this.onAccent,
      review: review ?? this.review,
      reviewInk: reviewInk ?? this.reviewInk,
      reviewSoft: reviewSoft ?? this.reviewSoft,
      reviewIcon: reviewIcon ?? this.reviewIcon,
      onReview: onReview ?? this.onReview,
      safe: safe ?? this.safe,
      safeInk: safeInk ?? this.safeInk,
      safeSoft: safeSoft ?? this.safeSoft,
      danger: danger ?? this.danger,
      dangerInk: dangerInk ?? this.dangerInk,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      favorite: favorite ?? this.favorite,
      favoriteInk: favoriteInk ?? this.favoriteInk,
      shadow: shadow ?? this.shadow,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      media: media ?? this.media,
      onMedia: onMedia ?? this.onMedia,
      scrim: scrim ?? this.scrim,
      mediaChrome: mediaChrome ?? this.mediaChrome,
      mediaChromeRaised: mediaChromeRaised ?? this.mediaChromeRaised,
      onMediaMuted: onMediaMuted ?? this.onMediaMuted,
      mediaDanger: mediaDanger ?? this.mediaDanger,
      mediaReview: mediaReview ?? this.mediaReview,
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
      onAccent: l(onAccent, other.onAccent),
      review: l(review, other.review),
      reviewInk: l(reviewInk, other.reviewInk),
      reviewSoft: l(reviewSoft, other.reviewSoft),
      reviewIcon: l(reviewIcon, other.reviewIcon),
      onReview: l(onReview, other.onReview),
      safe: l(safe, other.safe),
      safeInk: l(safeInk, other.safeInk),
      safeSoft: l(safeSoft, other.safeSoft),
      danger: l(danger, other.danger),
      dangerInk: l(dangerInk, other.dangerInk),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      favorite: l(favorite, other.favorite),
      favoriteInk: l(favoriteInk, other.favoriteInk),
      shadow: l(shadow, other.shadow),
      shadowSoft: l(shadowSoft, other.shadowSoft),
      media: l(media, other.media),
      onMedia: l(onMedia, other.onMedia),
      scrim: l(scrim, other.scrim),
      mediaChrome: l(mediaChrome, other.mediaChrome),
      mediaChromeRaised: l(mediaChromeRaised, other.mediaChromeRaised),
      onMediaMuted: l(onMediaMuted, other.onMediaMuted),
      mediaDanger: l(mediaDanger, other.mediaDanger),
      mediaReview: l(mediaReview, other.mediaReview),
    );
  }
}

extension AppPaletteX on BuildContext {
  /// Paleta del tema actual. Si el tema no la registra (p. ej. un MaterialApp
  /// sin AppTheme), se usa la paleta por defecto según el brillo.
  AppPalette get palette {
    final theme = Theme.of(this);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark ? AppPalette.dark : AppPalette.light);
  }

  /// Paleta del modo contrario, para contenido sobre superficies invertidas
  /// (snackbar oscuro en modo claro y viceversa).
  AppPalette get inversePalette =>
      Theme.of(this).brightness == Brightness.dark ? AppPalette.light : AppPalette.dark;
}
