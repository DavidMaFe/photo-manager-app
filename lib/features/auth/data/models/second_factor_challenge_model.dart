import 'package:photo_manager_app/features/auth/domain/entities/second_factor_challenge.dart';

class SecondFactorChallengeModel extends SecondFactorChallenge {

  const SecondFactorChallengeModel({required super.challengeToken, required super.method, required super.emailHint});

  factory SecondFactorChallengeModel.fromJson(Map<String, dynamic> json) {
    return SecondFactorChallengeModel(
      challengeToken: json['challengeToken'] as String,
      method: json['method'] as String,
      emailHint: json['emailHint'] as String,
    );
  }
}
