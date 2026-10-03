import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';


class ResetPasswordInputs extends StatefulWidget {

  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool enabled;

  const ResetPasswordInputs({
    super.key,
    required this.newPasswordController,
    required this.confirmPasswordController,
    this.enabled = true
  });

  @override
  State<ResetPasswordInputs> createState() => _ResetPasswordInputsState();
}


class _ResetPasswordInputsState extends State<ResetPasswordInputs> {

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.newPasswordLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.palette.ink
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: widget.newPasswordController,
          obscureText: _obscureNewPassword,
          enabled: widget.enabled,

          validator: (value) {
            if(value == null || value.trim().isEmpty) {
              return l10n.errorNewPasswordRequired;
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

            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                color: context.palette.ink2,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              }
            )
          ),
        ),

        const SizedBox(height: 20),

        Text(
          l10n.confirmNewPasswordLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.palette.ink
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: widget.confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          enabled: widget.enabled,

          validator: (value) {
            if(value == null || value.trim().isEmpty) {
              return l10n.errorConfirmPasswordRequired;
            }

            if(value != widget.newPasswordController.text) {
              return l10n.errorPasswordsDoNotMatch;
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

            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: context.palette.ink2,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              }
            )
          ),
        )
      ],
    );
  }
}