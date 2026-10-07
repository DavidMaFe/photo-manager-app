import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Text area for the 24 words, typed or pasted, separated by spaces or new lines.
class RecoveryWordsInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const RecoveryWordsInput({super.key, required this.controller, this.enabled = true});

  /// Words of the text, without empty entries or numbers ("1. abandon" also works).
  static List<String> parse(String text) {
    return text
        .split(RegExp(r'[\s,]+'))
        .map((word) => word.replaceAll(RegExp(r'^\d+\.?'), '').trim())
        .where((word) => word.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppTextField(
      key: const ValueKey('recovery-words-input'),
      controller: controller,
      label: l10n.recoveryWordsInputLabel,
      hintText: l10n.recoveryWordsInputHint,
      enabled: enabled,
      keyboardType: TextInputType.multiline,
      maxLines: 5,
      autofillHints: const [AutofillHints.password],
    );
  }
}
