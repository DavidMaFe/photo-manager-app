
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/navigation/auth_notifier.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/screens/login_screen.dart';

import '../../features/home/presentation/screens/home_screen.dart';

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
              builder: (context, state) => const LoginScreen()
          ),

          GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen()
          ),
        ]
    );
  }
}