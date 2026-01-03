import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';

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


class MainShell extends StatelessWidget {

  final Widget child;
  final StatefulNavigationShell navigationShell;

  const MainShell({
    Key? key,
    required this.child,
    required this.navigationShell
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

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
      child: Scaffold(
        body: child,
        bottomNavigationBar: isFileDetailPage ? null : BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(index),
          selectedItemColor: PhotoManagerColors.primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.folder, size: 28), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.sync, size: 28), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.notifications, size: 28), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: ''),
          ],
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