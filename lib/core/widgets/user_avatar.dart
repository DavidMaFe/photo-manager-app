import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';

/// Avatar circular con foto o iniciales sobre accent.
class UserAvatar extends StatelessWidget {
  final String name;
  final String? surname;
  final double size;
  /// Foto (p. ej. AuthenticatedImage); si no hay, se muestran las iniciales.
  final Widget? photo;
  final VoidCallback? onTap;

  /// Texto accesible (p. ej. «Abrir perfil»).
  final String? semanticLabel;

  const UserAvatar({
    super.key,
    required this.name,
    this.surname,
    this.size = 36,
    this.photo,
    this.onTap,
    this.semanticLabel,
  });

  /// Hasta dos iniciales en mayúscula: nombre + apellido, o las dos primeras
  /// palabras del nombre.
  static String initialsOf(String name, [String? surname]) {
    final words = [
      ...name.trim().split(RegExp(r'\s+')),
      if (surname != null) ...surname.trim().split(RegExp(r'\s+')),
    ].where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    final first = words.first.characters.first;
    final second = words.length > 1 ? words[1].characters.first : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
      child: photo != null
          ? SizedBox.square(dimension: size, child: photo)
          : Text(
              initialsOf(name, surname),
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w800,
                color: p.onAccent,
              ),
            ),
    );

    final content = Semantics(
      label: semanticLabel ?? '$name ${surname ?? ''}'.trim(),
      button: onTap != null,
      excludeSemantics: true,
      child: avatar,
    );
    if (onTap == null) return content;

    // Keeps a 44 px touch target around small avatars.
    return Tooltip(
      message: semanticLabel ?? name,
      child: InkResponse(
        onTap: onTap,
        radius: size / 2 + 6,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Center(widthFactor: 1, heightFactor: 1, child: content),
        ),
      ),
    );
  }
}
