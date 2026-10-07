/// Acceptance of the terms of use and the privacy policy by the logged-in user.
abstract class LegalAcceptanceRepository {
  Future<void> accept({required String termsVersion, required String privacyVersion});
}
