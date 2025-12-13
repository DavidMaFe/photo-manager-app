
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/features/auth/data/data_sources/remote/auth_remote_datasource.dart';
import 'package:photo_manager_app/features/auth/data/models/auth_response_model.dart';


class HttpRemoteDatasource implements AuthRemoteDatasource {

  final http.Client client;
  final String baseUrl;

  HttpRemoteDatasource({
    required this.client,
    this.baseUrl = 'http://10.0.2.2:8080'
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
      } else if (response.statusCode == 401) {
        throw Exception('Email or password are not correct');
      } else {
        throw Exception('Server error: ${response.statusCode}');
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