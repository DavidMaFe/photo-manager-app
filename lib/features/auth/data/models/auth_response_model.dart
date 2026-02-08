
import 'package:photo_manager_app/features/auth/data/models/user_model.dart';

class AuthResponseModel {

  final String token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final UserModel user;

  AuthResponseModel({
    required this.token,
    this.refreshToken,
    this.expiresAt,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {

    final token = json['token'] as String;
    final refreshToken = json['refreshToken'] as String?;
    final expiresAt = json['expiresAt'] == null
        ? null
        : DateTime.parse(json['expiresAt'] as String);

    final user = UserModel(
        id: json['id'].toString(),
        email: json['email'] as String,
        name: json['name'] as String,
        surname: json['surname'] == null ? null : json['surname'] as String
    );

    return AuthResponseModel(
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'token': token,
      'user': user.toJson(),
    };

    if (refreshToken != null) {
      json['refreshToken'] = refreshToken!;
    }

    if (expiresAt != null) {
      json['expiresAt'] = expiresAt!.toIso8601String();
    }

    return json;
  }
}