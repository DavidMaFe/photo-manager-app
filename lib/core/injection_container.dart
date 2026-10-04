
import 'package:photo_manager_app/core/permissions/device_permission_service.dart';
import 'package:photo_manager_app/core/permissions/permission_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager_app/core/database/app_database.dart';
import 'package:photo_manager_app/core/network/authenticated_http_client.dart';
import 'package:photo_manager_app/core/services/background_sync_service.dart';
import 'package:photo_manager_app/core/services/sync_log_service.dart';
import 'package:photo_manager_app/core/services/sync_notification_service.dart';
import 'package:photo_manager_app/core/services/sync_scheduler_service.dart';
import 'package:photo_manager_app/core/services/timezone_service.dart';
import 'package:photo_manager_app/core/services/ui_preferences_service.dart';
import 'package:photo_manager_app/features/favorites/data/data_sources/favorites_remote_data_source.dart';
import 'package:photo_manager_app/features/favorites/data/repositories/favorites_data_repository.dart';
import 'package:photo_manager_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:photo_manager_app/features/favorites/domain/use_cases/set_favorite_use_case.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:photo_manager_app/features/folders/data/data_sources/covers_remote_data_source.dart';
import 'package:photo_manager_app/features/folders/data/repositories/covers_data_repository.dart';
import 'package:photo_manager_app/features/folders/domain/repositories/covers_repository.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/apply_cover_changes_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_album_covers_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_cover_targets_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/set_album_covers_use_case.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/album_covers/album_covers_cubit.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/cover_picker/cover_picker_cubit.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:photo_manager_app/features/auth/data/repositories/auth_data_repository.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/refresh_token_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/file_management/data/data_sources/file_deletion_local_data_source.dart';
import 'package:photo_manager_app/features/file_management/data/data_sources/file_management_remote_data_source.dart';
import 'package:photo_manager_app/features/file_management/data/repositories/file_management_repository_impl.dart';
import 'package:photo_manager_app/features/file_management/domain/repositories/file_management_repository.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/get_folders_use_case.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/manage_files_use_case.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/get_file_info_use_case.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_bloc.dart';
import 'package:photo_manager_app/features/folders/data/data_sources/folder_remote_data_source.dart';
import 'package:photo_manager_app/features/folders/data/repositories/folder_repository_impl.dart';
import 'package:photo_manager_app/features/folders/domain/repositories/folder_repository.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/create_folder_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/delete_folder_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_folder_content_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/rename_folder_use_case.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_bloc.dart';
import 'package:photo_manager_app/features/gallery/data/data_sources/gallery_remote_data_source.dart';
import 'package:photo_manager_app/features/gallery/data/repositories/gallery_repository_impl.dart';
import 'package:photo_manager_app/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:photo_manager_app/features/gallery/domain/use_cases/get_files_use_case.dart';
import 'package:photo_manager_app/features/gallery/domain/use_cases/get_pending_file_ids_use_case.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:photo_manager_app/features/profile/data/repositories/profile_data_repository.dart';
import 'package:photo_manager_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/update_user_profile_use_case.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/change_password_use_case.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:photo_manager_app/features/devices/data/data_sources/device_remote_data_source.dart';
import 'package:photo_manager_app/features/devices/data/repositories/device_data_repository.dart';
import 'package:photo_manager_app/features/devices/domain/repositories/device_repository.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/get_user_devices_use_case.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/rename_device_use_case.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/toggle_auto_sync_use_case.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/unlink_device_use_case.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_bloc.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/media_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/sync_device_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/remote/sync_device_remote_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/remote/sync_session_remote_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/repositories/sync_device_repository_impl.dart';
import 'package:photo_manager_app/features/sync_session/data/repositories/sync_session_repository_impl.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/check_duplicated_files_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/complete_sync_session_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/register_sync_device_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/start_sync_session_use_case.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/upload_file_use_case.dart';
import 'package:photo_manager_app/features/synchronization/data/data_sources/synchronization_remote_data_source.dart';
import 'package:photo_manager_app/features/synchronization/data/repositories/synchronization_repository_impl.dart';
import 'package:photo_manager_app/features/synchronization/domain/repositories/synchronization_repository.dart';
import 'package:photo_manager_app/features/synchronization/domain/use_cases/get_synchronizations_use_case.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_bloc.dart';
import 'package:photo_manager_app/features/trash/data/data_sources/trash_remote_data_source.dart';
import 'package:photo_manager_app/features/trash/data/repositories/trash_repository_impl.dart';
import 'package:photo_manager_app/features/trash/domain/repositories/trash_repository.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/empty_trash_use_case.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/get_trash_files_use_case.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/permanently_delete_files_use_case.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/restore_files_use_case.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/domain/use_cases/request_password_reset_use_case.dart';
import '../features/auth/domain/use_cases/reset_password_use_case.dart';
import '../features/auth/domain/use_cases/validate_reset_code_use_case.dart';
import '../features/folders/domain/use_cases/get_folders_list_use_case.dart';
import '../features/folders/presentation/bloc/folder/folder_bloc.dart';
import '../features/onboarding/data/data_sources/onboarding_local_data_source.dart';
import '../features/onboarding/data/repositories/onboarding_data_repository.dart';
import '../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../features/onboarding/domain/use_cases/check_onboarding_status_use_case.dart';
import '../features/onboarding/domain/use_cases/complete_onboarding_use_case.dart';
import '../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../features/sync_session/presentation/bloc/sync_session_bloc.dart';
import '../features/sync_config/data/data_sources/sync_config_local_data_source.dart';
import '../features/sync_config/data/repositories/sync_config_data_repository.dart';
import '../features/sync_config/domain/repositories/sync_config_repository.dart';
import '../features/sync_config/domain/use_cases/get_sync_config_use_case.dart';
import '../features/sync_config/domain/use_cases/save_sync_config_use_case.dart';
import '../features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'events/app_event_bus.dart';
import 'utils/onboarding_preferences.dart';


final sl = GetIt.instance;

Future<void> init() async {

  // Device time zone for the X-Timezone header: read once, before any request.
  // init() also runs in the WorkManager background isolate, so uploads get it too.
  await TimezoneService.init();

  // GENERAL INJECTIONS
  // Plain HTTP client (used for auth endpoints to avoid circular dependency)
  sl.registerLazySingleton(() => http.Client());

  sl.registerLazySingleton(() => DeviceInfoPlugin());
  sl.registerLazySingleton(() => AppDatabase());
  sl.registerLazySingleton(() => AppEventBus());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Persistent sync log — registered immediately after SharedPreferences so it
  // is available in both the main isolate and the WorkManager background isolate.
  sl.registerLazySingleton(() => SyncLogService(sl<SharedPreferences>()));

  // Core Services
  sl.registerLazySingleton(() => UiPreferencesService(sl()));

  // Notification plugin
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  // Notification service
  sl.registerLazySingleton(
    () => SyncNotificationService(sl<FlutterLocalNotificationsPlugin>()),
  );

  // Sync scheduler service
  sl.registerLazySingleton(
    () => SyncSchedulerService(),
  );

  sl.registerLazySingleton(
    () => BackgroundSyncService(
      syncDeviceRepository: sl<SyncDeviceRepository>(),
      syncConfigRepository: sl<SyncConfigRepository>(),
      syncSessionRepository: sl<SyncSessionRepository>(),
      startSyncSessionUseCase: sl<StartSyncSessionUseCase>(),
      checkDuplicatesUseCase: sl<CheckDuplicatedFilesUseCase>(),
      uploadFileUseCase: sl<UploadFileUseCase>(),
      completeSyncSessionUseCase: sl<CompleteSyncSessionUseCase>(),
      mediaLocalDataSource: sl<MediaLocalDataSource>(),
      authRepository: sl<AuthRepository>(),
      sharedPreferences: sl<SharedPreferences>(),
      notificationService: sl<SyncNotificationService>(),
      syncLogService: sl<SyncLogService>(),
    ),
  );

  // DATASOURCE'S
  // auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () {
        final client = sl<http.Client>();
        return AuthRemoteDataSourceImpl(client: client);
      }
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
      () {
        final sharedPreferences = sl<SharedPreferences>();
        return AuthLocalDataSourceImpl(sharedPreferences: sharedPreferences);
      }
  );

  // profile
  sl.registerLazySingleton<ProfileRemoteDataSource>(
      () {
        final client = sl<AuthenticatedHttpClient>();
        return ProfileRemoteDataSourceImpl(client: client);
      }
  );

  sl.registerLazySingleton<ProfileLocalDataSource>(
      () {
        final sharedPreferences = sl<SharedPreferences>();
        return ProfileLocalDataSourceImpl(sharedPreferences: sharedPreferences);
      }
  );

  // devices
  sl.registerLazySingleton<DeviceRemoteDataSource>(
      () {
        final client = sl<AuthenticatedHttpClient>();
        return DeviceRemoteDataSourceImpl(client: client);
      }
  );

  // sync session
  sl.registerLazySingleton<SyncSessionRemoteDataSource>(
      () {
        final client = sl<AuthenticatedHttpClient>();
        return SyncSessionRemoteDatasourceImpl(client: client);
      }
  );

  sl.registerLazySingleton<SyncDeviceRemoteDataSource>(
      () {
        final client = sl<AuthenticatedHttpClient>();
        return SyncDeviceRemoteDataSourceImpl(client: client);
      }
  );

  sl.registerLazySingleton<SyncDeviceLocalDataSource>(
      () {
        final sharedPreferences = sl<SharedPreferences>();
        final deviceInfo = sl<DeviceInfoPlugin>();
        return SyncDeviceLocalDataSourceImpl(
          sharedPreferences: sharedPreferences,
          deviceInfo: deviceInfo
        );
      }
  );

  sl.registerLazySingleton<MediaLocalDataSource>(
      () => MediaLocalDataSource()
  );

  // gallery
  sl.registerLazySingleton<GalleryRemoteDataSource>(
      () {
        final client = sl<AuthenticatedHttpClient>();
        return GalleryRemoteDataSourceImpl(client: client);
      }
  );

  // file management
  sl.registerLazySingleton<FileManagementRemoteDataSource>(
      () {
        final client = sl<AuthenticatedHttpClient>();
        return FileManagementRemoteDataSourceImpl(client: client);
      }
  );

  // favorites
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
      () => FavoritesRemoteDataSourceImpl(client: sl<AuthenticatedHttpClient>())
  );

  // album covers
  sl.registerLazySingleton<CoversRemoteDataSource>(
      () => CoversRemoteDataSourceImpl(client: sl<AuthenticatedHttpClient>())
  );

  sl.registerLazySingleton<FileDeletionLocalDataSource>(
      () {
        return FileDeletionLocalDataSourceImpl();
      }
  );

  // folders
  sl.registerLazySingleton<FolderRemoteDataSource>(
      () {
        final client = sl<AuthenticatedHttpClient>();
        return FolderRemoteDataSourceImpl(client: client);
      }
  ) ;

  // synchronization
  sl.registerLazySingleton<SynchronizationRemoteDataSource>(
      () {
        final client = sl<AuthenticatedHttpClient>();
        return SynchronizationRemoteDataSourceImpl(client: client);
      }
  );

  // trash
  sl.registerLazySingleton<TrashRemoteDataSource>(
      () {
        final client = sl<AuthenticatedHttpClient>();
        return TrashRemoteDataSourceImpl(client: client);
      }
  );

  // sync config
  sl.registerLazySingleton<SyncConfigLocalDataSource>(
      () {
        final sharedPreferences = sl<SharedPreferences>();
        return SyncConfigLocalDataSourceImpl(sharedPreferences: sharedPreferences);
      }
  );


  // REPOSITORIES
  // auth
  sl.registerLazySingleton<AuthRepository>(
      () {
        final remoteDataSource = sl<AuthRemoteDataSource>();
        final localDataSource = sl<AuthLocalDataSource>();
        final profileLocalDataSource = sl<ProfileLocalDataSource>();
        final syncDeviceLocalDataSource = sl<SyncDeviceLocalDataSource>();
        return AuthDataRepository(
            remoteDataSource: remoteDataSource,
            localDataSource: localDataSource,
            profileLocalDataSource: profileLocalDataSource,
            syncDeviceLocalDataSource: syncDeviceLocalDataSource
        );
      }
  );

  // profile
  sl.registerLazySingleton<ProfileRepository>(
      () {
        final profileRemoteDataSource = sl<ProfileRemoteDataSource>();
        final profileLocalDataSource = sl<ProfileLocalDataSource>();
        return ProfileDataRepository(
            profileRemoteDatasource: profileRemoteDataSource,
            profileLocalDataSource: profileLocalDataSource
        );
      }
  );

  // devices
  sl.registerLazySingleton<DeviceRepository>(
      () {
        final deviceRemoteDataSource = sl<DeviceRemoteDataSource>();
        return DeviceDataRepository(remoteDataSource: deviceRemoteDataSource);
      }
  );

  // sync session
  sl.registerLazySingleton<SyncSessionRepository>(
      () {
        final syncSessionRemoteDataSource = sl<SyncSessionRemoteDataSource>();
        return SyncSessionRepositoryImpl(
          remoteDataSource: syncSessionRemoteDataSource
        );
      }
  );

  sl.registerLazySingleton<SyncDeviceRepository>(
      () {
        final syncDeviceRemoteDataSource = sl<SyncDeviceRemoteDataSource>();
        final syncDeviceLocalDataSource = sl<SyncDeviceLocalDataSource>();
        return SyncDeviceRepositoryImpl(
          remoteDataSource: syncDeviceRemoteDataSource,
          localDataSource: syncDeviceLocalDataSource
        );
      }
  );

  // gallery
  sl.registerLazySingleton<GalleryRepository>(
      () {
        final remoteDataSource = sl<GalleryRemoteDataSource>();
        return GalleryRepositoryImpl(remoteDataSource);
      }
  );

  // file management
  sl.registerLazySingleton<FileManagementRepository>(
      () {
        final remoteDataSource = sl<FileManagementRemoteDataSource>();
        final deletionLocalDataSource = sl<FileDeletionLocalDataSource>();
        final database = sl<AppDatabase>();

        return FileManagementRepositoryImpl(
          remoteDataSource: remoteDataSource,
          deletionLocalDataSource: deletionLocalDataSource,
          database: database
        );
      }
  );

  // folders
  sl.registerLazySingleton<FolderRepository>(
      () {
        final remoteDataSource = sl<FolderRemoteDataSource>();
        return FolderRepositoryImpl(
          remoteDataSource: remoteDataSource
        );
      }
  );

  sl.registerLazySingleton<CoversRepository>(
      () => CoversDataRepository(sl<CoversRemoteDataSource>())
  );

  sl.registerLazySingleton<FavoritesRepository>(
      () => FavoritesDataRepository(sl<FavoritesRemoteDataSource>())
  );

  // synchronization
  sl.registerLazySingleton<SynchronizationRepository>(
      () {
        final remoteDatSource = sl<SynchronizationRemoteDataSource>();
        return SynchronizationRepositoryImpl(remoteDataSource: remoteDatSource);
      }
  );

  // trash
  sl.registerLazySingleton<TrashRepository>(
      () {
        final remoteDataSource = sl<TrashRemoteDataSource>();
        return TrashRepositoryImpl(remoteDataSource: remoteDataSource);
      }
  );

  // sync config
  sl.registerLazySingleton<SyncConfigRepository>(
      () {
        final localDataSource = sl<SyncConfigLocalDataSource>();
        return SyncConfigDataRepository(localDataSource: localDataSource);
      }
  );


  // Authenticated HTTP Client (uses AuthRepository for token refresh)
  // Registered after repositories to avoid circular dependency
  sl.registerLazySingleton<AuthenticatedHttpClient>(
      () {
        final plainClient = sl<http.Client>();
        final authLocalDataSource = sl<AuthLocalDataSource>();
        final authRepository = sl<AuthRepository>();
        final eventBus = sl<AppEventBus>();

        return AuthenticatedHttpClient(
          client: plainClient,
          authLocalDataSource: authLocalDataSource,
          onTokenRefresh: () => authRepository.refreshToken(),
          eventBus: eventBus,
        );
      }
  );

  // USE CASES
  // auth
  sl.registerFactory(
      () {
        final repository = sl<AuthRepository>();
        return LoginUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<AuthRepository>();
        return LogoutUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<AuthRepository>();
        return RegisterUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<AuthRepository>();
        return RequestPasswordResetUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<AuthRepository>();
        return ValidateResetCodeUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<AuthRepository>();
        return ResetPasswordUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<AuthRepository>();
        return RefreshTokenUseCase(repository);
      }
  );

  // profile
  sl.registerFactory(
      () {
        final repository = sl<ProfileRepository>();
        return GetUserProfileUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<ProfileRepository>();
        return UpdateUserProfileUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<ProfileRepository>();
        return ChangePasswordUseCase(repository);
      }
  );

  // devices
  sl.registerFactory(
      () {
        final repository = sl<DeviceRepository>();
        return GetUserDevicesUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<DeviceRepository>();
        return RenameDeviceUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<DeviceRepository>();
        return ToggleAutoSyncUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<DeviceRepository>();
        return UnlinkDeviceUseCase(repository);
      }
  );

  // sync session
  sl.registerFactory(
      () {
        final syncDeviceRepository = sl<SyncDeviceRepository>();
        return RegisterSyncDeviceUseCase(syncDeviceRepository);
      }
  );

  sl.registerFactory(
      () {
        final syncSessionRepository = sl<SyncSessionRepository>();
        return StartSyncSessionUseCase(syncSessionRepository);
      }
  );

  sl.registerFactory(
          () {
        final syncSessionRepository = sl<SyncSessionRepository>();
        return CheckDuplicatedFilesUseCase(syncSessionRepository);
      }
  );

  sl.registerFactory(
          () {
        final syncSessionRepository = sl<SyncSessionRepository>();
        return UploadFileUseCase(syncSessionRepository);
      }
  );

  sl.registerFactory(
          () {
        final syncSessionRepository = sl<SyncSessionRepository>();
        return CompleteSyncSessionUseCase(syncSessionRepository);
      }
  );

  // gallery
  sl.registerFactory(
      () {
        final repository = sl<GalleryRepository>();
        return GetFilesUseCase(repository);
      }
  );
  sl.registerFactory(
      () {
        final repository = sl<GalleryRepository>();
        return GetPendingFileIdsUseCase(repository);
      }
  );

  // file management
  sl.registerFactory(
      () {
        final repository = sl<FileManagementRepository>();
        return GetFileInfoUseCase(repository);
      }
  );
  sl.registerFactory(
      () {
        final repository = sl<FileManagementRepository>();
        return ManageFilesUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<FileManagementRepository>();
        return GetFoldersUseCase(repository);
      }
  );

  // folders
  sl.registerFactory(
      () {
        final repository = sl<FolderRepository>();
        return GetFoldersListUseCase(repository);
      }
  );

  sl.registerFactory(
          () {
        final repository = sl<FolderRepository>();
        return GetFolderContentUseCase(repository);
      }
  );

  // album covers
  sl.registerFactory(() => GetCoverTargetsUseCase(sl<CoversRepository>()));
  sl.registerFactory(() => ApplyCoverChangesUseCase(sl<CoversRepository>()));
  sl.registerFactory(() => GetAlbumCoversUseCase(sl<CoversRepository>()));
  sl.registerFactory(() => SetAlbumCoversUseCase(sl<CoversRepository>()));

  // favorites
  sl.registerFactory(() => SetFavoriteUseCase(sl<FavoritesRepository>()));

  sl.registerFactory(
          () {
        final repository = sl<FolderRepository>();
        return CreateFolderUseCase(repository);
      }
  );

  sl.registerFactory(
          () {
        final repository = sl<FolderRepository>();
        return RenameFolderUseCase(repository);
      }
  );

  sl.registerFactory(
          () {
        final repository = sl<FolderRepository>();
        return DeleteFolderUseCase(repository);
      }
  );

  // synchronization
  sl.registerFactory(
      () {
        final repository = sl<SynchronizationRepository>();
        return GetSynchronizationsUseCase(repository);
      }
  );

  // trash
  sl.registerFactory(
      () {
        final repository = sl<TrashRepository>();
        return GetTrashFilesUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<TrashRepository>();
        return RestoreFilesUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<TrashRepository>();
        return PermanentlyDeleteFilesUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<TrashRepository>();
        return EmptyTrashUseCase(repository);
      }
  );

  // sync config
  sl.registerFactory(
      () {
        final repository = sl<SyncConfigRepository>();
        return GetSyncConfigUseCase(repository);
      }
  );

  sl.registerFactory(
      () {
        final repository = sl<SyncConfigRepository>();
        return SaveSyncConfigUseCase(repository);
      }
  );


  // BLOC'S
  // auth
  sl.registerFactory(
      () {
        final loginUseCase = sl<LoginUseCase>();
        final registerUseCase = sl<RegisterUseCase>();
        final logoutUseCase = sl<LogoutUseCase>();
        final refreshTokenUseCase = sl<RefreshTokenUseCase>();
        final registerSyncDeviceUseCase = sl<RegisterSyncDeviceUseCase>();
        final requestPasswordResetUseCase = sl<RequestPasswordResetUseCase>();
        final validateResetCodeUseCase = sl<ValidateResetCodeUseCase>();
        final resetPasswordUseCase = sl<ResetPasswordUseCase>();
        final authRepository = sl<AuthRepository>();
        final syncDeviceRepository = sl<SyncDeviceRepository>();
        final eventBus = sl<AppEventBus>();
        return AuthBloc(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            logoutUseCase: logoutUseCase,
            refreshTokenUseCase: refreshTokenUseCase,
            registerSyncDeviceUseCase: registerSyncDeviceUseCase,
            requestPasswordResetUseCase: requestPasswordResetUseCase,
            validateResetCodeUseCase: validateResetCodeUseCase,
            resetPasswordUseCase: resetPasswordUseCase,
            authRepository: authRepository,
            syncDeviceRepository: syncDeviceRepository,
            eventBus: eventBus,
        );
      }
  );

  // profile
  sl.registerLazySingleton(
      () {
        final getUserProfileUseCase = sl<GetUserProfileUseCase>();
        final updateUserProfileUseCase = sl<UpdateUserProfileUseCase>();
        final changePasswordUseCase = sl<ChangePasswordUseCase>();
        final eventBus = sl<AppEventBus>();
        return ProfileBloc(
          getUserProfileUseCase,
          updateUserProfileUseCase,
          changePasswordUseCase,
          eventBus,
        );
      }
  );

  // devices
  sl.registerFactory(
      () {
        final getUserDevicesUseCase = sl<GetUserDevicesUseCase>();
        final renameDeviceUseCase = sl<RenameDeviceUseCase>();
        final toggleAutoSyncUseCase = sl<ToggleAutoSyncUseCase>();
        final unlinkDeviceUseCase = sl<UnlinkDeviceUseCase>();
        final eventBus = sl<AppEventBus>();
        final syncSchedulerService = sl<SyncSchedulerService>();
        final syncConfigRepository = sl<SyncConfigRepository>();
        return DeviceBloc(
          getUserDevicesUseCase: getUserDevicesUseCase,
          renameDeviceUseCase: renameDeviceUseCase,
          toggleAutoSyncUseCase: toggleAutoSyncUseCase,
          unlinkDeviceUseCase: unlinkDeviceUseCase,
          eventBus: eventBus,
          syncSchedulerService: syncSchedulerService,
          syncConfigRepository: syncConfigRepository,
        );
      }
  );

  // sync session
  sl.registerLazySingleton(
      () {
        final startSyncSessionUseCase = sl<StartSyncSessionUseCase>();
        final checkDuplicatesUseCase = sl<CheckDuplicatedFilesUseCase>();
        final uploadFilesUseCase = sl<UploadFileUseCase>();
        final completeSyncSessionUseCase = sl<CompleteSyncSessionUseCase>();
        final syncSessionRepository = sl<SyncSessionRepository>();
        final syncDeviceRepository = sl<SyncDeviceRepository>();
        final mediaLocalDataSource = sl<MediaLocalDataSource>();
        final eventBus = sl<AppEventBus>();
        final sharedPreferences = sl<SharedPreferences>();

        return SyncSessionBloc(
          startSyncSessionUseCase: startSyncSessionUseCase,
          checkDuplicatedFilesUseCase: checkDuplicatesUseCase,
          uploadFileUseCase: uploadFilesUseCase,
          completeSyncSessionUseCase: completeSyncSessionUseCase,
          syncSessionRepository: syncSessionRepository,
          syncDeviceRepository: syncDeviceRepository,
          mediaLocalDataSource: mediaLocalDataSource,
          eventBus: eventBus,
          sharedPreferences: sharedPreferences,
        );
      }
  );

  // gallery
  sl.registerFactory(
      () {
        final getFileUseCase = sl<GetFilesUseCase>();
        final getPendingFileIdsUseCase = sl<GetPendingFileIdsUseCase>();
        final eventBus = sl<AppEventBus>();
        return GalleryBloc(
          getFilesUseCase: getFileUseCase,
          getPendingFileIdsUseCase: getPendingFileIdsUseCase,
          eventBus: eventBus,
        );
      }
  );

  // file management
  sl.registerFactory(
      () {
        final manageFilesUseCase = sl<ManageFilesUseCase>();
        final eventBus = sl<AppEventBus>();
        return FileManagementBloc(manageFilesUseCase: manageFilesUseCase, eventBus: eventBus);
      }
  );

  sl.registerFactory(
      () {
        final getFoldersUseCase = sl<GetFoldersUseCase>();
        final eventBus = sl<AppEventBus>();
        return ManageFolderBloc(getFoldersUseCase: getFoldersUseCase, eventBus: eventBus);
      }
  );
  sl.registerFactory(
      () => FileInfoBloc(getFileInfoUseCase: sl<GetFileInfoUseCase>())
  );
  sl.registerFactory(
      () => FavoritesBloc(setFavoriteUseCase: sl<SetFavoriteUseCase>(), eventBus: sl<AppEventBus>())
  );
  sl.registerFactory(
      () => CoverPickerCubit(
        getCoverTargetsUseCase: sl<GetCoverTargetsUseCase>(),
        applyCoverChangesUseCase: sl<ApplyCoverChangesUseCase>(),
        eventBus: sl<AppEventBus>(),
      )
  );
  sl.registerFactory(
      () => AlbumCoversCubit(
        getAlbumCoversUseCase: sl<GetAlbumCoversUseCase>(),
        setAlbumCoversUseCase: sl<SetAlbumCoversUseCase>(),
        eventBus: sl<AppEventBus>(),
      )
  );

  // folders
  sl.registerFactory(
      () {
        final getFoldersUseCase = sl<GetFoldersListUseCase>();
        final createFolderUseCase = sl<CreateFolderUseCase>();
        final renameFolderUseCase = sl<RenameFolderUseCase>();
        final deleteFolderUseCase = sl<DeleteFolderUseCase>();
        final eventBus = sl<AppEventBus>();

        return FolderBloc(
          getFoldersUseCase: getFoldersUseCase,
          createFolderUseCase: createFolderUseCase,
          renameFolderUseCase: renameFolderUseCase,
          deleteFolderUseCase: deleteFolderUseCase,
          eventBus: eventBus,
        );
      }
  );

  sl.registerFactory(
      () {
        final getFolderContentUseCase = sl<GetFolderContentUseCase>();
        final eventBus = sl<AppEventBus>();

        return FolderContentBloc(getFolderContentUseCase: getFolderContentUseCase, eventBus: eventBus);
      }
  );

  // synchronization
  sl.registerFactory(
      () {
        final getSynchronizationsUseCase = sl<GetSynchronizationsUseCase>();
        final syncDeviceRepository = sl<SyncDeviceRepository>();
        final eventBus = sl<AppEventBus>();
        return SynchronizationBloc(
            getSynchronizationsUseCase: getSynchronizationsUseCase,
            syncDeviceRepository: syncDeviceRepository,
            eventBus: eventBus,
        );
      }
  );

  // trash
  sl.registerFactory(
      () {
        final getTrashFilesUseCase = sl<GetTrashFilesUseCase>();
        final restoreFilesUseCase = sl<RestoreFilesUseCase>();
        final permanentlyDeleteFilesUseCase = sl<PermanentlyDeleteFilesUseCase>();
        final emptyTrashUseCase = sl<EmptyTrashUseCase>();
        final eventBus = sl<AppEventBus>();
        return TrashBloc(
          getTrashFilesUseCase: getTrashFilesUseCase,
          restoreFilesUseCase: restoreFilesUseCase,
          permanentlyDeleteFilesUseCase: permanentlyDeleteFilesUseCase,
          emptyTrashUseCase: emptyTrashUseCase,
          eventBus: eventBus,
        );
      }
  );

  // sync config
  sl.registerFactory(
      () {
        final getSyncConfigUseCase = sl<GetSyncConfigUseCase>();
        final saveSyncConfigUseCase = sl<SaveSyncConfigUseCase>();
        final syncSchedulerService = sl<SyncSchedulerService>();
        return SyncConfigBloc(
          getSyncConfigUseCase: getSyncConfigUseCase,
          saveSyncConfigUseCase: saveSyncConfigUseCase,
          syncSchedulerService: syncSchedulerService,
        );
      }
  );

  // ─── ONBOARDING ──────────────────────────────────────────────────────────

  // Data source
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(
      OnboardingPreferences(sl<SharedPreferences>()),
    ),
  );

  // Repository
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingDataRepository(sl<OnboardingLocalDataSource>()),
  );

  // Use cases
  sl.registerFactory(
    () => CheckOnboardingStatusUseCase(sl<OnboardingRepository>()),
  );

  sl.registerFactory(
    () => CompleteOnboardingUseCase(sl<OnboardingRepository>()),
  );

  sl.registerLazySingleton<PermissionService>(() => DevicePermissionService());

  // BLoC
  sl.registerFactory(
    () => OnboardingBloc(
      completeOnboardingUseCase: sl<CompleteOnboardingUseCase>(),
      permissionService: sl<PermissionService>(),
    ),
  );

  // OnboardingNotifier is registered in main.dart after AuthBloc is created,
  // because it needs the same AuthBloc singleton instance.
  // It is registered here as a placeholder; see main.dart for the actual registration.
}