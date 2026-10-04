import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Title + album name field + primary button, shared by the create and
/// rename sheets.
class AlbumNameForm extends StatefulWidget {
  static const int maxLength = 100;

  final String title;
  final String submitLabel;
  final String initialName;
  final ValueChanged<String> onSubmit;

  const AlbumNameForm({
    super.key,
    required this.title,
    required this.submitLabel,
    this.initialName = '',
    required this.onSubmit,
  });

  @override
  State<AlbumNameForm> createState() => _AlbumNameFormState();
}

class _AlbumNameFormState extends State<AlbumNameForm> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialName);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_controller.text.trim());
    }
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
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          AppTextField(
            label: l10n.folderName,
            controller: _controller,
            hintText: l10n.hintFolderName,
            autofocus: true,
            maxLength: AlbumNameForm.maxLength,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.folderNameRequiredError;
              }
              if (value.trim().length > AlbumNameForm.maxLength) {
                return l10n.folderMaxHundredCharactersError;
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          AppButton.primary(label: widget.submitLabel, onPressed: _submit),
        ],
      ),
    );
  }
}
