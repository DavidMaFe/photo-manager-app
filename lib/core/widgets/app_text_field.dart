import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_radius.dart';

/// Campo de texto con etiqueta encima. Sustituye a las `InputDecoration` duplicadas.
///
/// Enfocado: fondo surface, borde accent 1.5 y halo accentSoft.
/// Error: borde danger y texto dangerInk debajo (del `inputDecorationTheme`).
class AppTextField extends StatefulWidget {
  final String? label;

  /// Nota corta junto a la etiqueta en ink2 (p. ej. «(opcional)»).
  final String? labelNote;

  /// Widget alineado a la derecha en la línea de la etiqueta (p. ej. «¿La has olvidado?»).
  final Widget? labelTrailing;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final AutovalidateMode? autovalidateMode;

  const AppTextField({
    super.key,
    this.label,
    this.labelNote,
    this.labelTrailing,
    this.controller,
    this.focusNode,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autovalidateMode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  FocusNode? _ownFocusNode;
  bool _focused = false;

  FocusNode get _focusNode => widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChange);
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final field = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.field),
        boxShadow: [
          if (_focused) BoxShadow(color: p.accentSoft, spreadRadius: 4),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        autofillHints: widget.autofillHints,
        inputFormatters: widget.inputFormatters,
        maxLength: widget.maxLength,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onFieldSubmitted,
        autovalidateMode: widget.autovalidateMode,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: p.ink),
        decoration: InputDecoration(
          hintText: widget.hintText,
          errorText: widget.errorText,
          errorMaxLines: 3,
          fillColor: _focused ? p.surface : p.surface2,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          counterText: '',
        ),
      ),
    );

    if (widget.label == null && widget.labelTrailing == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (widget.label != null)
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: widget.label!,
                    children: [
                      if (widget.labelNote != null)
                        TextSpan(
                          text: ' ${widget.labelNote!}',
                          style: TextStyle(fontWeight: FontWeight.w600, color: p.ink2),
                        ),
                    ],
                  ),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink),
                ),
              )
            else
              const Spacer(),
            if (widget.labelTrailing != null) widget.labelTrailing!,
          ],
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
