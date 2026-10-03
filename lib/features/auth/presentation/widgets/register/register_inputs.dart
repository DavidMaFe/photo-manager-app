import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';



class RegisterInputs extends StatefulWidget {

  final TextEditingController nameInputController;
  final TextEditingController surnameInputController;
  final TextEditingController emailInputController;
  final TextEditingController passwordInputController;
  final TextEditingController confirmPasswordInputController;
  final bool enabled;

  const RegisterInputs({
    super.key,
    required this.nameInputController,
    required this.surnameInputController,
    required this.emailInputController,
    required this.passwordInputController,
    required this.confirmPasswordInputController,
    this.enabled = true,
  });

  @override
  State<RegisterInputs> createState() => _RegisterInputsState();
}


class _RegisterInputsState extends State<RegisterInputs> {

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.nameLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.palette.ink
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.nameInputController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            enabled: widget.enabled,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.errorNameRequired;
              }
              return null;
            },
            decoration: _buildInputDecoration(
              hintText: l10n.namePlaceholder
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.surnameLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.palette.ink
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.surnameInputController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            enabled: widget.enabled,
            decoration: _buildInputDecoration(
              hintText: l10n.surnamePlaceholder
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.emailLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.palette.ink,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.emailInputController,
            keyboardType: TextInputType.emailAddress,
            enabled: widget.enabled,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.errorEmailRequired;
              }
              if (!value.contains('@') || !value.contains('.')) {
                return l10n.errorInvalidEmail;
              }
              return null;
            },
            decoration: _buildInputDecoration(
              hintText: l10n.emailPlaceholder,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.passwordLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.palette.ink,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.passwordInputController,
            obscureText: _obscurePassword,
            enabled: widget.enabled,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.errorPasswordRequired;
              }
              return null;
            },
            decoration: _buildInputDecoration(
              hintText: "*********",
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: context.palette.ink2,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.confirmPasswordLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.palette.ink,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.confirmPasswordInputController,
            obscureText: _obscureConfirmPassword,
            enabled: widget.enabled,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.errorConfirmPasswordRequired;
              }
              if (value != widget.passwordInputController.text) {
                return l10n.errorPasswordsDoNotMatch;
              }
              return null;
            },
            decoration: _buildInputDecoration(
              hintText: "*********",
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
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