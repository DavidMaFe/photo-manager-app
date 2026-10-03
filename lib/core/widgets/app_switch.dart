import 'package:flutter/material.dart';

/// Interruptor de «Revelado» (track accent/line, thumb blanco, sin borde).
///
/// Los colores salen del `switchTheme` de AppTheme.
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Texto accesible del interruptor.
  final String? semanticLabel;

  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final control = Switch(
      value: value,
      onChanged: onChanged,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
    if (semanticLabel == null) return control;
    return Semantics(label: semanticLabel, child: control);
  }
}
