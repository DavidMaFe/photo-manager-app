import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_typography.dart';

/// Etiqueta de sección en mayúsculas («COPIA Y ESPACIO»).
class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const SectionLabel(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(24, 22, 24, 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Semantics(
        header: true,
        child: Text(text.toUpperCase(), style: AppTypography.sectionLabel(context.palette)),
      ),
    );
  }
}
