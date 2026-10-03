import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/navigation/shell_selection_mode.dart';
import 'package:photo_manager_app/core/widgets/app_nav_bar.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import '../../features/file_management/presentation/bloc/file_management/file_management_state.dart';
import '../../features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import '../../features/file_management/presentation/bloc/manage_folder/manage_folder_event.dart';
import '../../features/folders/presentation/bloc/folder/folder_bloc.dart';
import '../../features/folders/presentation/bloc/folder/folder_event.dart' hide LoadFolders;
import '../../features/folders/presentation/bloc/folder/folder_state.dart';
import '../../features/folders/presentation/bloc/folder_content/folder_content_bloc.dart';
import '../../features/folders/presentation/bloc/folder_content/folder_content_event.dart';
import '../../features/gallery/presentation/bloc/gallery_bloc.dart';
import '../../features/gallery/presentation/bloc/gallery_event.dart';


/// Tab scaffold: Photos · Albums · Backup · Profile with the floating bar.
class MainShell extends StatefulWidget {

  final Widget child;
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.child,
    required this.navigationShell
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {

  final ValueNotifier<bool> _selectionMode = ValueNotifier(false);

  @override
  void dispose() {
    _selectionMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final currentLocation = GoRouterState.of(context).uri.toString();
    final isFileDetailPage = currentLocation.contains('/file/');

    return MultiBlocListener(
      listeners: [
        BlocListener<FileManagementBloc, FileManagementState>(
          listener: (context, state) {
            if (state is FileManagementSuccess) {
              _syncAllViews(context);
            }
          },
        ),

        BlocListener<FolderBloc, FolderState>(
          listener: (context, state) {
            if (state is FolderOperationSuccess) {
              _syncAllViews(context);
            }
          },
        ),
      ],
      child: ShellSelectionMode(
        notifier: _selectionMode,
        child: ValueListenableBuilder<bool>(
          valueListenable: _selectionMode,
          builder: (context, isSelecting, child) => Scaffold(
            // The floating bar overlays the content; pages read the bottom
            // inset to keep their last items visible.
            extendBody: true,
            body: child,
            bottomNavigationBar: isFileDetailPage || isSelecting
                ? null
                : AppNavBar(
                    currentIndex: widget.navigationShell.currentIndex,
                    onTap: (index) => widget.navigationShell.goBranch(
                      index,
                      initialLocation: index == widget.navigationShell.currentIndex,
                    ),
                    destinations: [
                      AppNavDestination(icon: Symbols.photo_library_rounded, label: l10n.navPhotos),
                      AppNavDestination(icon: Symbols.photo_album_rounded, label: l10n.navAlbums),
                      AppNavDestination(icon: Symbols.cloud_sync_rounded, label: l10n.navBackup),
                      AppNavDestination(icon: Symbols.person_rounded, label: l10n.navProfile),
                    ],
                  ),
          ),
          child: widget.child,
        ),
      ),
    );
  }

  void _syncAllViews(BuildContext context) {

    try {
      context.read<GalleryBloc>().add(const RefreshGallery());
    } catch (e) {}

    context.read<FolderBloc>().add(const RefreshFolders());

    try {
      context.read<FolderContentBloc>().add(const RefreshFolderContent());
    } catch (e) {}

    context.read<ManageFolderBloc>().add(const LoadFolders());
  }
}
