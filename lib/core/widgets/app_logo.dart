import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_typography.dart';

/// Fondo sobre el que se dibuja el logo.
enum AppLogoVariant {
  /// Elige claro u oscuro según el brillo del tema.
  auto,

  /// Sobre fondo claro.
  onLight,

  /// Sobre fondo oscuro.
  onDark,

  /// Sobre el violeta de marca (símbolo y texto en blanco).
  onAccent,
}

/// Logo «Diafragma-nube» con logotipo opcional «Photo**Manager**».
class AppLogo extends StatelessWidget {
  static const markAsset = 'assets/branding/logo_mark.svg';
  static const markDarkAsset = 'assets/branding/logo_mark_dark.svg';
  static const markWhiteAsset = 'assets/branding/logo_mark_white.svg';
  static const markSmallAsset = 'assets/branding/logo_mark_small.svg';

  /// Por debajo de este alto se usa la versión simplificada del símbolo.
  static const smallMarkThreshold = 32.0;

  /// Proporción ancho/alto del símbolo (viewBox 78×56).
  static const markAspectRatio = 78 / 56;

  final double markHeight;
  final bool showWordmark;
  final AppLogoVariant variant;

  /// Horizontal (símbolo + texto en fila) o vertical (texto debajo, como en login).
  final Axis direction;

  /// Tamaño del logotipo; por defecto proporcional al símbolo.
  final double? wordmarkSize;

  const AppLogo({
    super.key,
    this.markHeight = 40,
    this.showWordmark = true,
    this.variant = AppLogoVariant.auto,
    this.direction = Axis.horizontal,
    this.wordmarkSize,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = _resolveVariant(context);
    final mark = SvgPicture.asset(
      _markAsset(resolved),
      height: markHeight,
      width: markHeight * markAspectRatio,
      excludeFromSemantics: true,
    );

    if (!showWordmark) {
      return Semantics(label: 'Photo Manager', image: true, child: mark);
    }

    final isHorizontal = direction == Axis.horizontal;
    final fontSize = wordmarkSize ?? (isHorizontal ? markHeight * 0.55 : 22.0);
    final gap = isHorizontal ? (markHeight * 0.3).clamp(10.0, 22.0) : 12.0;

    final children = <Widget>[
      mark,
      SizedBox(width: isHorizontal ? gap : 0, height: isHorizontal ? 0 : gap),
      _Wordmark(fontSize: fontSize, variant: resolved),
    ];

    return MergeSemantics(
      child: isHorizontal
          ? Row(mainAxisSize: MainAxisSize.min, children: children)
          : Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  AppLogoVariant _resolveVariant(BuildContext context) {
    if (variant != AppLogoVariant.auto) return variant;
    return Theme.of(context).brightness == Brightness.dark
        ? AppLogoVariant.onDark
        : AppLogoVariant.onLight;
  }

  String _markAsset(AppLogoVariant resolved) {
    if (resolved == AppLogoVariant.onAccent) return markWhiteAsset;
    if (markHeight < smallMarkThreshold) return markSmallAsset;
    return resolved == AppLogoVariant.onDark ? markDarkAsset : markAsset;
  }
}

class _Wordmark extends StatelessWidget {
  final double fontSize;
  final AppLogoVariant variant;

  const _Wordmark({required this.fontSize, required this.variant});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final onAccent = variant == AppLogoVariant.onAccent;
    final white = Theme.of(context).colorScheme.onPrimary;

    final style = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.03 * fontSize,
      height: 1.1,
    );

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: 'Photo', style: TextStyle(color: onAccent ? white : palette.ink)),
          TextSpan(text: 'Manager', style: TextStyle(color: onAccent ? white : palette.accent)),
        ],
      ),
      maxLines: 1,
    );
  }
}
