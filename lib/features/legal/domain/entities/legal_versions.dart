/// Versions of the legal texts bundled in the app. They must match app.legal.* in the backend: when a text changes,
/// raise its version here and there, and every user accepts it again at the next login.
class LegalVersions {
  const LegalVersions._();

  static const String terms = '1.0';
  static const String privacy = '1.0';

  /// Date the current versions came into force.
  static final DateTime effectiveDate = DateTime(2026, 10, 7);
}
