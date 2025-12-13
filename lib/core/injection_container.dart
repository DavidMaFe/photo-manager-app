
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager_app/features/auth/data/data_sources/local/auth_local_datasource.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/local/auth_local_datasource_impl.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/remote/auth_remote_datasource.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/remote/http_remote_datasource.dart';
import 'package:photo_manager_app/features/auth/data/repositories/auth_data_repository.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';


final sl = GetIt.instance;

Future<void> init() async {

  // GENERAL INJECTIONS
  sl.registerLazySingleton(() => http.Client());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);


  // DATASOURCE'S
  sl.registerLazySingleton<AuthRemoteDatasource>(
      () {
        final client = sl<http.Client>();
        return HttpRemoteDatasource(client: client);
      }
  );

  sl.registerLazySingleton<AuthLocalDatasource>(
      () {
        final sharedPreferences = sl<SharedPreferences>();
        return AuthLocalDatasourceImpl(sharedPreferences: sharedPreferences);
      }
  );

  // REPOSITORIES
  sl.registerLazySingleton<AuthRepository>(
      () {
        final remoteDatasource = sl<AuthRemoteDatasource>();
        final localDatasource = sl<AuthLocalDatasource>();
        return AuthDataRepository(
            remoteDatasource: remoteDatasource,
            localDatasource: localDatasource
        );
      }
  );

  // USE CASES
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

  // BLOC'S
  sl.registerFactory(
      () {
        final loginUseCase = sl<LoginUseCase>();
        final logoutUseCase = sl<LogoutUseCase>();
        final authRepository = sl<AuthRepository>();
        return AuthBloc(loginUseCase: loginUseCase, logoutUseCase: logoutUseCase,
            authRepository: authRepository);
      }
  );
}