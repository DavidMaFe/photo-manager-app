import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class PasswordChangeSection extends StatefulWidget {
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool enabled;

  const PasswordChangeSection({
    super.key,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    this.enabled = true,
  });

  @override
  State<PasswordChangeSection> createState() => _PasswordChangeSectionState();
}

class _PasswordChangeSectionState extends State<PasswordChangeSection> {
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.passwordSection,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.leavePasswordEmptyHint,
          style: TextStyle(
            fontSize: 14,
            color: context.palette.ink2,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.currentPasswordLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.currentPasswordController,
          obscureText: _obscureCurrentPassword,
          enabled: widget.enabled,
          validator: (value) {
            // Only validate if user is trying to change password
            if (widget.newPasswordController.text.isNotEmpty ||
                widget.confirmPasswordController.text.isNotEmpty) {
              if (value == null || value.isEmpty) {
                return l10n.errorCurrentPasswordRequired;
              }
            }
            return null;
          },
          decoration: _buildInputDecoration(
            hintText: l10n.currentPasswordPlaceholder,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                color: context.palette.ink2,
              ),
              onPressed: () {
                setState(() {
                  _obscureCurrentPassword = !_obscureCurrentPassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.newPasswordLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.newPasswordController,
          obscureText: _obscureNewPassword,
          enabled: widget.enabled,
          validator: (value) {
            // Only validate if user entered current password
            if (widget.currentPasswordController.text.isNotEmpty) {
              if (value == null || value.isEmpty) {
                return l10n.errorNewPasswordRequired;
              }
            }
            return null;
          },
          decoration: _buildInputDecoration(
            hintText: "*********",
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                color: context.palette.ink2,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.confirmNewPasswordLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          enabled: widget.enabled,
          validator: (value) {
            // Only validate if user entered new password
            if (widget.newPasswordController.text.isNotEmpty) {
              if (value == null || value.isEmpty) {
                return l10n.errorConfirmPasswordRequired;
              }
              if (value != widget.newPasswordController.text) {
                return l10n.errorPasswordsDoNotMatch;
              }
            }
            return null;
          },
          decoration: _buildInputDecoration(
            hintText: "*********",
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: context.palette.ink2,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: context.palette.ink3),
      filled: true,
      fillColor: context.palette.background,
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.palette.danger, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.palette.danger, width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.palette.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.palette.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.palette.accent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
    );
  }
}
