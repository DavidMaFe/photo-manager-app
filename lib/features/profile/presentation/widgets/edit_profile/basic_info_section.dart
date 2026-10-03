import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class BasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final bool enabled;

  const BasicInfoSection({
    super.key,
    required this.nameController,
    required this.surnameController,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.basicInfoSection,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.nameLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: nameController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          enabled: enabled,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.errorNameRequired;
            }
            return null;
          },
          decoration: _buildInputDecoration(context, 
            hintText: l10n.namePlaceholder,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.surnameLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: surnameController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          enabled: enabled,
          decoration: _buildInputDecoration(context, 
            hintText: l10n.surnamePlaceholder,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context, {
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
