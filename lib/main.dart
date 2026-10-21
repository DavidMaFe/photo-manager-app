import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/navigation/app_router.dart';
import 'package:photo_manager_app/core/navigation/auth_notifier.dart';
import 'package:photo_manager_app/core/navigation/onboarding_notifier.dart';
import 'package:photo_manager_app/core/navigation/startup_splash.dart';
import 'package:photo_manager_app/core/services/background_task_handler.dart';
import 'package:photo_manager_app/core/services/sync_notification_service.dart';
import 'package:photo_manager_app/core/services/sync_scheduler_service.dart';
import 'package:photo_manager_app/core/services/ui_preferences_service.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/clear_shared_files_use_case.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_bloc.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_event.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/on_device_presence_cubit.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/share_cubit.dart';
import 'package:photo_manager_app/features/downloads/presentation/services/on_device_presence_updater.dart';
import 'package:photo_manager_app/features/onboarding/domain/use_cases/check_onboarding_status_use_case.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/billing_cubit.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/plan_cubit.dart';
import 'package:photo_manager_app/features/sync_config/domain/use_cases/apply_plan_to_sync_config_use_case.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';
import 'package:workmanager/workmanager.dart';
import 'config/app_config.dart';
import 'config/theme/app_theme.dart';
import 'core/injection_container.dart' as di;
import 'core/monitoring/app_logger.dart';
import 'core/utils/app_locale.dart';


void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // The native splash stays until the router knows where the app opens (StartupSplash)
  binding.deferFirstFrame();

  // Hide system navigation bar completely (immersive sticky).
  // The bar appears briefly as a semi-transparent overlay when the user
  // swipes from the edge, then auto-hides again.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize dependency injection
  await di.init();

  // Monitoring: the errors nobody handled go to the log of the backend (CLAUDE.md, «Logs and metrics»)
  final appLogger = di.sl<AppLogger>();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    appLogger.recordError(details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    appLogger.recordError(error, stackTrace);
    return true;
  };
  appLogger.start();

  // Initialize WorkManager for background tasks
  await Workmanager().initialize(
    backgroundTaskHandler,
    isInDebugMode: AppConfig.isDevelopment,
  );

  // Initialize notification service
  final notificationService = di.sl<SyncNotificationService>();
  await notificationService.initialize();

  // Restore sync schedule on app startup.
  //
  // Uses restoreSyncIfNeeded (ExistingWorkPolicy.keep) instead of
  // rescheduleSync to avoid cancelling and re-registering a task that is
  // already correctly pending. This prevents time-drift where opening the
  // app at 9 AM would shift a 2 AM scheduled task to 9 AM.
  final syncConfigRepository = di.sl<SyncConfigRepository>();
  final syncSchedulerService = di.sl<SyncSchedulerService>();
  final syncConfig = await syncConfigRepository.getSyncConfig();

  if (syncConfig != null && syncConfig.autoSyncEnabled) {
    await syncSchedulerService.restoreSyncIfNeeded(syncConfig);
  }

  final authBloc = di.sl<AuthBloc>()..add(CheckAuthStatus());

  // Create OnboardingNotifier and register it as a singleton so OnboardingPage can access it
  final onboardingNotifier = OnboardingNotifier(
    authBloc: authBloc,
    checkOnboardingStatusUseCase: di.sl<CheckOnboardingStatusUseCase>(),
  );
  di.sl.registerSingleton<OnboardingNotifier>(onboardingNotifier);

  final router = AppRouter.createRouter(authBloc, onboardingNotifier,
      observers: [AppScreenObserver(appLogger)]);

  final startupAuth = AuthNotifier(authBloc);
  StartupSplash(
    changes: Listenable.merge([startupAuth, onboardingNotifier]),
    isResolved: () => !startupAuth.isLoading && !onboardingNotifier.isCheckingStatus,
    release: () async {
      // One more frame, so the router has already moved to the page the app opens on
      await binding.endOfFrame;
      // Away from the login page (the initial location) the router animates the change of page: it finishes under
      // the splash, so the login page is never seen
      if (authBloc.state is! NotAuthenticated) await Future<void>.delayed(_routeTransitionDuration);
      binding.allowFirstFrame();
    },
  ).start();

  runApp(MyApp(
    authBloc: authBloc,
    router: router,
    uiPreferencesService: di.sl<UiPreferencesService>(),
  ));
}

/// Default page transition of the platform (MaterialApp without a custom pageTransitionsTheme).
Duration get _routeTransitionDuration => defaultTargetPlatform == TargetPlatform.iOS
    ? CupertinoRouteTransitionMixin.kTransitionDuration
    : const Duration(milliseconds: FadeForwardsPageTransitionsBuilder.kTransitionMilliseconds);

class MyApp extends StatefulWidget {

  final AuthBloc authBloc;
  final GoRouter router;
  final UiPreferencesService uiPreferencesService;

  const MyApp({
    super.key,
    required this.authBloc,
    required this.router,
    required this.uiPreferencesService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<Object?>? _planSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    di.sl<ClearSharedFilesUseCase>()();
    _onAuthState(widget.authBloc.state);
    _authSubscription = widget.authBloc.stream.listen(_onAuthState);
    // The free plan backs up weekly: a daily automatic backup becomes weekly when the plan is read
    _planSubscription = di.sl<PlanCubit>().stream
        .map((state) => state.plan)
        .where((plan) => plan != null)
        .distinct()
        .listen((plan) => di.sl<ApplyPlanToSyncConfigUseCase>()(dailyBackup: plan!.limits.dailyBackup));
  }

  /// With a session: what this device is missing and a download that may be running in the background
  /// (ROADMAP-downloads-and-account-deletion.md).
  void _onAuthState(AuthState state) {
    if (state is AuthSuccessful) {
      di.sl<PlanCubit>().load();
      // Purchases paid while the app was closed, or in another session, reach the server
      if (AppConfig.billingEnabled) di.sl<BillingCubit>().start();
      di.sl<OnDevicePresenceUpdater>().start();
      di.sl<DownloadProgressBloc>().add(const DownloadProgressWatchRequested());
    }
  }

  @override
  void dispose() {
  WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    _planSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Monitoring: what is queued goes out when the app leaves and when it comes back
    if (state == AppLifecycleState.paused || state == AppLifecycleState.resumed) {
      di.sl<AppLogger>().flush();
    }
    if (state == AppLifecycleState.resumed) {
      // Android resets system UI on resume — reapply immersive mode.
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      // Back from the share sheet: the other app already copied the shared files
      di.sl<ClearSharedFilesUseCase>()();
      if (widget.authBloc.state is AuthSuccessful) {
        // Photos deleted from the gallery meanwhile, the progress of a download, and the plan (it may have changed in
        // the store)
        di.sl<PlanCubit>().load();
        di.sl<OnDevicePresenceUpdater>().refresh();
        di.sl<DownloadProgressBloc>().add(const DownloadProgressWatchRequested());
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authBloc),
        // Downloads to the gallery and sharing, from any page (ROADMAP-downloads-and-account-deletion.md)
        BlocProvider.value(value: di.sl<DownloadProgressBloc>()),
        BlocProvider(create: (_) => di.sl<OnDevicePresenceCubit>()),
        BlocProvider(create: (_) => di.sl<ShareCubit>()),
        BlocProvider.value(value: di.sl<PlanCubit>()),
        BlocProvider.value(value: di.sl<BillingCubit>()),
      ],
      // Theme mode and color of the app chosen by the user
      child: ListenableBuilder(
        listenable: Listenable.merge([widget.uiPreferencesService.themeMode, widget.uiPreferencesService.accent]),
        builder: (context, _) => MaterialApp.router(
          title: 'Photo Manager',
          routerConfig: widget.router,

          theme: AppTheme.light(widget.uiPreferencesService.accent.value),
          darkTheme: AppTheme.dark(widget.uiPreferencesService.accent.value),
          themeMode: widget.uiPreferencesService.themeMode.value,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],

          // The language of the device when the app has it, English otherwise (AppLocale)
          supportedLocales: AppLocale.supported,
          localeListResolutionCallback: (locales, _) => AppLocale.resolve(locales),
        ),
      )
    );
  }
}
