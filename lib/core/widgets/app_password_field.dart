import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../config/theme/app_palette.dart';
import 'app_text_field.dart';

/// [AppTextField] para contraseñas con botón de mostrar/ocultar.
class AppPasswordField extends StatefulWidget {
  final String? label;
  final Widget? labelTrailing;
  final TextEditingController? controller;
  final String? hintText;
  final bool enabled;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  /// Textos accesibles del botón del ojo.
  final String showTooltip;
  final String hideTooltip;

  const AppPasswordField({
    super.key,
    this.label,
    this.labelTrailing,
    this.controller,
    this.hintText,
    this.enabled = true,
    this.textInputAction,
    this.autofillHints = const [AutofillHints.password],
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    required this.showTooltip,
    required this.hideTooltip,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      labelTrailing: widget.labelTrailing,
      controller: widget.controller,
      hintText: widget.hintText,
      enabled: widget.enabled,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      suffixIcon: IconButton(
        tooltip: _obscure ? widget.showTooltip : widget.hideTooltip,
        icon: Icon(
          _obscure ? Symbols.visibility_off_rounded : Symbols.visibility_rounded,
          color: context.palette.ink2,
          size: 22,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
