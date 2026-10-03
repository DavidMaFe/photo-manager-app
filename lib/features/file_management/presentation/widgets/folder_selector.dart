import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/widgets/error_banner.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_folder.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_state.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class FolderSelector extends StatelessWidget {

  final String? selectedFolderId;
  final ValueChanged<String?> onFolderSelected;

  const FolderSelector({
    super.key,
    required this.selectedFolderId,
    required this.onFolderSelected
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageFolderBloc, ManageFolderState>(
      builder: (context, state) {
        if (state is ManageFolderStarting) {
          context.read<ManageFolderBloc>().add(const LoadFolders());
          return const _LoadingIndicator();
        }

        if (state is ManageFoldersLoading) {
          return const _LoadingIndicator();
        }

        if (state is ManageFoldersLoaded) {
          return _FolderList(
            folders: state.folders,
            selectedFolderId: selectedFolderId,
            onFolderSelected: onFolderSelected
          );
        }

        if (state is ManageFolderError) {
          return ErrorBanner(
            failure: state.failure,
            onRetry: () {
              context.read<ManageFolderBloc>().add(const LoadFolders());
            },
            margin: const EdgeInsets.symmetric(vertical: 8),
          );
        }
        
        return const _LoadingIndicator();
      },
    );
  }
}


class _LoadingIndicator extends StatelessWidget {
  
  const _LoadingIndicator();
  
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
    );
  }
}


class _FolderList extends StatelessWidget {
  
  final List<ManageFolder> folders;
  final String? selectedFolderId;
  final ValueChanged<String?> onFolderSelected;
  
  const _FolderList({
    required this.folders, 
    required this.selectedFolderId, 
    required this.onFolderSelected
  });
  
  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    if (folders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(l10n.noFolders, style: TextStyle(color: context.palette.ink2, fontSize: 13)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.palette.background,
        borderRadius: BorderRadius.circular(8)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: folders.asMap().entries.map((entry) {
          final index = entry.key;
          final folder = entry.value;
          final isSelected = selectedFolderId == folder.id;
          final isLast = index == folders.length - 1;

          return Column(
            children: [
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => onFolderSelected(folder.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? context.palette.accent : context.palette.ink3,
                            size: 20
                        ),

                        const SizedBox(width: 10),

                        Icon(
                          Icons.folder,
                          color: context.palette.ink2,
                          size: 18,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                folder.name,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? context.palette.accentInk : context.palette.ink
                                ),
                              ),
                              if (folder.fileCount > 0)
                                Text(
                                  '${folder.fileCount} ${l10n.files}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: context.palette.ink2
                                  ),
                                )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              if(!isLast)
                Divider(height: 1, color: context.palette.line)
            ],
          );
        }).toList(),
      ),
    );
  }
}
