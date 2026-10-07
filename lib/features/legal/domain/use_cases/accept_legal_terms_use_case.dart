import 'package:photo_manager_app/features/legal/domain/entities/legal_versions.dart';
import 'package:photo_manager_app/features/legal/domain/repositories/legal_acceptance_repository.dart';

/// Accepts the versions of the terms of use and the privacy policy shown by this app (after a new version, or for
/// accounts created before they existed).
class AcceptLegalTermsUseCase {
  final LegalAcceptanceRepository _repository;

  AcceptLegalTermsUseCase(this._repository);

  Future<void> call() => _repository.accept(termsVersion: LegalVersions.terms, privacyVersion: LegalVersions.privacy);
}
