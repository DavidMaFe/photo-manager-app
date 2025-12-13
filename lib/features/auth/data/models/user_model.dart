
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';


class UserModel extends User {

  UserModel({required super.id, required super.email, required super.name, super.surname});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'].toString(),
        email: json['email'] as String,
        name: json['name'] as String,
        surname: json['surname'] as String?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (surname != null) 'surname': surname
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
        id: user.id,
        email: user.email,
        name: user.name,
        surname: user.surname
    );
  }
}