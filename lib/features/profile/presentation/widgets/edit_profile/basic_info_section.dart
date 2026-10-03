import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Name and last name fields.
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l10n.nameLabel,
          controller: nameController,
          hintText: l10n.namePlaceholder,
          enabled: enabled,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.errorNameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: l10n.surnameShortLabel,
          labelNote: l10n.optionalLabel,
          controller: surnameController,
          hintText: l10n.surnamePlaceholder,
          enabled: enabled,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}
