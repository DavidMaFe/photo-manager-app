/// The login asked for the second factor: the password was right, but this device is not trusted yet. The keys and
/// the tokens come once the code emailed to [emailHint] is sent with [challengeToken].
class SecondFactorChallenge {
  final String challengeToken;
  final String method;

  /// The masked email the code went to (`d***@outlook.es`).
  final String emailHint;

  const SecondFactorChallenge({required this.challengeToken, required this.method, required this.emailHint});
}
