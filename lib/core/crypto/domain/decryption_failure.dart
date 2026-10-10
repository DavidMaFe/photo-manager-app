/// The data could not be decrypted: wrong key, or data that was modified or truncated.
///
/// The message never includes key material.
class DecryptionFailure implements Exception {
  final String message;

  const DecryptionFailure(this.message);

  @override
  String toString() => 'DecryptionFailure: $message';
}
