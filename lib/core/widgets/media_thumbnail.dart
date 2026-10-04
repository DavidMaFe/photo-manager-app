import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_radius.dart';

/// Miniatura de foto o vídeo con sus estados (por revisar, vídeo, selección).
///
/// Sustituye a FileThumbnailCard y TrashFileCard ([bottomLeftBadge] para la
/// pastilla de días de la papelera).
class MediaThumbnail extends StatelessWidget {
  static const _animation = Duration(milliseconds: 200);

  /// Imagen (p. ej. AuthenticatedImage con `BoxFit.cover`).
  final Widget image;
  final bool isPending;
  final bool isVideo;
  final Duration? videoDuration;

  /// Modo selección: muestra el círculo vacío o la marca de seleccionada.
  final bool selectable;
  final bool selected;

  /// Corazón blanco abajo a la izquierda (no se usa en la papelera).
  final bool isFavorite;

  /// Miniatura grande (2×2) de la rejilla: indicadores algo mayores.
  final bool large;
  final Widget? bottomLeftBadge;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Texto accesible (p. ej. «Foto, 1 oct»).
  final String? semanticLabel;

  const MediaThumbnail({
    super.key,
    required this.image,
    this.isPending = false,
    this.isVideo = false,
    this.videoDuration,
    this.selectable = false,
    this.selected = false,
    this.isFavorite = false,
    this.large = false,
    this.bottomLeftBadge,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = BorderRadius.circular(AppRadius.thumb);
    final isSelected = selectable && selected;
    // Indicators follow the image when it shrinks for the selection.
    final favoriteInset = (large ? 8.0 : 6.0) + (isSelected ? 7 : 0);

    return Semantics(
      label: semanticLabel,
      selected: selectable ? selected : null,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedPadding(
              duration: _animation,
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(isSelected ? 7 : 0),
              child: ClipRRect(
                borderRadius: radius,
                child: ColoredBox(color: p.surface2, child: image),
              ),
            ),
            if (isSelected)
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(color: p.accent, width: 3),
                  ),
                ),
              ),
            if (isVideo)
              Positioned(
                right: 6,
                bottom: 6,
                child: _VideoBadge(duration: videoDuration, palette: p),
              ),
            if (bottomLeftBadge != null)
              Positioned(left: 6, bottom: 6, child: bottomLeftBadge!)
            else if (isFavorite)
              AnimatedPositioned(
                duration: _animation,
                curve: Curves.easeOutCubic,
                left: favoriteInset,
                bottom: favoriteInset,
                child: _FavoriteMark(size: large ? 20 : 18, palette: p),
              ),
            if (selectable)
              Positioned(
                top: 6,
                right: 6,
                child: isSelected ? _SelectedMark(palette: p) : _SelectableMark(palette: p),
              )
            else if (isPending)
              Positioned(top: 6, right: 6, child: _PendingDot(palette: p)),
          ],
        ),
      ),
    );
  }

  /// «m:ss» o «h:mm:ss».
  static String formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
    }
    return '$minutes:$seconds';
  }
}

class _FavoriteMark extends StatelessWidget {
  final double size;
  final AppPalette palette;

  const _FavoriteMark({required this.size, required this.palette});

  @override
  Widget build(BuildContext context) {
    // Always white with a shadow so it reads on any photo.
    return Icon(
      Symbols.favorite_rounded,
      size: size,
      fill: 1,
      color: palette.onMedia,
      shadows: [Shadow(color: palette.media.withValues(alpha: 0.45), blurRadius: 4, offset: const Offset(0, 1))],
    );
  }
}

class _PendingDot extends StatelessWidget {
  final AppPalette palette;

  const _PendingDot({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: palette.review,
        shape: BoxShape.circle,
        border: Border.all(color: palette.onMedia, width: 2),
      ),
    );
  }
}

class _VideoBadge extends StatelessWidget {
  final Duration? duration;
  final AppPalette palette;

  const _VideoBadge({required this.duration, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 2, 7, 2),
      decoration: BoxDecoration(
        color: palette.scrim,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.play_arrow_rounded, size: 15, color: palette.onMedia, fill: 1),
          if (duration != null) ...[
            const SizedBox(width: 2),
            Text(
              MediaThumbnail.formatDuration(duration!),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: palette.onMedia),
            ),
          ],
        ],
      ),
    );
  }
}

class _SelectableMark extends StatelessWidget {
  final AppPalette palette;

  const _SelectableMark({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.scrim.withValues(alpha: 0.15),
        border: Border.all(color: palette.onMedia, width: 2),
      ),
    );
  }
}

class _SelectedMark extends StatelessWidget {
  final AppPalette palette;

  const _SelectedMark({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: palette.onMedia, shape: BoxShape.circle),
      child: Icon(Symbols.check_circle_rounded, size: 24, color: palette.accent, fill: 1),
    );
  }
}
