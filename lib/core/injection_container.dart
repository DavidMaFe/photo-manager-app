
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:photo_manager_app/features/auth/data/repositories/auth_data_repository.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

import '../features/sync_session/presentation/bloc/sync_session_bloc.dart';


final sl = GetIt.instance;

Future<void> init() async {

  // GENERAL INJECTIONS
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => DeviceInfoPlugin());

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

  // profile
  sl.registerFactory(
      () {
        final repository = sl<ProfileRepository>();
        return GetUserProfileUseCase(repository);
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


  // BLOC'S
  // auth
  sl.registerFactory(
      () {
        final loginUseCase = sl<LoginUseCase>();
        final logoutUseCase = sl<LogoutUseCase>();
        final registerSyncDeviceUseCase = sl<RegisterSyncDeviceUseCase>();
        final authRepository = sl<AuthRepository>();
        final syncDeviceRepository = sl<SyncDeviceRepository>();
        return AuthBloc(
            loginUseCase: loginUseCase,
            logoutUseCase: logoutUseCase,
            registerSyncDeviceUseCase: registerSyncDeviceUseCase,
            authRepository: authRepository,
            syncDeviceRepository: syncDeviceRepository
        );
      }
  );

  // profile
  sl.registerLazySingleton(
      () {
        final getUserProfileUseCase = sl<GetUserProfileUseCase>();
        return ProfileBloc(getUserProfileUseCase);
      }
  );

  // sync session
  sl.registerFactory(
      () {
        final startSyncSessionUseCase = sl<StartSyncSessionUseCase>();
        final checkDuplicatesUseCase = sl<CheckDuplicatedFilesUseCase>();
        final uploadFilesUseCase = sl<UploadFileUseCase>();
        final completeSyncSessionUseCase = sl<CompleteSyncSessionUseCase>();
        final syncSessionRepository = sl<SyncSessionRepository>();
        final syncDeviceRepository = sl<SyncDeviceRepository>();
        final mediaLocalDataSource = sl<MediaLocalDataSource>();

        return SyncSessionBloc(
          startSyncSessionUseCase: startSyncSessionUseCase,
          checkDuplicatedFilesUseCase: checkDuplicatesUseCase,
          uploadFileUseCase: uploadFilesUseCase,
          completeSyncSessionUseCase: completeSyncSessionUseCase,
          syncSessionRepository: syncSessionRepository,
          syncDeviceRepository: syncDeviceRepository,
          mediaLocalDataSource: mediaLocalDataSource
        );
      }
  );

  // gallery
  sl.registerFactory(
      () {
        final getFileUseCase = sl<GetFilesUseCase>();
        return GalleryBloc(getFilesUseCase: getFileUseCase);
      }
  );
}