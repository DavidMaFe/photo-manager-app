import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/widgets/app_sheet.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_event.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/album_name_form.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


/// "New album" sheet content.
class CreateFolderModal extends StatelessWidget {

  final String? parentFolderId;

  const CreateFolderModal({
    super.key,
    this.parentFolderId
  });

  /// Opens the sheet with [FolderBloc] taken from [context].
  static Future<void> show(BuildContext context, {String? parentFolderId}) {
    final bloc = context.read<FolderBloc>();
    return showAppSheet<void>(
      context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: CreateFolderModal(parentFolderId: parentFolderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return AlbumNameForm(
      title: parentFolderId == null ? l10n.newFolderTitle : l10n.newSubalbum,
      submitLabel: l10n.create,
      onSubmit: (name) {
        context.read<FolderBloc>().add(
          CreateFolderRequested(name: name, parentFolderId: parentFolderId)
        );
        Navigator.pop(context);
      },
    );
  }
}
