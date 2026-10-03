import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_radius.dart';

/// Código de un solo uso en casillas. Solo dígitos; admite pegar el código completo
/// y avanza solo (un único campo oculto recibe la entrada).
class OtpField extends StatefulWidget {
  final int length;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;
  final bool hasError;

  const OtpField({
    super.key,
    this.length = 6,
    this.controller,
    this.onChanged,
    this.onCompleted,
    this.autofocus = false,
    this.hasError = false,
  });

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  TextEditingController? _ownController;
  final FocusNode _focusNode = FocusNode();

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
    _focusNode.addListener(_rebuild);
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _ownController?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = _controller.text;
    final activeIndex = text.length.clamp(0, widget.length - 1);

    return Stack(
      children: [
        Row(
          children: [
            for (var i = 0; i < widget.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _OtpBox(
                  digit: i < text.length ? text[i] : '',
                  active: _focusNode.hasFocus && i == activeIndex,
                  hasError: widget.hasError,
                  palette: p,
                ),
              ),
            ],
          ],
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              maxLength: widget.length,
              showCursor: false,
              enableInteractiveSelection: false,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              decoration: const InputDecoration(
                counterText: '',
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: _handleChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  final String digit;
  final bool active;
  final bool hasError;
  final AppPalette palette;

  const _OtpBox({
    required this.digit,
    required this.active,
    required this.hasError,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final borderColor = hasError ? p.danger : (active ? p.accent : null);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? p.surface : p.surface2,
        borderRadius: BorderRadius.circular(AppRadius.field),
        border: borderColor == null ? null : Border.all(color: borderColor, width: 1.5),
        boxShadow: [if (active) BoxShadow(color: p.accentSoft, spreadRadius: 4)],
      ),
      child: Text(
        digit,
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: p.ink),
      ),
    );
  }
}
