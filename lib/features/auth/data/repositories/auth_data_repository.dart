
import 'package:photo_manager_app/features/auth/data/data_sources/local/auth_local_datasource.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/remote/auth_remote_datasource.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';

import '../../domain/entities/user.dart';


class AuthDataRepository implements AuthRepository {

  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;

  AuthDataRepository({
    required this.remoteDatasource,
    required this.localDatasource
  });

  @override
  Future<User> login({required String email, required String password}) async {

    final authResponse = await remoteDatasource.login(email, password);

    await localDatasource.cacheToken(authResponse.token);
    await localDatasource.cacheUser(authResponse.user);

    return authResponse.user;
  }

  @override
  Future<void> logout() async {

    try {
      final token = await localDatasource.getToken();

      if (token != null && token.isNotEmpty) {
        await remoteDatasource.logout(token);
      }
    } catch (e) {
      await localDatasource.clearCache();
    }
  }

  @override
  Future<User?> getCurrentUser() async {

    final cachedUser = await localDatasource.getCachedUser();

    if (cachedUser != null && await localDatasource.hasValidToken()) {
      return cachedUser;
    } else {
      await localDatasource.clearCache();
      return null;
    }
  }

  @override
  Future<bool> hasToken() async {
    return await localDatasource.hasValidToken();
  }
}