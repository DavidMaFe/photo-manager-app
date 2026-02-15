import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../../../config/theme/photo_manager_colors.dart';
import '../../domain/entities/folder.dart';
import '../bloc/folder/folder_bloc.dart';


class RenameFolderModal extends StatefulWidget {

  final Folder folder;

  const RenameFolderModal({
    super.key,
    required this.folder
  });

  @override
  State<RenameFolderModal> createState() => _RenameFolderModalState();
}


class _RenameFolderModalState extends State<RenameFolderModal> {

  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.folder.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 32,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24
      ),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: PhotoManagerColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: PhotoManagerColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.renameFolder,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87
                        ),
                      ),
                      Text(
                        widget.folder.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: l10n.folderName,
                  hintText: l10n.hintFolderName,
                  prefixIcon: const Icon(Icons.folder),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: PhotoManagerColors.primary,
                          width: 2
                      )
                  )
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.folderNameRequiredError;
                }
                if (value.trim().length > 100) {
                  return l10n.folderMaxHundredCharactersError;
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
              maxLength: 100,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                        ),
                        side: BorderSide(color: Colors.grey.shade300)
                    ),
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _handleRename,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: PhotoManagerColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                        ),
                        elevation: 0
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.save,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _handleRename() {
    if (_formKey.currentState!.validate()) {
      context.read<FolderBloc>().add(
          RenameFolderRequested(
            folderId: widget.folder.id,
            newName: _nameController.text.trim()
          )
      );
      Navigator.pop(context);
    }
  }
}