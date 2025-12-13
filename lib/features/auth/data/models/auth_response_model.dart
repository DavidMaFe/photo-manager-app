
import 'package:photo_manager_app/features/auth/data/models/user_model.dart';

class AuthResponseModel {

  final String token;
  final UserModel user;
  final String? refreshToken;
  final DateTime? expiresAt;

  AuthResponseModel({
    required this.token,
    required this.user,
    this.refreshToken,
    this.expiresAt
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {

    final token = json['token'] as String;

    final user = UserModel(
        id: json['id'].toString(),
        email: json['email'] as String,
        name: json['name'] as String,
        surname: json['surname'] as String
    );

    return AuthResponseModel(
      token: token,
      user: user,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String()
    };
  }

  bool get isExpired {
    if(expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}