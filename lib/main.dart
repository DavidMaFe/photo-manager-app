import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/navigation/app_router.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';
import 'core/injection_container.dart' as di;


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  final authBloc = di.sl<AuthBloc>()..add(CheckAuthStatus());
  final router = AppRouter.createRouter(authBloc);

  runApp(MyApp(authBloc: authBloc, router: router));
}

class MyApp extends StatelessWidget {

  final AuthBloc authBloc;
  final GoRouter router;

  const MyApp({super.key, required this.authBloc, required this.router});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
      ],
      child: MaterialApp.router(
        title: 'Photo Manager',
        routerConfig: router,

        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],

        supportedLocales: const [
          Locale('es', ''),
          Locale('en', ''),
        ],

        locale: const Locale('es'),

        localeResolutionCallback: (locale, supportedLocales) {
          if (locale != null) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
          }

          return const Locale('es');
        },
      )
    );
  }
}
