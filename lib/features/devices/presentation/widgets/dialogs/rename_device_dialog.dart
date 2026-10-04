import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_sheet.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// "Rename device" sheet.
class RenameDeviceDialog extends StatefulWidget {
  static const int maxLength = 50;

  final String currentName;
  final Function(String) onConfirm;

  const RenameDeviceDialog({
    super.key,
    required this.currentName,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required String currentName,
    required Function(String) onConfirm,
  }) {
    return showAppSheet<void>(
      context,
      builder: (_) => RenameDeviceDialog(currentName: currentName, onConfirm: onConfirm),
    );
  }

  @override
  State<RenameDeviceDialog> createState() => _RenameDeviceDialogState();
}

class _RenameDeviceDialogState extends State<RenameDeviceDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.currentName);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop();
    widget.onConfirm(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.renameDevice, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          AppTextField(
            label: l10n.deviceName,
            controller: _controller,
            autofocus: true,
            maxLength: RenameDeviceDialog.maxLength,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleConfirm(),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return l10n.deviceNameRequired;
              if (text.length > RenameDeviceDialog.maxLength) return l10n.deviceNameTooLong;
              return null;
            },
          ),
          const SizedBox(height: 20),
          AppButton.primary(label: l10n.rename, onPressed: _handleConfirm),
        ],
      ),
    );
  }
}
