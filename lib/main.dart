import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/navigation/app_router.dart';
import 'package:photo_manager_app/core/navigation/onboarding_notifier.dart';
import 'package:photo_manager_app/core/services/background_task_handler.dart';
import 'package:photo_manager_app/core/services/sync_notification_service.dart';
import 'package:photo_manager_app/core/services/sync_scheduler_service.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/onboarding/domain/use_cases/check_onboarding_status_use_case.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';
import 'package:workmanager/workmanager.dart';
import 'core/injection_container.dart' as di;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  // Initialize WorkManager for background tasks
  await Workmanager().initialize(
    backgroundTaskHandler,
    isInDebugMode: true, // Enable debug mode to see WorkManager logs
  );

  // Initialize notification service
  final notificationService = di.sl<SyncNotificationService>();
  await notificationService.initialize();

  // Reschedule sync on app startup (handles device reboot scenario)
  final syncConfigRepository = di.sl<SyncConfigRepository>();
  final syncSchedulerService = di.sl<SyncSchedulerService>();
  final syncConfig = await syncConfigRepository.getSyncConfig();

  if (syncConfig != null && syncConfig.autoSyncEnabled) {
    await syncSchedulerService.rescheduleSync(syncConfig);
  }

  final authBloc = di.sl<AuthBloc>()..add(CheckAuthStatus());

  // Create OnboardingNotifier and register it as a singleton so OnboardingPage can access it
  final onboardingNotifier = OnboardingNotifier(
    authBloc: authBloc,
    checkOnboardingStatusUseCase: di.sl<CheckOnboardingStatusUseCase>(),
  );
  di.sl.registerSingleton<OnboardingNotifier>(onboardingNotifier);

  final router = AppRouter.createRouter(authBloc, onboardingNotifier);

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
