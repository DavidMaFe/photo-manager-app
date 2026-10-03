import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';


class LoginInputs extends StatefulWidget{

  final TextEditingController emailInputController;
  final TextEditingController passwordInputController;
  final bool enabled;

  const LoginInputs({
    super.key,
    required this.emailInputController,
    required this.passwordInputController,
    this.enabled = true
  });

  @override
  State<StatefulWidget> createState() => _LoginInputsState();
}

class _LoginInputsState extends State<LoginInputs> {

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.emailLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.palette.ink
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: widget.emailInputController,
          keyboardType: TextInputType.emailAddress,
          enabled: widget.enabled,

          validator: (value) {
            if(value == null || value.trim().isEmpty) {
              return l10n.errorEmailRequired;
            }

            if(!value.contains('@') || !value.contains('.')) {
              return l10n.errorInvalidEmail;
            }

            return null;
          },

          decoration: InputDecoration(
            hintText: l10n.emailPlaceholder,
            hintStyle: TextStyle(color: context.palette.ink3),
            filled: true,
            fillColor: context.palette.background,

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.danger, width: 2)
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.danger, width: 2)
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.line)
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.line)
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.accent, width: 2)
            ),

            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
          ),
        ),

        const SizedBox(height: 20),

        Text(
          l10n.passwordLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.palette.ink
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: widget.passwordInputController,
          obscureText: _obscurePassword,
          enabled: widget.enabled,

          validator: (value) {
            if(value == null || value.trim().isEmpty) {
              return l10n.errorPasswordRequired;
            }

            return null;
          },

          decoration: InputDecoration(
            hintText: "*********",
            hintStyle: TextStyle(color: context.palette.ink3),
            filled: true,
            fillColor: context.palette.background,

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.danger, width: 2)
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.danger, width: 2)
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.line)
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.line)
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.accent, width: 2)
            ),

            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: context.palette.ink2,
            ),

            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            })
          ),
        )
      ],
    );
  }
}