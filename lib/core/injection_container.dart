
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:photo_manager_app/features/auth/data/repositories/auth_data_repository.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:photo_manager_app/features/profile/data/repositories/profile_data_repository.dart';
import 'package:photo_manager_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';


final sl = GetIt.instance;

Future<void> init() async {

  // GENERAL INJECTIONS
  sl.registerLazySingleton(() => http.Client());

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

  // BLOC'S
  // auth
  sl.registerFactory(
      () {
        final loginUseCase = sl<LoginUseCase>();
        final logoutUseCase = sl<LogoutUseCase>();
        final authRepository = sl<AuthRepository>();
        return AuthBloc(loginUseCase: loginUseCase, logoutUseCase: logoutUseCase,
            authRepository: authRepository);
      }
  );

  // profile
  sl.registerLazySingleton(
      () {
        final getUserProfileUseCase = sl<GetUserProfileUseCase>();
        return ProfileBloc(getUserProfileUseCase);
      }
  );
}