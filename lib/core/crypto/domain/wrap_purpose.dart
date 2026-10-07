/// What a wrapped key is used for. It is part of the authenticated data, so a key wrapped for one purpose cannot be
/// opened as another (docs/e2ee-spec.md, section 4.1).
enum WrapPurpose {
  masterKeyByPassword('mk-by-password'),
  masterKeyByRecovery('mk-by-recovery'),
  identitySecretKey('identity-sk'),
  fileKey('file-key');

  final String label;

  const WrapPurpose(this.label);
}
