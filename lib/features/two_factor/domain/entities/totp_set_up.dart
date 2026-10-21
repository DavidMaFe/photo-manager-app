/// A pending set-up of the authenticator app: the [secret] to type in it, or the [otpauthUri] that opens it with the
/// secret already filled in. Kept in memory only, while the set-up lasts.
class TotpSetUp {
  final String secret;
  final String otpauthUri;

  const TotpSetUp({required this.secret, required this.otpauthUri});

  /// The secret in groups of 4, easier to type: `GEZD GNBV ...`.
  String get groupedSecret {
    final groups = <String>[];
    for (var i = 0; i < secret.length; i += 4) {
      groups.add(secret.substring(i, i + 4 > secret.length ? secret.length : i + 4));
    }
    return groups.join(' ');
  }
}
