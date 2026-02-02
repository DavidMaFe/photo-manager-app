import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/navigation/auth_notifier.dart';
import 'package:photo_manager_app/core/navigation/main_shell.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/pages/login_page.dart';
import 'package:photo_manager_app/features/auth/presentation/pages/register_page.dart';
import 'package:photo_manager_app/features/file_management/presentation/pages/file_detail_page.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_event.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_event.dart';
import 'package:photo_manager_app/features/folders/presentation/pages/folder_content_page.dart';
import 'package:photo_manager_app/features/folders/presentation/pages/folders_page.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:photo_manager_app/features/gallery/presentation/pages/gallery_page.dart';
import 'package:photo_manager_app/features/notification/presentation/pages/notifications_page.dart';
import 'package:photo_manager_app/features/profile/presentation/pages/profile_page.dart';
import 'package:photo_manager_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:photo_manager_app/features/trash/presentation/pages/trash_page.dart';
import 'package:photo_manager_app/features/trash/presentation/pages/trash_file_detail_page.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_bloc.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_bloc.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_event.dart';
import 'package:photo_manager_app/features/synchronization/presentation/pages/synchronization_page.dart';

import '../../features/auth/presentation/pages/request_password_reset_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/validate_reset_code_page.dart';
import '../../features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import '../../features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import '../../features/gallery/domain/entities/gallery_file.dart';
import '../../features/sync_session/presentation/bloc/sync_session_bloc.dart';
import '../injection_container.dart';


class AppRouter {

  static GoRouter createRouter(AuthBloc authBloc) {
    final authNotifier = AuthNotifier(authBloc);

    return GoRouter(
        initialLocation: RoutePaths.login,
        refreshListenable: authNotifier,
        redirect: (context, state) {
          final isAuthenticated = authNotifier.isAuthenticated;
          final isLoading = authNotifier.isLoading;
          final isGoingToLogin = state.matchedLocation == RoutePaths.login;
          final isGoingToRegister = state.matchedLocation == RoutePaths.register;
          final isGoingToPasswordReset = state.matchedLocation == RoutePaths.requestPasswordReset ||
              state.matchedLocation == RoutePaths.validateResetCode ||
              state.matchedLocation == RoutePaths.resetPassword;


          if (isLoading) {
            return null;
          }

          if (!isAuthenticated && !isGoingToLogin && !isGoingToRegister && !isGoingToPasswordReset) {
            return RoutePaths.login;
          }
          if (isAuthenticated && (isGoingToLogin || isGoingToRegister || isGoingToPasswordReset)) {
            return RoutePaths.home;
          }

          return null;
        },

        routes: [
          GoRoute(
              path: RoutePaths.login,
              name: RouteNames.login,
              builder: (context, state) => const LoginPage()
          ),
          GoRoute(
            path: RoutePaths.register,
            name: RouteNames.register,
            builder: (context, state) => const RegisterPage()
          ),
          GoRoute(
            path: RoutePaths.requestPasswordReset,
            name: RouteNames.requestPasswordReset,
            builder: (context, state) => const RequestPasswordResetPage(),
          ),
          GoRoute(
            path: RoutePaths.validateResetCode,
            name: RouteNames.validateResetCode,
            builder: (context, state) {
              final email = state.extra as String;
              return ValidateResetCodePage(email: email);
            },
          ),
          GoRoute(
            path: RoutePaths.resetPassword,
            name: RouteNames.resetPassword,
            builder: (context, state) {
              final params = state.extra as Map<String, dynamic>;
              return ResetPasswordPage(
                email: params['email'] as String,
                code: params['code'] as String,
              );
            },
          ),
          GoRoute(
              path: '/file/:fileId',
              name: RouteNames.fileDetail,
              builder: (context, state) {

                final extra = state.extra as Map<String, dynamic>?;
                final files = extra?['files'] as List<GalleryFile>? ?? [];
                final initialIndex = extra?['initialIndex'] ?? 0;

                return MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (context) => sl<FileManagementBloc>()),
                    BlocProvider(create: (context) => sl<ManageFolderBloc>())
                  ],
                  child: FileDetailPage(files: files, initialIndex: initialIndex),
                );
              }
          ),

          StatefulShellRoute.indexedStack(
              builder: (context, state, navigationShell) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => sl<FileManagementBloc>(),
                    ),
                    BlocProvider(
                      create: (context) => sl<FolderBloc>()..add(const LoadFolders()),
                    ),
                    BlocProvider(
                      create: (context) => sl<ManageFolderBloc>(),
                    ),
                    BlocProvider(
                      create: (context) => sl<GalleryBloc>()..add(const LoadGallery()),
                    ),
                  ],
                  child: MainShell(
                    navigationShell: navigationShell,
                    child: navigationShell,
                  ),
                );
              },
              branches: [
                // Branch 0: Home
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: RoutePaths.home,
                      name: RouteNames.home,
                      builder: (context, state) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: sl<SyncSessionBloc>())
                        ],
                        child: const GalleryPage(),
                      ),
                    ),
                  ],
                ),

                // Branch 1: Folders
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                        path: RoutePaths.folders,
                        name: RouteNames.folders,
                        builder: (context, state) => const FoldersPage(),
                        routes: [
                          GoRoute(
                            path: ':folderId',
                            name: RouteNames.folderContent,
                            builder: (context, state) {
                              final folderId = state.pathParameters['folderId']!;

                              return BlocProvider(
                                create: (context) => sl<FolderContentBloc>()
                                  ..add(LoadFolderContent(folderId: folderId)),
                                child: FolderContentPage(folderId: folderId),
                              );
                            },
                          )
                        ]
                    ),
                  ],
                ),

                // Branch 2: Sync
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: RoutePaths.sync,
                      name: RouteNames.sync,
                      builder: (context, state) => BlocProvider(
                        create: (context) => sl<SynchronizationBloc>()
                          ..add(const LoadSynchronizations()),
                        child: const SynchronizationPage(),
                      )
                    ),
                  ],
                ),

                // Branch 3: Notifications
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: RoutePaths.notifications,
                      name: RouteNames.notifications,
                      builder: (context, state) => const NotificationsPage()
                    ),
                  ],
                ),

                // Branch 4: Profile
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                        path: RoutePaths.profile,
                        name: RouteNames.profile,
                        builder: (context, state) => BlocProvider.value(
                            value: sl<ProfileBloc>()..add(LoadProfileRequested()),
                            child: const ProfilePage()
                        ),
                        routes: [
                          GoRoute(
                            path: 'edit',
                            name: RouteNames.editProfile,
                            builder: (context, state) => BlocProvider.value(
                              value: sl<ProfileBloc>(),
                              child: const EditProfilePage(),
                            ),
                          ),
                          GoRoute(
                            path: 'trash',
                            name: RouteNames.trash,
                            builder: (context, state) => const TrashPage(),
                            routes: [
                              GoRoute(
                                path: 'file/:fileId',
                                name: RouteNames.trashFileDetail,
                                builder: (context, state) {
                                  final extra = state.extra as Map<String, dynamic>?;
                                  final files = extra?['files'] as List<TrashFile>? ?? [];
                                  final initialIndex = extra?['initialIndex'] ?? 0;

                                  return BlocProvider.value(
                                    value: sl<TrashBloc>(),
                                    child: TrashFileDetailPage(
                                      files: files,
                                      initialIndex: initialIndex
                                    ),
                                  );
                                }
                              ),
                            ],
                          ),
                        ]
                    ),
                  ],
                ),
              ]
          )
        ]
    );
  }
}