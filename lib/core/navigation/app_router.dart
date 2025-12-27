import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/navigation/auth_notifier.dart';
import 'package:photo_manager_app/core/navigation/main_shell.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/pages/login_page.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:photo_manager_app/features/gallery/presentation/pages/gallery_page.dart';
import 'package:photo_manager_app/features/profile/presentation/pages/profile_page.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_event.dart';

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

          if (isLoading) {
            return null;
          }

          if (!isAuthenticated && !isGoingToLogin) {
            return RoutePaths.login;
          }
          if (isAuthenticated && isGoingToLogin) {
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
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell, child: navigationShell),
            branches: [

              // Branch 0: Home
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: RoutePaths.home,
                    name: RouteNames.home,
                    builder: (context, state) => BlocProvider(
                      create: (context) => sl<GalleryBloc>()..add(const LoadGallery()),
                      child: const GalleryPage(),
                    )
                  ),
                ],
              ),

              // Branch 1: Folders
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: RoutePaths.folders,
                    name: RouteNames.folders,
                    builder: (context, state) => const GalleryPage(), // TODO: crear
                  ),
                ],
              ),

              // Branch 2: Sync
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: RoutePaths.sync,
                    name: RouteNames.sync,
                    builder: (context, state) => const GalleryPage(), // TODO: crear
                  ),
                ],
              ),

              // Branch 3: Notifications
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: RoutePaths.notifications,
                    name: RouteNames.notifications,
                    builder: (context, state) => const GalleryPage(), // TODO: crear
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
                    )
                  ),
                ],
              ),
            ]
          )
        ]
    );
  }
}