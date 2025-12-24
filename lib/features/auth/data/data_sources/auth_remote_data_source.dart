import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';

import '../models/auth_response_model.dart';


abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<void> logout(String token);
}


class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {

  final http.Client client;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = DataConstants.backendBaseUrl
  });

  @override
  Future<AuthResponseModel> login(String email, String password) async {

    final url =  Uri.parse('$baseUrl/api/login/');

    try {
      final response = await client.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password})
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AuthResponseModel.fromJson(jsonData);
      } else {
        throw Exception(jsonDecode(response.body)["code"]);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connexion error: $e');
    }
  }

  @override
  Future<void> logout(String token) async {

    final url = Uri.parse('$baseUrl/api/logout/');

    try {
      await client.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }
      );
    } catch (e){
      // Ignore the error, the token will be cleared anyways
    }
  }
}