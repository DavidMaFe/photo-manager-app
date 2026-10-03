import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/widgets/app_sheet.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_event.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/album_name_form.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


/// "Rename album" sheet content.
class RenameFolderModal extends StatelessWidget {

  final Folder folder;

  const RenameFolderModal({
    super.key,
    required this.folder
  });

  /// Opens the sheet with [FolderBloc] taken from [context].
  static Future<void> show(BuildContext context, Folder folder) {
    final bloc = context.read<FolderBloc>();
    return showAppSheet<void>(
      context,
      builder: (_) => BlocProvider.value(value: bloc, child: RenameFolderModal(folder: folder)),
    );
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return AlbumNameForm(
      title: l10n.renameFolder,
      submitLabel: l10n.rename,
      initialName: folder.name,
      onSubmit: (name) {
        context.read<FolderBloc>().add(
          RenameFolderRequested(folderId: folder.id, newName: name)
        );
        Navigator.pop(context);
      },
    );
  }
}
