
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager_app/core/database/app_database.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:photo_manager_app/features/auth/data/repositories/auth_data_repository.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/file_management/data/data_sources/file_deletion_local_data_source.dart';
import 'package:photo_manager_app/features/file_management/data/data_sources/file_management_remote_data_source.dart';
import 'package:photo_manager_app/features/file_management/data/repositories/file_management_repository_impl.dart';
import 'package:photo_manager_app/features/file_management/domain/repositories/file_management_repository.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/get_folders_use_case.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/manage_files_use_case.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
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
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:photo_manager_app/features/profile/data/repositories/profile_data_repository.dart';
import 'package:photo_manager_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/update_user_profile_use_case.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/change_password_use_case.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_bloc.dart';
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
import '../features/sync_session/presentation/bloc/sync_session_bloc.dart';
import 'events/app_event_bus.dart';


final sl = GetIt.instance;

Future<void> init() async {

  // GENERAL INJECTIONS
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => DeviceInfoPlugin());
  sl.registerLazySingleton(() => AppDatabase());
  sl.registerLazySingleton(() => AppEventBus());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);


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
        final client = sl<http.Client>();
        final authLocalDataSource = sl<AuthLocalDataSource>();
        return ProfileRemoteDataSourceImpl(client: client,
            authLocalDataSource: authLocalDataSource);
      }
  );

  sl.registerLazySingleton<ProfileLocalDataSource>(
      () {
        final sharedPreferences = sl<SharedPreferences>();
        return ProfileLocalDataSourceImpl(sharedPreferences: sharedPreferences);
      }
  );

  // sync session
  sl.registerLazySingleton<SyncSessionRemoteDataSource>(
      () {
        final client = sl<http.Client>();
        final authLocalDataSource = sl<AuthLocalDataSource>();
        return SyncSessionRemoteDatasourceImpl(
          client: client,
          authLocalDataSource: authLocalDataSource
        );
      }
  );

  sl.registerLazySingleton<SyncDeviceRemoteDataSource>(
      () {
        final client = sl<http.Client>();
        final authLocalDataSource = sl<AuthLocalDataSource>();
        return SyncDeviceRemoteDataSourceImpl(
            client: client,
            authLocalDataSource: authLocalDataSource
        );
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
        final client = sl<http.Client>();
        final autLocalDataSource = sl<AuthLocalDataSource>();
        return GalleryRemoteDataSourceImpl(
          client: client,
          authLocalDataSource: autLocalDataSource
        );
      }
  );

  // file management
  sl.registerLazySingleton<FileManagementRemoteDataSource>(
      () {
        final client = sl<http.Client>();
        final authLocalDataSource = sl<AuthLocalDataSource>();
        return FileManagementRemoteDataSourceImpl(
          client: client,
          authLocalDataSource: authLocalDataSource
        );
      }
  );

  sl.registerLazySingleton<FileDeletionLocalDataSource>(
      () {
        return FileDeletionLocalDataSourceImpl();
      }
  );

  // folders
  sl.registerLazySingleton<FolderRemoteDataSource>(
      () {
        final client = sl<http.Client>();
        final authLocalDataSource = sl<AuthLocalDataSource>();
        return FolderRemoteDataSourceImpl(
            client: client,
            authLocalDataSource: authLocalDataSource
        );
      }
  ) ;

  // synchronization
  sl.registerLazySingleton<SynchronizationRemoteDataSource>(
      () {
        final client = sl<http.Client>();
        final authLocalDataSource = sl<AuthLocalDataSource>();
        return SynchronizationRemoteDataSourceImpl(
            client: client,
            authLocalDataSource: authLocalDataSource
        );
      }
  );

  // trash
  sl.registerLazySingleton<TrashRemoteDataSource>(
      () {
        final client = sl<http.Client>();
        final authLocalDataSource = sl<AuthLocalDataSource>();
        return TrashRemoteDataSourceImpl(
          client: client,
          authLocalDataSource: authLocalDataSource
        );
      }
  );


  // REPOSITORIES
  // auth
  sl.registerLazySingleton<AuthRepository>(
      () {
        final remoteDataSource = sl<AuthRemoteDataSource>();
        final localDataSource = sl<AuthLocalDataSource>();
        final profileLocalDataSource = sl<ProfileLocalDataSource>();
        return AuthDataRepository(
            remoteDataSource: remoteDataSource,
            localDataSource: localDataSource,
            profileLocalDataSource: profileLocalDataSource
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

  // file management
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


  // BLOC'S
  // auth
  sl.registerFactory(
      () {
        final loginUseCase = sl<LoginUseCase>();
        final registerUseCase = sl<RegisterUseCase>();
        final logoutUseCase = sl<LogoutUseCase>();
        final registerSyncDeviceUseCase = sl<RegisterSyncDeviceUseCase>();
        final requestPasswordResetUseCase = sl<RequestPasswordResetUseCase>();
        final validateResetCodeUseCase = sl<ValidateResetCodeUseCase>();
        final resetPasswordUseCase = sl<ResetPasswordUseCase>();
        final authRepository = sl<AuthRepository>();
        final syncDeviceRepository = sl<SyncDeviceRepository>();
        return AuthBloc(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            logoutUseCase: logoutUseCase,
            registerSyncDeviceUseCase: registerSyncDeviceUseCase,
            requestPasswordResetUseCase: requestPasswordResetUseCase,
            validateResetCodeUseCase: validateResetCodeUseCase,
            resetPasswordUseCase: resetPasswordUseCase,
            authRepository: authRepository,
            syncDeviceRepository: syncDeviceRepository
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

        return SyncSessionBloc(
          startSyncSessionUseCase: startSyncSessionUseCase,
          checkDuplicatedFilesUseCase: checkDuplicatesUseCase,
          uploadFileUseCase: uploadFilesUseCase,
          completeSyncSessionUseCase: completeSyncSessionUseCase,
          syncSessionRepository: syncSessionRepository,
          syncDeviceRepository: syncDeviceRepository,
          mediaLocalDataSource: mediaLocalDataSource,
          eventBus: eventBus,
        );
      }
  );

  // gallery
  sl.registerFactory(
      () {
        final getFileUseCase = sl<GetFilesUseCase>();
        final eventBus = sl<AppEventBus>();
        return GalleryBloc(getFilesUseCase: getFileUseCase, eventBus: eventBus);
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
}