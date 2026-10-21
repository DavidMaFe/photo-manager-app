import 'package:photo_manager_app/features/auth/data/models/auth_response_model.dart';
import 'package:photo_manager_app/features/auth/data/models/second_factor_challenge_model.dart';

/// Answer of POST /api/login/: the session ([session]), or the second factor ([challenge]) when the device is not
/// trusted (`secondFactorRequired: true`). Exactly one of them.
class LoginResponseModel {
  final AuthResponseModel? session;
  final SecondFactorChallengeModel? challenge;

  const LoginResponseModel.session(AuthResponseModel this.session) : challenge = null;

  const LoginResponseModel.challenge(SecondFactorChallengeModel this.challenge) : session = null;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['secondFactorRequired'] == true) {
      return LoginResponseModel.challenge(SecondFactorChallengeModel.fromJson(json));
    }
    return LoginResponseModel.session(AuthResponseModel.fromJson(json));
  }
}
